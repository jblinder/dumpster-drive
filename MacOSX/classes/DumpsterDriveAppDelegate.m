//
//  DumpsterDriveAppDelegate.m
//  DumpsterDrive
//
//  Created by Justin Blinder.
//  Copyright 2011. All rights reserved.
//

#import "DumpsterDriveAppDelegate.h"

@implementation DumpsterDriveAppDelegate

@synthesize window;


- (void)awakeFromNib 
{
	window.title = @"Dumpster Drive";
	queuePosition = 1;
	queueTotal    = 0;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
	[NSApp activateIgnoringOtherApps:YES];
	
	uploadFilesArray   = [[NSMutableArray alloc] init];
	uploadFoldersArray = [[NSMutableArray alloc] init];
 	[tableView setUIDelegate:self];
    [tableView setMainFrameURL:DUMPSTER_ROOT_URL];
	NSLog(@"url %@",DUMPSTER_ROOT_URL);
	[downloadQueueStatus setStringValue:@""];
	
	NSString *firstLaunch = [[DirectoryManager sharedInstance] getBundleValueAsString:@"first_launch"];
	NSString *file		  = [[DirectoryManager sharedInstance] getBundleValueAsString:@"delete_folder"];
	
    NSFileManager *fileManager = [[NSFileManager alloc] init];

	if([firstLaunch isEqualToString:@"YES"])
    {
		[NSApp beginSheet:introSheet modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];		
	}
	else if(![fileManager fileExistsAtPath:file])
	{
		[NSApp beginSheet:configureSheet modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];		
	}
	else
	{
		[defaultBackground setHidden:YES];
		[downloadFolderPath setStringValue:file];
		[downloadFolderDisplay setStringValue:[downloadFolderPath stringValue]];	
	}
    [fileManager release];

}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [tableView setMainFrameURL:DUMPSTER_ROOT_URL];
}


#pragma mark --
#pragma mark Actions delegate methods


- (IBAction)getDirectory:(id)sender 
{
	[downloadQueueStatus setStringValue:@""];
    selectedURL = [tableView stringByEvaluatingJavaScriptFromString:@"getContent();"];  
	NSString *formattedURL = [selectedURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	formattedURL = [formattedURL stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
	
	if ( [selectedURL length] == 0)
	{
		[downloadStatus setStringValue:@"Must Select A File To Download"];
	}
	
	NSURL *url = [NSURL URLWithString:selectedURL];
	NSArray *chunks = [formattedURL componentsSeparatedByString: @"/"];
	NSString *filePath  = [NSString stringWithFormat:@"%@/%@",[downloadFolderPath stringValue],[chunks objectAtIndex:[chunks count]-1]];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDownloadDestinationPath:filePath];
	[request setDownloadProgressDelegate:progressIndicatorDownload];
	[request setDelegate:self];
	[request startAsynchronous];
}

//Reveals Settings Sheet
- (IBAction)getSettings:(id)sender 
{
    [NSApp beginSheet:configureSheet modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];		
}

//Removes Settings Sheet
- (IBAction)finishSettings:(id)sender
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSString *firstLaunch = [[DirectoryManager sharedInstance] getBundleValueAsString:@"first_launch"];

	BOOL isDir;
	if([firstLaunch isEqualToString:@"YES"] && [fileManager fileExistsAtPath:[downloadFolderIntroPath stringValue] isDirectory:&isDir] && isDir )
	{
		[[DirectoryManager sharedInstance] setBundleValueAsString:@"first_launch" value:@"NO"];
		[[DirectoryManager sharedInstance] setBundleValueAsString:@"delete_folder" value:[downloadFolderIntroPath stringValue]];
		[downloadFolderPath setStringValue:[downloadFolderIntroPath stringValue]];
		[defaultBackground setHidden:YES];
		[introSheet orderOut:nil];
		[NSApp endSheet:introSheet];
	}
	else if ([fileManager fileExistsAtPath:[downloadFolderPath stringValue] isDirectory:&isDir] && isDir)
	{
		[[DirectoryManager sharedInstance] setBundleValueAsString:@"delete_folder" value:[downloadFolderPath stringValue]];
		[defaultBackground setHidden:YES];
		[configureSheet orderOut:nil];
		[NSApp endSheet:configureSheet];
	}	
    [fileManager release];
}

- (IBAction)openDumpster:(id)sender 
{	
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	[workspace openFile:[downloadFolderPath stringValue]];
}

//Opens File Browser Panel
- (IBAction)browseFiles:(id)sender
{
	NSOpenPanel *oPanel = [[NSOpenPanel openPanel] retain];
	[oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];
    [oPanel setDelegate:self];
	[oPanel	setCanCreateDirectories:YES];
    switch([oPanel runModal])
    {
        case NSFileHandlingPanelOKButton:
        {
		    NSFileManager *fileManager = [[NSFileManager alloc] init];
			NSURL* directoryURL = [oPanel directoryURL];
			NSURL *dumpsterURL   = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Dumpster",[directoryURL path]]];

            [fileManager createDirectoryAtPath:[dumpsterURL path] withIntermediateDirectories:NO attributes:nil error:nil];
            
            NSImage* iconImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"DDRIVE.png"]];
            BOOL didSetIcon = [[NSWorkspace sharedWorkspace] setIcon:iconImage forFile:[dumpsterURL path] options:0];
            [iconImage release];
    
            [downloadFolderIntroPath setStringValue:[dumpsterURL path]];
            [downloadFolderPath setStringValue:[dumpsterURL path]];
            [downloadFolderDisplay setStringValue:[dumpsterURL path]];	
            [fileManager release];

            window.title = [NSString stringWithFormat:@"Dumpster Drive | Download Folder: %@", [downloadFolderDisplay stringValue]];
        }
        case NSFileHandlingPanelCancelButton:
        {
            return;
        }
    }
}

//PREVENTS USER FROM DELETING PAST USER ROOT
-(BOOL)panel:(id)sender shouldEnableURL:(NSURL *)url {
    NSString *path = [url path];
    NSString *homeDir = NSHomeDirectory();
    return [path hasPrefix:homeDir] && ! [path isEqualToString:homeDir];

}

- (void)panel:(id)sender didChangeToDirectoryURL:(NSURL *)url {
    NSString *path = [url path];
    NSString *homeDir = NSHomeDirectory();
    if (! [path hasPrefix:homeDir]) [sender setDirectory:homeDir];
}

- (BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError 
{
    NSString *path = [url path];
    NSString *homeDir = NSHomeDirectory();
    if (! [path hasPrefix:homeDir]) {
        if (outError) *outError = @"URL REQUEST FAILED"; 
            return NO;    
    }
           return YES;
}

- (IBAction)uploadContent:(id)sender
{
     NSFileManager *manager = [[NSFileManager alloc] init];
	 NSURL *path = [NSURL fileURLWithPath:[downloadFolderPath stringValue]];
	 
     NSArray *dirContents =	[manager contentsOfDirectoryAtURL:path 
								   includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey] 
													  options:NSDirectoryEnumerationSkipsHiddenFiles 
														error:nil];
	if ([dirContents count] > 0)
	{
		NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];

		NSDirectoryEnumerator *enumerator = [manager
			enumeratorAtURL:path
			includingPropertiesForKeys:keys
			options:NSDirectoryEnumerationSkipsHiddenFiles
			errorHandler:^(NSURL *url, NSError *error) {
				// Handle the error.
				// Return YES if the enumeration should continue after the error.
				return YES;
		}];

														
		 
		 [downloadQueueStatus setStringValue:@""];
		 
		 queuePosition = 0;
		 queueTotal	  = 0;
		 
		 [networkQueue reset];
		 [networkQueue setShowAccurateProgress:YES];
		 [networkQueue setUploadProgressDelegate:progressIndicatorUpload];
		 [networkQueue setRequestDidFailSelector:@selector(postFailed:)];
		 [networkQueue setRequestDidFinishSelector:@selector(postFinished:)];
		 [networkQueue setDelegate:self];
		 

		for (NSURL *url in enumerator) { 
			NSError *error;
			NSNumber *isDirectory = nil;
			if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error] ) 
			{
				
			}
			else if (! [isDirectory boolValue]) 
			{
				NSLog(@"Number: %@", isDirectory);
				NSLog(@"File: %@", [url path]);
				queueTotal ++;

				NSDictionary *attrs = [manager attributesOfItemAtPath:[url path] error:NULL];

				UInt32 result = [attrs fileSize];
				result /= 1000;
				NSLog(@"size:%i", result);
			 
				ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:DUMPSTER_UPLOAD_URL]] autorelease];
				
				[request setFile:[url path] forKey:@"uploadedfile"];
				[request setPostValue:[NSString stringWithFormat:@"%i",result] forKey:@"filesize"];
				[networkQueue addOperation:request];
				[uploadFilesArray addObject:[url path]];

			}
			else if ( [isDirectory boolValue])
			{
				[uploadFoldersArray addObject:[url path]];
			}
		}	
		[downloadQueueStatus setStringValue:[NSString stringWithFormat:@"Deleting file %i of %i",queuePosition+1,queueTotal]];
		if(queueTotal > 0) [self disableInterface];
		[networkQueue go];
	 }
	[manager release];
}



-(void)filePanelDidEnd:(NSOpenPanel*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo 
{
	[downloadFolderPath setStringValue:[sheet filename]];
	[downloadFolderDisplay setStringValue:[sheet filename]];	
	window.title = [NSString stringWithFormat:@"Dumpster Drive | Download Folder: %@", [downloadFolderDisplay stringValue]];
}


#pragma mark -- 
#pragma mark ASIHTTPRequest DOWNLOAD 

- (void)requestFinished:(ASIHTTPRequest *)request
{
	[downloadStatus setStringValue:@"Download Successful"];
	[progressIndicatorDownload setDoubleValue:0.0f];
	NSString *filepath = [tableView stringByEvaluatingJavaScriptFromString:@"receiveFileID();"];
	NSURL *url = [NSURL URLWithString:DUMPSTER_REMOVE_URL];
	ASIFormDataRequest *removeRequest = [ASIFormDataRequest requestWithURL:url];
    [removeRequest setPostValue:filepath forKey:@"id"];
    [removeRequest startSynchronous];
    [tableView reload:self];
}

//Called when a download request fails
- (void)requestFailed:(ASIHTTPRequest *)request
{
	[downloadStatus setStringValue:@"Download Failed. Please make sure you are online."];
}


- (BOOL)application:(NSApplication *)sender openFile:(NSString *)path
{
	return YES;
}


#pragma mark --
#pragma mark ASIHTTPRequest POST

- (void)postFinished:(ASIHTTPRequest *)request
{
	[downloadStatus setStringValue:@"Upload Successful"];
	[tableView stringByEvaluatingJavaScriptFromString:@"reloadContent();"];
}


//Called if a upload fails
- (void)postFailed:(ASIHTTPRequest *)request
{
	queuePosition++;
	[downloadStatus setStringValue:@"Upload Failed. Please make sure you are online."];
}

#pragma mark --
#pragma mark Interface ON/OFF

- (void)disableInterface
{
	[buttonSettings setEnabled:NO];
	[buttonDownload setEnabled:NO];
	[buttonEmpty setEnabled:NO];
}

- (void)enableInterface
{
	[buttonSettings setEnabled:YES];
	[buttonDownload setEnabled:YES];
	[buttonEmpty setEnabled:YES];
}

#pragma mark --
#pragma mark SETTTINGS

- (NSUInteger)webView:(WebView *)sender dragDestinationActionMaskForDraggingInfo:(id <NSDraggingInfo>)draggingInfo
{
	return 0;
}



@end

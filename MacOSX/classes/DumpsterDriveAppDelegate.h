//
//  DumpsterDriveAppDelegate.h
//  DumpsterDrive
//
//  Created by Justin Blinder.
//  Copyright 2011. All rights reserved.
//

/**
 @Class AppDelegate:

 TODO: REFACTOR BIG TIME! 
 Refactor interface, network, file system management code into seperate classees
 */


#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"	
#import "DirectoryManager.h"


@interface DumpsterDriveAppDelegate : NSObject <NSApplicationDelegate, NSOpenSavePanelDelegate> 
{
    NSWindow *window;
	NSString *dumpsterFolderPath;
	IBOutlet id introSheet;
	IBOutlet id configureSheet;
	IBOutlet NSButton *buttonSettings;
	IBOutlet NSButton *buttonOpen;
	IBOutlet NSButton *buttonEmpty;
	IBOutlet NSButton *buttonDownload;
	IBOutlet NSImageView *dragBox;
	IBOutlet NSProgressIndicator *progressIndicatorDownload;
	IBOutlet NSProgressIndicator *progressIndicatorUpload;
	IBOutlet WebView  *tableView;
	IBOutlet NSTextField *labelUploadSize;
	IBOutlet NSTextField *downloadStatus;
	IBOutlet NSTextField *downloadQueueStatus;
	IBOutlet NSTextField *downloadFolderIntroPath;
	IBOutlet NSTextField *downloadFolderPath;
	IBOutlet NSTextField *downloadFolderDisplay;
	IBOutlet NSImageView *defaultBackground;
	NSMutableArray *uploadFilesArray;
	NSMutableArray *uploadFoldersArray;
	NSString *selectedURL;
	NSString *defaultDownloadFolder;
	int queuePosition;
	int queueTotal;
	ASINetworkQueue *networkQueue;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)getDirectory:(id)sender;
- (IBAction)getSettings:(id)sender;
- (IBAction)finishSettings:(id)sender;
- (IBAction)browseFiles:(id)sender;
- (IBAction)openDumpster:(id)sender;
- (void)disableInterface;
- (void)enableInterface;
@end

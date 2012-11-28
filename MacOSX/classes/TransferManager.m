//
//  TransferManager.m
//  DumpsterDrive
//
//  Created by Justin Blinder.
//  Copyright 2011. All rights reserved.
//

#import "TransferManager.h"


@implementation TransferManager
@synthesize networkQueue;

- (id) init
{
    if ( self = [super init] )
    {
		networkQueue = [[ASINetworkQueue alloc] init];
    }
    return self;
}

#pragma mark --
#pragma mark REQUEST

- (void)downloadFile:(NSURL *)url destination:(NSString *)filePath
{
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDownloadDestinationPath:filePath];
	[request setDownloadProgressDelegate:[[NSApplication sharedApplication] progressIndicatorDownload]];
	[request setDelegate:[NSApplication sharedApplication]];
	[request startAsynchronous];
}



#pragma mark --
#pragma mark REQUEST CALLBACK

- (void)postFinished:(ASIHTTPRequest *)request
{
	
}

- (void)postFailed:(ASIHTTPRequest *)request
{

}

#pragma mark -- 
#pragma mark DOWNLOAD CALLBACK

- (void)requestFinished:(ASIHTTPRequest *)request
{

}

- (void)requestFailed:(ASIHTTPRequest *)request
{

}

-(void)dealloc
{
	[super dealloc];
}

@end

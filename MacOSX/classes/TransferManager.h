//
//  TransferManager.h
//  DumpsterDrive
//
//  Created by Justin Blinder.
//  Copyright 2011. All rights reserved.
//

/**
 @Class TransferManager:
    Manages data between local file system and server 
*/

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"	

@interface TransferManager : NSObject 
{
	ASINetworkQueue *networkQueue;
}

@property (nonatomic,retain) ASINetworkQueue *networkQueue;

- (void)downloadFile:(NSURL *)url destination:(NSString *)filePath;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)postFinished:(ASIHTTPRequest *)request;
- (void)postFailed:(ASIHTTPRequest *)request;

@end

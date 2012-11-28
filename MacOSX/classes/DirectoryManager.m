//
//  DirectoryManager.m
//  DumpsterDrive
//
//  Created by Justin Blinder on 6/6/11.
//  Copyright 2011. All rights reserved.
//

#import "DirectoryManager.h"


@implementation DirectoryManager

static DirectoryManager *__sharedDirectoryManager = nil;


+ (DirectoryManager *)sharedInstance 
{
	@synchronized(self) 
	{
		if (__sharedDirectoryManager == nil) 
		{
			[[self alloc] init]; 
		}
	}
	return __sharedDirectoryManager;
}

- (id) init
{
	self = [super init];
	if (self != nil) 
	{
	}
	return self;
}


- (id)retain 
{
  return self;
}


- (unsigned)retainCount 
{
  return UINT_MAX;  
}


- (void)release 
{

}

- (id)autorelease 
{
  return self;
}


#pragma mark Singleton utility methods

- (UInt32)getFileSize:(NSString *)filePath
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:NULL];
	[fileManager release];
	UInt32 result = [attrs fileSize];
	result /= 1000;
	return result;
}

- (NSString *)getBundleValueAsString:(NSString *)key
{
	NSString *path=[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:path]; 
	NSString *value= [dict valueForKey:key]; 
	return value;
}

- (NSString *)setBundleValueAsString:(NSString *)key value:(NSString *)val
{
	NSString *path=[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"];
	NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:path]; 
	[dict setValue:val forKey:key];
	[dict writeToFile:path atomically:YES];
}

	
@end

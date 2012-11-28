//
//  DirectoryManager.h
//  DumpsterDrive
//
//  Created by Justin Blinder.
//  Copyright 2011. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface DirectoryManager : NSObject {

}

+ (DirectoryManager *)sharedInstance;
- (UInt32)getFileSize:(NSString *)filePath;
- (NSString *)getBundleValueAsString:(NSString *)key;
- (NSString *)setBundleValueAsString:(NSString *)key value:(NSString *)val;
@end

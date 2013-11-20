//
//  GBSFileWrapper+URL.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <GBSFileWrapper/GBSFileWrapper.h>

typedef NS_OPTIONS(NSUInteger, GBSFileWrapperReadingOptions) {
    GBSFileWrapperReadingImmediate = NSFileWrapperReadingImmediate,
    GBSFileWrapperReadingWithoutMapping = NSFileWrapperReadingWithoutMapping,
};

typedef NS_OPTIONS(NSUInteger, GBSFileWrapperWritingOptions) {
    GBSFileWrapperWritingAtomic = NSDataWritingAtomic,
    GBSFileWrapperWritingWithoutOverwriting = NSDataWritingWithoutOverwriting,
};

/// Thrown if a GBSFileWrapper's underlying file can't be accessed when the contents property is first used. The exact error can be found in the userInfo's NSUnderlyingErrorKey key.
extern NSString * const GBSFileWrapperContentsInaccessibleException;

@interface GBSFileWrapper (URL)

/// Includes all resource value keys that can be modified.
+ (NSArray*)writableResourceValueKeys;

/// Includes the contents of +writableResourceValueKeys, excluding modification and access dates.
+ (NSArray*)persistentResourceValueKeys;

- (id)initWithURL:(NSURL*)URL options:(GBSFileWrapperReadingOptions)options error:(NSError**)error;

- (BOOL)writeToURL:(NSURL*)URL options:(GBSFileWrapperWritingOptions)options error:(NSError**)error;

@end

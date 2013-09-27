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
    GBSFileWrapperReadingWithoutMapping = NSFileWrapperReadingWithoutMapping
};

typedef NS_OPTIONS(NSUInteger, GBSFileWrapperWritingOptions) {
    GBSFileWrapperWritingAtomic = NSFileWrapperWritingAtomic,
    
};

@interface GBSFileWrapper (URL)

- (id)initWithURL:(NSURL*)URL options:(GBSFileWrapperReadingOptions)options error:(NSError**)error;

- (BOOL)writeToURL:(NSURL*)URL options:(GBSFileWrapperWritingOptions)options error:(NSError**)error;

@end

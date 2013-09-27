//
//  GBSFileWrapper+URL.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSFileWrapper+URL.h"
#import "GBSFileWrapper+NSFileWrapper.h"

// We're gonna be ridiculously lazy and lean on NSFileWrapper for this.

@implementation GBSFileWrapper (URL)

- (id)initWithURL:(NSURL *)URL options:(GBSFileWrapperReadingOptions)options error:(NSError *__autoreleasing *)error {
    NSFileWrapper * wrapper = [[NSFileWrapper alloc] initWithURL:URL options:(NSFileWrapperReadingOptions)options error:error];
    return [self initWithNSFileWrapper:wrapper];
}

- (BOOL)writeToURL:(NSURL *)URL options:(GBSFileWrapperWritingOptions)options error:(NSError *__autoreleasing *)error {
    NSFileWrapper * wrapper = [self NSFileWrapper];
    return [wrapper writeToURL:URL options:(NSFileWrapperWritingOptions)options originalContentsURL:nil error:error];
}

@end

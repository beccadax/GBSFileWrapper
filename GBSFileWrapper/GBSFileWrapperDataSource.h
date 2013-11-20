//
//  GBSFileWrapperDataSource.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GBSFileWrapperDefines.h"

@protocol GBSFileWrapperDataSource <NSObject>

- (GBSFileWrapperType)typeForFileWrapper:(GBSFileWrapper*)fileWrapper;

- (NSData*)regularFileContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;
- (NSURL*)symbolicLinkContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;
- (NSDictionary*)directoryContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;

/// Returns a copy of the data source that can be independently mutated.
- (id <GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper*)fileWrapper;

- (void)setNilContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;
- (void)setRegularFileContents:(NSData*)contents forFileWrapper:(GBSFileWrapper*)fileWrapper;
- (void)setSymbolicLinkContents:(NSURL*)contents forFileWrapper:(GBSFileWrapper*)fileWrapper;

/// Called before calling -addDirectoryContents: or -removeAllDirectoryContents. If the data source does not already represent a directory, it should turn itself into an empty directory.
- (void)makeDirectoryContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;
/// Adds, updates, or removes child file wrappers. A null value indicates that the corresponding key should be removed.
- (void)addDirectoryContents:(NSDictionary*)dictionaryOfNamesAndFileWrappersOrNulls;
/// Removes all child file wrappers from the directory.
- (void)removeAllDirectoryContents;

@end

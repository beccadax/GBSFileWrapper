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

- (id <GBSFileWrapperDataSource>)copyFromFileWrapper:(GBSFileWrapper*)fileWrapper;

- (void)setNilContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;
- (void)setRegularFileContents:(NSData*)contents forFileWrapper:(GBSFileWrapper*)fileWrapper;
- (void)setSymbolicLinkContents:(NSURL*)contents forFileWrapper:(GBSFileWrapper*)fileWrapper;

- (void)makeDirectoryContentsForFileWrapper:(GBSFileWrapper*)fileWrapper;
- (void)addDirectoryContents:(NSDictionary*)dictionaryOfNamesAndFileWrappersOrNulls;
- (void)removeAllDirectoryContents;

@end

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

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys error:(NSError **)error;

@end

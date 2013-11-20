//
//  NSObject+GBSFileWrapperContent.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBSFileWrapperDefines.h"
#import "GBSFileWrapperDataSource.h"

// This protocol is mostly used for type safety. Do not attempt to apply it to your own data types.
@protocol GBSFileWrapperContents <NSObject>

- (GBSFileWrapperType)typeForFileWrapper:(GBSFileWrapper*)fileWrapper;

@end

// Used for regular files
@interface NSData (GBSFileWrapperContents) <GBSFileWrapperContents> @end

// Used for directories
@interface NSDictionary (GBSFileWrapperContents) <GBSFileWrapperContents> @end

// Used for symbolic links
@interface NSURL (GBSFileWrapperContents) <GBSFileWrapperContents> @end

// You can specify a dictionary of resource values as a resource value data source
@interface NSDictionary (GBSFileWrapperResourceValues) <GBSFileWrapperResourceValues> @end

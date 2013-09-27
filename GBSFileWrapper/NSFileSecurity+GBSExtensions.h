//
//  NSFileSecurity+GBSExtensions.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileSecurity (GBSExtensions)

- (id)initWithPOSIXMode:(mode_t)mode;
- (id)initWithPOSIXMode:(mode_t)mode owner:(uid_t)owner group:(gid_t)group;

- (CFFileSecurityRef)CFFileSecurity NS_RETURNS_INNER_POINTER;

- (BOOL)getPOSIXMode:(mode_t*)mode;
- (BOOL)setPOSIXMode:(mode_t)mode;
- (BOOL)clearPOSIXMode;

- (BOOL)getPOSIXOwner:(uid_t*)user;
- (BOOL)setPOSIXOwner:(uid_t)user;
- (BOOL)clearPOSIXOwner;

- (BOOL)getPOSIXGroup:(gid_t*)group;
- (BOOL)setPOSIXGroup:(gid_t)group;
- (BOOL)clearPOSIXGroup;

- (BOOL)getAccessControlList:(acl_t*)acl;   // You're responsible for acl_free()ing this later!
- (BOOL)setAccessControlList:(acl_t)acl;
- (BOOL)clearAccessControlList;

@end

//
//  NSFileSecurity+GBSExtensions.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "NSFileSecurity+GBSExtensions.h"

@implementation NSFileSecurity (GBSExtensions)

- (id)initWithPOSIXMode:(mode_t)mode {
    if((self = [self init])) {
        if(![self setPOSIXMode:mode]) {
            return nil;
        }
    }
    return self;
}

- (id)initWithPOSIXMode:(mode_t)mode owner:(uid_t)owner group:(gid_t)group {
    if((self = [self init])) {
        if(![self setPOSIXMode:mode]) {
            return nil;
        }
        if(![self setPOSIXOwner:owner]) {
            return nil;
        }
        if(![self setPOSIXGroup:group]) {
            return nil;
        }
    }
    return self;
}

- (CFFileSecurityRef)CFFileSecurity {
    return (__bridge CFFileSecurityRef)self;
}

#define GBSFileSecurityAccessors(selectorName, functionName, type) \
- (BOOL)get##selectorName:(type*)value { \
    return CFFileSecurityGet##functionName([self CFFileSecurity], value); \
} \
\
- (BOOL)set##selectorName:(type)value { \
    return CFFileSecuritySet##functionName([self CFFileSecurity], value); \
} \
\
- (BOOL)clear##selectorName { \
    return CFFileSecurityClearProperties([self CFFileSecurity], kCFFileSecurityClear##functionName); \
}

GBSFileSecurityAccessors(POSIXMode, Mode, mode_t)
GBSFileSecurityAccessors(POSIXOwner, Owner, uid_t)
GBSFileSecurityAccessors(POSIXGroup, Group, gid_t)

- (BOOL)getAccessControlList:(acl_t *)value {
    return CFFileSecurityCopyAccessControlList([self CFFileSecurity], value);
}

- (BOOL)setAccessControlList:(acl_t)value { \
    return CFFileSecuritySetAccessControlList([self CFFileSecurity], value);
}

- (BOOL)clearAccessControlList {
    return CFFileSecurityClearProperties([self CFFileSecurity], kCFFileSecurityClearAccessControlList);
}

@end

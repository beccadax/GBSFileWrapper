//
//  GBSFileWrapper+NSFileWrapper.h
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <GBSFileWrapper/GBSFileWrapper.h>

@interface GBSFileWrapper (NSFileWrapper)

- (id)initWithNSFileWrapper:(NSFileWrapper*)nsFileWrapper;

- (NSFileWrapper*)NSFileWrapper;

@end

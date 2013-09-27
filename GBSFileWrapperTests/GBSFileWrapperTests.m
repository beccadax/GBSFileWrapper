//
//  GBSFileWrapperTests.m
//  GBSFileWrapperTests
//
//  Created by Brent Royal-Gordon on 9/26/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBSFileWrapper.h"

@interface GBSFileWrapperTests : XCTestCase

@end

@implementation GBSFileWrapperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSData * data = [@"example" dataUsingEncoding:NSUTF8StringEncoding];
        
    GBSFileWrapper * wrapper = [[GBSFileWrapper alloc] initWithContents:data resourceValues:@{ NSURLFileSecurityKey: [[NSFileSecurity alloc] initWithPOSIXMode:0644] }];
    
    XCTAssertEqual(wrapper.type, GBSFileWrapperTypeRegularFile, @"GBSFileWrapper with NSData contents is a regualr file");
    
    XCTAssertEqualObjects(wrapper.contents, data, @"GBSFileWrapper preserves contents correctly");
    
    NSFileSecurity * security;
    XCTAssertTrue([wrapper getResourceValue:&security forKey:NSURLFileSecurityKey error:NULL], @"Fetched security object successfully");
    XCTAssertNotNil(wrapper, @"Actually got a security object");
    
    mode_t mode;
    XCTAssertTrue([security getPOSIXMode:&mode], @"Can get POSIX mode");
    XCTAssertEqual(mode, (mode_t)0644, @"POSIX mode is correct");
}

@end

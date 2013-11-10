//
//  GBSFileWrapperURL.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/9/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GBSFileWrapper.h"

@interface GBSFileWrapperURL : XCTestCase

@property (strong) GBSFileWrapper * colorSync;

@end

@implementation GBSFileWrapperURL

- (void)setUp
{
    [super setUp];
    
    NSError * error;
    self.colorSync = [[GBSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:@"/Library/ColorSync"] options:0 error:&error];
    if(!self.colorSync) {
        XCTFail(@"Couldn't get ColorSync folder: %@", error);
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testColorSync {
    XCTAssertNotNil(self.colorSync, @"Constructed a file wrapper form ColorSync dir");
    XCTAssertEqual(self.colorSync.type, GBSFileWrapperTypeDirectory, @"ColorSync dir is indeed a directory");
    XCTAssertTrue([self.colorSync.contents isKindOfClass:NSDictionary.class], @"ColorSync dir has dictionary contents");
}

- (void)testScripts {
    GBSFileWrapper * scripts = self.colorSync.contents[@"Scripts"];
    
    XCTAssertNotNil(scripts, @"ColorSync has a Scripts symlink");
    XCTAssertEqual(scripts.type, GBSFileWrapperTypeSymbolicLink, @"Which is a symbolic link");
    XCTAssertTrue([scripts.contents isKindOfClass:NSURL.class], @"Contents are an NSURL");
}

- (void)testProfiles {
    GBSFileWrapper * profiles = self.colorSync.contents[@"Profiles"];
    
    XCTAssertNotNil(profiles, @"Has a Profiles directory");
    XCTAssertEqual(profiles.type, GBSFileWrapperTypeDirectory, @"And Profiles directory really is a directory");
}

- (void)testProfilesBlackAndWhite {
    GBSFileWrapper * profiles = self.colorSync.contents[@"Profiles"];
    GBSFileWrapper * blackAndWhite = profiles.contents[@"Black & White.icc"];
    
    XCTAssertNotNil(blackAndWhite, @"Profiles has a Black & White profile");
    XCTAssertEqual(blackAndWhite.type, GBSFileWrapperTypeRegularFile, @"Which is a regular file");
    XCTAssertTrue([blackAndWhite.contents isKindOfClass:NSData.class], @"Contents are an NSData");
}

@end

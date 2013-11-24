//
//  GBSMutableFileWrapper.m
//  GBSFileWrapper
//
//  Created by Brent Royal-Gordon on 11/9/13.
//  Copyright (c) 2013 Groundbreaking Software. All rights reserved.
//

#import "GBSMutableFileWrapper.h"
#import "NSDictionary+subdictionaryWithKeys.h"

@implementation GBSMutableFileWrapper {
    NSMutableDictionary * _changedResourceValues;
}

- (id)initWithDataSource:(id<GBSFileWrapperDataSource>)dataSource resourceValues:(id<GBSFileWrapperResourceValues>)resourceValueDataSource {
    if((self = [super initWithDataSource:dataSource resourceValues:resourceValueDataSource])) {
        _changedResourceValues = [NSMutableDictionary new];
    }
    return self;
}

- (void)setContents:(id)contents {
    switch ([contents typeForFileWrapper:self]) {
        case GBSFileWrapperTypeNil:
            [self.dataSource setNilContentsForFileWrapper:self];
            break;
            
        case GBSFileWrapperTypeRegularFile:
            [self.dataSource setRegularFileContents:[contents copy] forFileWrapper:self];
            break;
            
        case GBSFileWrapperTypeSymbolicLink:
            [self.dataSource setSymbolicLinkContents:contents forFileWrapper:self];
            break;
            
        case GBSFileWrapperTypeDirectory:
            [self.dataSource makeDirectoryContentsForFileWrapper:self];
            [self.dataSource removeAllDirectoryContents];
            [self.dataSource addDirectoryContents:contents];
            break;
    }
}

- (void)setContentsChildFileWrapper:(GBSFileWrapper *)childWrapper forName:(NSString *)name {
    [self.dataSource makeDirectoryContentsForFileWrapper:self];
    [self.dataSource addDirectoryContents:@{ name: childWrapper ?: [NSNull null] }];
}

- (NSString*)addContentsChildFileWrapper:(GBSFileWrapper *)childWrapper forPreferredName:(NSString *)preferredName {
    NSParameterAssert(childWrapper);
    
    NSString * name = preferredName;
    
    if(self.type == GBSFileWrapperTypeDirectory) {
        NSUInteger number = 2;
        while (self.contents[name]) {
            name = [NSString stringWithFormat:@"%@ %lu.%@", preferredName.stringByDeletingPathExtension, (unsigned long)number++, preferredName.pathExtension];
        }
    }
    
    [self setContentsChildFileWrapper:childWrapper forName:name];
    
    return name;
}

+ (NSArray*)allResourceValueKeys {
    static NSArray * singleton;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        singleton = @[ NSURLNameKey, NSURLLocalizedNameKey, NSURLIsRegularFileKey, NSURLIsDirectoryKey, NSURLIsSymbolicLinkKey, NSURLIsVolumeKey, NSURLIsPackageKey, NSURLIsSystemImmutableKey, NSURLIsUserImmutableKey, NSURLIsHiddenKey, NSURLHasHiddenExtensionKey, NSURLCreationDateKey, NSURLContentAccessDateKey, NSURLContentModificationDateKey, NSURLAttributeModificationDateKey, NSURLLinkCountKey, NSURLParentDirectoryURLKey, NSURLVolumeURLKey, NSURLTypeIdentifierKey, NSURLLocalizedTypeDescriptionKey, NSURLLabelNumberKey, NSURLLabelColorKey, NSURLLocalizedLabelKey, NSURLEffectiveIconKey, NSURLCustomIconKey, NSURLFileResourceIdentifierKey, NSURLVolumeIdentifierKey, NSURLPreferredIOBlockSizeKey, NSURLIsReadableKey, NSURLIsWritableKey, NSURLIsExecutableKey, NSURLFileSecurityKey, NSURLIsExcludedFromBackupKey, NSURLTagNamesKey, NSURLPathKey, NSURLIsMountTriggerKey, NSURLFileResourceTypeKey, NSURLFileSizeKey, NSURLFileAllocatedSizeKey, NSURLTotalFileSizeKey, NSURLTotalFileAllocatedSizeKey, NSURLIsAliasFileKey, NSURLVolumeLocalizedFormatDescriptionKey, NSURLVolumeTotalCapacityKey, NSURLVolumeAvailableCapacityKey, NSURLVolumeResourceCountKey, NSURLVolumeSupportsPersistentIDsKey, NSURLVolumeSupportsSymbolicLinksKey, NSURLVolumeSupportsHardLinksKey, NSURLVolumeSupportsJournalingKey, NSURLVolumeIsJournalingKey, NSURLVolumeSupportsSparseFilesKey, NSURLVolumeSupportsZeroRunsKey, NSURLVolumeSupportsCaseSensitiveNamesKey, NSURLVolumeSupportsCasePreservedNamesKey, NSURLVolumeSupportsRootDirectoryDatesKey, NSURLVolumeSupportsVolumeSizesKey, NSURLVolumeSupportsRenamingKey, NSURLVolumeSupportsAdvisoryFileLockingKey, NSURLVolumeSupportsExtendedSecurityKey, NSURLVolumeIsBrowsableKey, NSURLVolumeMaximumFileSizeKey, NSURLVolumeIsEjectableKey, NSURLVolumeIsRemovableKey, NSURLVolumeIsInternalKey, NSURLVolumeIsAutomountedKey, NSURLVolumeIsLocalKey, NSURLVolumeIsReadOnlyKey, NSURLVolumeCreationDateKey, NSURLVolumeURLForRemountingKey, NSURLVolumeUUIDStringKey, NSURLVolumeNameKey, NSURLVolumeLocalizedNameKey, NSURLIsUbiquitousItemKey, NSURLUbiquitousItemHasUnresolvedConflictsKey, NSURLUbiquitousItemIsDownloadingKey, NSURLUbiquitousItemIsUploadedKey, NSURLUbiquitousItemIsUploadingKey, NSURLUbiquitousItemDownloadingStatusKey, NSURLUbiquitousItemDownloadingErrorKey, NSURLUbiquitousItemUploadingErrorKey, ];
    });
    
    return singleton;
}

- (NSDictionary*)combinedResourceValues {
    NSMutableDictionary * dict = [[self resourceValuesForKeys:[self.class allResourceValueKeys]] mutableCopy];
    [dict addEntriesFromDictionary:self.changedResourceValues];
    
    return dict;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[GBSFileWrapper alloc] initWithDataSource:[self.dataSource copyFromFileWrapper:self] resourceValues:[self combinedResourceValues]];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[GBSMutableFileWrapper alloc] initWithDataSource:[self.dataSource copyFromFileWrapper:self] resourceValues:[self combinedResourceValues]];
}

- (void)setResourceValue:(id)value forKey:(NSString *)key {
    [self setResourceValues:@{ key: value ?: [NSNull null] }];
}

- (void)setResourceValues:(NSDictionary *)values {
    [(NSMutableDictionary*)self.changedResourceValues addEntriesFromDictionary:values];
}

- (NSDictionary *)resourceValuesForKeys:(NSArray *)keys {
    NSArray * remainingKeys;
    NSMutableDictionary * values = [[self.changedResourceValues subdictionaryWithKeys:keys notFoundKeys:&remainingKeys] mutableCopy];
    
    if(remainingKeys.count) {
        [values addEntriesFromDictionary:[super resourceValuesForKeys:remainingKeys]];
    }
    
    return values;
}

@end

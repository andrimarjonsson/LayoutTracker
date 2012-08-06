//
//  AMAppInfo.m
//  LayoutTracker
//
//  Created by Andri Mar Jónsson on 1/28/12.
//  Copyright (c) 2012 Two Drunk Coders. All rights reserved.
//

#import "AMAppInfo.h"

NSString* const kPathKey = @"kPathKey";
NSString* const kLocalizedNameKey = @"kLocalizedNameKey";
NSString* const kBundleIdentifierKey = @"kBundleIdentifierKey";

@implementation AMAppInfo

@synthesize path = _path;
@synthesize localizedName = _localizedName;
@synthesize bundleIdentifier = _bundleIdentifier;
@synthesize icon = _icon;

#pragma mark - Object lifecycle
- (id)initWithNSRunningApplication:(NSRunningApplication *)application
{
    self = [super init];
    if(self)
    {
        _path = [[[application bundleURL] path] retain];
        _localizedName = [[application localizedName] retain];
        _bundleIdentifier = [[application bundleIdentifier] retain];
        _icon = [[application icon] copy];
        [_icon setSize:NSMakeSize(16.0f, 16.0f)];
    }
    return self;
}

- (id)init
{
    // Search for the currently active application
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    NSUInteger index = [runningApps indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop)
                        {
                            if ([[obj valueForKey:@"isActive"] boolValue] == YES)
                            {
                                *stop = YES;
                                return YES;
                            }
                            return NO;
                        }];
    return [self initWithNSRunningApplication:[runningApps objectAtIndex:index]];
}

- (void)dealloc
{
    [_path release];
    [_localizedName release];
    [_bundleIdentifier release];
    [_icon release];
    [super dealloc];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    if(self = [super init])
    {
        _path = [[decoder decodeObjectForKey:kPathKey] retain];
        _localizedName = [[decoder decodeObjectForKey:kLocalizedNameKey] retain];
        _bundleIdentifier = [[decoder decodeObjectForKey:kBundleIdentifierKey] retain];
        
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        _icon = [[workspace iconForFile:_path] copy];
        [_icon setSize:NSMakeSize(16.0f, 16.0f)];
        
        return self;
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_path forKey:kPathKey];
    [encoder encodeObject:_localizedName forKey:kLocalizedNameKey];
    [encoder encodeObject:_bundleIdentifier forKey:kBundleIdentifierKey];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    // No real copying going on, just add to the retain count
    return [self retain];
}

#pragma mark - Other
- (NSString*)description
{
    return _bundleIdentifier;
}

#pragma mark - Equality and Comparison
- (BOOL)isEqual:(id)object
{
    if(self == object)
    {
        return YES;
    }
    if(!object || ![object isKindOfClass:[self class]])
    {
        return NO;
    }
    
    return [self isEqualToAppInfo:object];
}

- (BOOL) isEqualToAppInfo:(AMAppInfo*)object
{
    if(self == object)
    {
        return YES;
    }
    if(([[object localizedName] isEqualToString:[self localizedName]]) && ([[object path] isEqualToString:[self path]]))
    {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return (NSUInteger) (void *)[AMAppInfo class];
}

@end

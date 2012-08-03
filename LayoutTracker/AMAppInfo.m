//
//  AMAppInfo.m
//  LayoutTracker
//
//  Created by Andri Mar Jónsson on 1/28/12.
//  Copyright (c) 2012 Two Drunk Coders. All rights reserved.
//

#import "AMAppInfo.h"

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
        _path = [[[application executableURL] path] retain];
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
    [_icon release];
    [super dealloc];
}

#pragma mark - Accessors
- (NSString *)localizedName
{
    return _localizedName;
}

- (NSImage *)icon
{
    return _icon;
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

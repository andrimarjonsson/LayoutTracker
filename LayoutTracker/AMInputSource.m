//
//  AMInputSource.m
//  KeyLangSwitch
//
//  Created by Andri Mar Jónsson on 12/26/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//

#import "AMInputSource.h"

@interface AMInputSource (PrivateMethods) 
- (void)baseInit;
@end

@implementation AMInputSource

@synthesize inputSourceRef = _ref;
@synthesize localizedName = _localizedName;
@synthesize icon = _icon;

- (id)init
{
    return [self initWithTISInputSource:TISCopyCurrentKeyboardLayoutInputSource()];
}

- (id)initWithTISInputSource:(TISInputSourceRef)source
{
    self = [super init];
    if (self) {
        _ref = source;
        CFRetain(_ref);
        
    }
    return self;
}

- (void) dealloc;
{
    if (_ref != NULL) 
    {
        CFRelease(_ref);
    }
    [_localizedName release];
    [_icon release];

    [super dealloc];
}

#pragma mark - Accessors

- (NSString*)localizedName
{
    if (_localizedName) 
    {
        return _localizedName;
    }
     _localizedName = [[NSString stringWithString:(NSString*)((CFStringRef)TISGetInputSourceProperty(_ref, kTISPropertyLocalizedName))] retain];
    return _localizedName;
}

- (NSImage*)icon
{
    if (_icon)
    {
        return _icon;
    }
    IconRef iconRef = (IconRef)TISGetInputSourceProperty(_ref, kTISPropertyIconRef);
    _icon = [[NSImage alloc] initWithIconRef:iconRef];
    [_icon setSize:NSMakeSize(16.0, 16.0)];
    return _icon;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    // This is so the object can be used with NSDictionaryController
    // We do not want to really deep copy the object, simply add another
    // retain on the handle.
    CFRetain(_ref);
    return [self retain];
}

#pragma mark - PrivateMethods
- (void)baseInit
{
    //Recursive directory walk
    NSDirectoryEnumerator *de = [[NSFileManager defaultManager] enumeratorAtPath:@"/Applications"];
    NSString *filename;
    while (filename = [de nextObject])
    {
        if ([[filename pathExtension] isEqualToString:@"app"])
        {
            // Add to app list.
        }
    }
}

#pragma mark - ToString
- (NSString*)description
{
    return [self localizedName];
}

@end

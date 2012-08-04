//
//  AMInputSource.m
//  KeyLangSwitch
//
//  Created by Andri Mar Jónsson on 12/26/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//

#import "AMInputSource.h"

static NSCache *inputSourceCache = nil;

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

- (TISInputSourceRef)inputSourceWithID:(NSString*)inputSourceID
{
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        inputSourceCache = [[NSCache alloc] init];
    });
    
    TISInputSourceRef theInputSource = (TISInputSourceRef)[inputSourceCache objectForKey:inputSourceID];
    
    if(theInputSource == NULL)
    {
        //Fill the cache
        
        CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionaryAddValue(dict, kTISPropertyInputSourceCategory, kTISCategoryKeyboardInputSource);
        CFDictionaryAddValue(dict, kTISPropertyInputSourceType, kTISTypeKeyboardLayout);
        
        CFArrayRef inputList = TISCreateInputSourceList(dict, false);
        
        NSUInteger count = CFArrayGetCount(inputList);
        
        for(NSUInteger i = 0; i < count; i++)
        {
            TISInputSourceRef inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(inputList, i);
            
            NSString *currentInputSourceID = TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
            
            [inputSourceCache setObject:(id)inputSource forKey:currentInputSourceID];
            
            if([currentInputSourceID isEqualToString:inputSourceID])
                theInputSource = inputSource;
        }
        
        CFRelease(inputList);
    }    
    
    return theInputSource;
}

- (NSString*)sourceID
{
    if(_ref != NULL)
        return TISGetInputSourceProperty(_ref, kTISPropertyInputSourceID);
    
    return nil;
}

- (id)initWithInputSourceID:(NSString*)inputSourceID
{
    if(self = [super init])
    {
        TISInputSourceRef inputSourceRef = [self inputSourceWithID:inputSourceID];
        
        if(inputSourceRef == NULL)
            return nil;
        
        _ref = inputSourceRef;
        CFRetain(_ref);
        
        return self;
    }
    
    return nil;
}

- (void)dealloc;
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

//
//  AMAppDelegate.m
//  LanguageLock
//
//  Created by Andri Mar Jónsson on 12/30/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//
// TODO: Polish prefs window. <- Ongoing
// TOOD: Editable table to make your own pairings.
// TODO: Have a better icon made.

#import "AMAppDelegate.h"
#import "AMInputSource.h"
#import "AMPreferencesController.h"
#import "AMAppInfo.h"

@interface AMAppDelegate (PrivateMethods)
- (void)activeAppDidChange:(NSNotification*)notitfication;
- (void)systemSelectedInputSourceDidChange:(NSNotification*)notification;
- (void)systemEnabledInputSourcesDidChange:(NSNotification*)notification;
- (void)readInputSources;
@end

@interface AMAppDelegate (ActionHelpers)
- (void)createPrefControllerIfNull;
- (void)forcePrefControllerOnTop;
@end    

@implementation AMAppDelegate

@synthesize menu = _menu;
@synthesize statusItem = _statusItem;
@synthesize activeApp = _activeApp;
@synthesize disabled = _disabled;
@synthesize preferenceController = _preferenceController;

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Init the structures used
        _applicationInputSourceMap = [[NSMutableDictionary alloc] init];
        _inputSources = [[NSMutableDictionary alloc] init];
        // Get enabled layouts in the system
        [self readInputSources];
        // Get the default one, I know init will do the same but I like to be explicit
        // in what I'm trying to achieve.
        _defaultInputSource = [[AMInputSource alloc] initWithTISInputSource:TISCopyCurrentKeyboardLayoutInputSource()];
        _activeApp = [[AMAppInfo alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_inputSources release];
    [_applicationInputSourceMap release];
    [_defaultInputSource release];
    [_statusItem release];
    [_menuIcon release];
    [_altMenuIcon release];
    [_preferenceController release];
    [_activeApp release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self 
                                                           selector:@selector(activeAppDidChange:) 
                                                               name:NSWorkspaceDidActivateApplicationNotification
                                                             object:nil];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self 
                                                        selector:@selector(systemSelectedInputSourceDidChange:) 
                                                            name:(NSString*)kTISNotifySelectedKeyboardInputSourceChanged
                                                          object:nil 
                                              suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self 
                                                        selector:@selector(systemEnabledInputSourcesDidChange:) 
                                                            name:(NSString*)kTISNotifyEnabledKeyboardInputSourcesChanged
                                                          object:nil 
                                              suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    // Reset to input source during startup
    TISSelectInputSource([_defaultInputSource inputSourceRef]);
}

- (void)awakeFromNib
{
    // Init UI
    _statusItem = [[[NSStatusBar systemStatusBar] 
                   statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setHighlightMode:YES]; 
    [_statusItem setEnabled:YES];
    [_statusItem setToolTip:@"LanguageLock 1.0"];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"keyboard" ofType:@"png"];
    NSString *altPath = [bundle pathForResource:@"keyboardAlt" ofType:@"png"];
    _menuIcon = [[NSImage alloc] initWithContentsOfFile:path];
    _altMenuIcon = [[NSImage alloc] initWithContentsOfFile:altPath];
    [_statusItem setImage:_menuIcon];
    [_statusItem setAlternateImage:_altMenuIcon];
    [_statusItem setMenu:_menu];
}

#pragma mark - PrivateMethods

- (void)activeAppDidChange:(NSNotification *)notification
{
    // Update the active app
    AMAppInfo *app = [[AMAppInfo alloc] initWithNSRunningApplication:[[notification userInfo] objectForKey:NSWorkspaceApplicationKey]];
    self.activeApp = app;
    [app release];
    
    // See if we need to update the keyboard layout
    if(!_disabled) 
    {
        //NSString* appName = [_activeApp localizedName];
        AMInputSource* inputSource = [_applicationInputSourceMap objectForKey:_activeApp];
        if(inputSource != nil) 
        {
            TISSelectInputSource([inputSource inputSourceRef]);
        } 
        else 
        {
            TISSelectInputSource([_defaultInputSource inputSourceRef]);
        }
    }
}

- (void)systemSelectedInputSourceDidChange:(NSNotification*)notification
{
    if (!_disabled) 
    {
        AMInputSource *currentInputSource = [[AMInputSource alloc] initWithTISInputSource:TISCopyCurrentKeyboardLayoutInputSource()];
        [_applicationInputSourceMap setObject:currentInputSource forKey:_activeApp];
        [currentInputSource release];
    }
}

- (void)systemEnabledInputSourcesDidChange:(NSNotification*)notification
{
    [self readInputSources];
}

- (void)readInputSources
{
    // Clear the dictionary
    [_inputSources removeAllObjects];
    
    // Refill it
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, 
                                                            2, 
                                                            &kCFTypeDictionaryKeyCallBacks,
                                                            &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(dict, kTISPropertyInputSourceCategory, kTISCategoryKeyboardInputSource);
    CFDictionaryAddValue(dict, kTISPropertyInputSourceType, kTISTypeKeyboardLayout);
    
    
    CFArrayRef inputList = TISCreateInputSourceList(dict, false);
    long inputListSize = CFArrayGetCount(inputList);
    
    for (int i = 0; i < inputListSize; ++i) 
    {
        TISInputSourceRef inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(inputList, i);
        AMInputSource *tmpSrc = [[AMInputSource alloc] initWithTISInputSource:inputSource];
        [_inputSources setObject:tmpSrc forKey:[tmpSrc localizedName]];
        [tmpSrc release];
    }
    
    // Cleanup
    CFRelease(dict);
    CFRelease(inputList);
}

#pragma mark - Actions
- (IBAction)showPreferences:(id)sender
{
    [self createPrefControllerIfNull];

    // TODO: Better way to represent this than magic constants.
    [self.preferenceController setCurrentViewTag:0];
    
    [self forcePrefControllerOnTop];
}

- (IBAction)showAbout:(id)sender
{
    [self createPrefControllerIfNull];
    
    // TODO: Better way to represent this than magic constants.
    [self.preferenceController setCurrentViewTag:1];
    
    [self forcePrefControllerOnTop];
}

#pragma mark - ActionHelpers
- (void)createPrefControllerIfNull
{
    if (!self.preferenceController) 
    {
        self.preferenceController = [[AMPreferencesController alloc ] initWithInputSourceMap:_applicationInputSourceMap];
    }
    
    // Force a reload of the table in the general section.
    // TODO: Isn't there a callback that always gets called when showWindow
    // succeeds.
    [self.preferenceController.tableView reloadData];
}
- (void)forcePrefControllerOnTop
{
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferenceController showWindow:self];
    [self.preferenceController.window makeKeyAndOrderFront:self];
}


@end

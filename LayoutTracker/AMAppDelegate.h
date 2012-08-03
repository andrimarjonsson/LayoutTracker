//
//  AMAppDelegate.h
//  LanguageLock
//
//  Created by Andri Mar Jónsson on 12/30/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AMInputSource;
@class AMPreferencesController;
@class AMAppInfo;

@interface AMAppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableDictionary *_inputSources;
    NSMutableDictionary *_applicationInputSourceMap;
    AMInputSource *_defaultInputSource;
    NSImage *_menuIcon;
    NSImage *_altMenuIcon;
    
    // Public poperties
    IBOutlet NSMenu *_menu;
    NSStatusItem * _statusItem;
    AMAppInfo *_activeApp;
    BOOL _disabled;
    AMPreferencesController *_preferenceController;
    
}

@property (assign) IBOutlet NSMenu *menu;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) AMAppInfo *activeApp;
@property (nonatomic, retain) AMPreferencesController *preferenceController;
@property (nonatomic, assign, getter = isDisabled) BOOL disabled;

- (IBAction)showPreferences:(id)sender;
- (IBAction)showAbout:(id)sender;

@end

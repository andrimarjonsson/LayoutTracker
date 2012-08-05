//
//  AMPreferencesController.h
//  LanguageLock
//
//  Created by Andri Mar Jónsson on 12/31/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMPreferencesController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource, NSToolbarDelegate>
{
    NSTableView *_tableView;
    NSButton *_startOnLogin;
    NSMutableDictionary *_applicationInputSourceMap;
    NSInteger _currentViewTag;

    IBOutlet NSToolbar* toolBar;
    IBOutlet NSView* generalView;
    IBOutlet NSView* aboutView;
}

- (id)initWithInputSourceMap:(NSMutableDictionary*)inputSourceMap;

@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSButton *startOnLogin;
@property (assign) NSInteger currentViewTag;

- (IBAction)toggleStartOnLogin:(id)sender;
- (IBAction)switchSubview:(id)sender;

@end

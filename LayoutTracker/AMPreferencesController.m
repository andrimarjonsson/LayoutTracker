//
//  AMPreferencesController.m
//  LanguageLock
//
//  Created by Andri Mar Jónsson on 12/31/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//

#import "AMPreferencesController.h"
#import "LaunchAtLoginController.h"
#import "AMInputSource.h"
#import "AMAppInfo.h"

@implementation AMPreferencesController

@synthesize tableView = _tableView;
@synthesize startOnLogin = _startOnLogin;
@synthesize currentViewTag = _currentViewTag;

- (id)initWithInputSourceMap:(NSMutableDictionary*)inputSources
{
    self = [super initWithWindowNibName:@"Preferences"];
    if(self)
    {
        _applicationInputSourceMap = [inputSources retain];
        _currentViewTag = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [_applicationInputSourceMap release];
    [super dealloc];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [_startOnLogin setState:launch];
    [launchController release];
}

- (void)awakeFromNib
{
    NSView *startView = [self viewFromTag:_currentViewTag];
    [self.window setContentSize:[startView frame].size];
    [[self.window contentView] addSubview:startView];
    [toolBar setSelectedItemIdentifier:[self identifierFromTag:_currentViewTag]];
    [self.window center];
}

#pragma mark - NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSInteger count = 0;
    if(_applicationInputSourceMap)
    {
        count = [_applicationInputSourceMap count];
    }
    return count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id returnVal = nil;
    NSArray* keys = [_applicationInputSourceMap allKeys];
    
    if([[tableColumn identifier] isEqualToString:@"Application"])
    {
        //returnVal = [keys objectAtIndex:row];
        AMAppInfo* appInfo = [keys objectAtIndex:row];
        
        NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
        [(NSCell *) [attachment attachmentCell] setImage:[appInfo icon]];
        
        NSMutableAttributedString *aString = [[[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy] autorelease];
        [[aString mutableString] appendFormat:@" %@", [appInfo localizedName]];
        // Adjust vertical alignment so that image and text are flush.
        [aString addAttribute:NSBaselineOffsetAttributeName  value:[NSNumber numberWithFloat: -2.5] range:NSMakeRange(0, 1)];
        
        returnVal = aString;
    }
    
    if([[tableColumn identifier] isEqualToString:@"Layout"])
    {
        AMInputSource *inputSource = [_applicationInputSourceMap objectForKey:[keys objectAtIndex:row]];
        NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
        [(NSCell *) [attachment attachmentCell] setImage:[inputSource icon]];
        
        NSMutableAttributedString *aString = [[[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy] autorelease];
        [[aString mutableString] appendFormat:@" %@", [inputSource localizedName]];
        // Adjust vertical alignment so that image and text are flush.
        [aString addAttribute:NSBaselineOffsetAttributeName  value:[NSNumber numberWithFloat: -2.5] range:NSMakeRange(0, 1)];
        
        returnVal = aString;
    }
    
    return returnVal;
}

#pragma mark - Actions

- (IBAction)toggleStartOnLogin:(id)sender 
{
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [_startOnLogin state];
    [launchController setLaunchAtLogin:launch];
    [launchController release];
}

- (IBAction)switchSubview:(id)sender
{
    NSInteger buttonTag = [sender tag];
    [self switchSubviewHelper:buttonTag];
    return;
}

#pragma mark - Utilities
- (void)switchSubviewHelper:(NSInteger)tag
{
    NSView* selectedView = [self viewFromTag:tag];
    NSRect selectedFrame = [self calculateNewFrame:selectedView];
    NSView* prevView = [self viewFromTag:_currentViewTag];
    _currentViewTag = tag;
    
    //Perform the switch
    [NSAnimationContext beginGrouping];
    
    [[NSAnimationContext currentContext] setDuration:0.1F];
    [[[self.window contentView] animator] replaceSubview:prevView with:selectedView];
    [[self.window animator] setFrame:selectedFrame display:YES];
    
    [NSAnimationContext endGrouping];
}

- (NSView*)viewFromTag:(NSInteger)tag
{
    switch(tag)
    {
        case 0:
            return generalView;
        case 1:
            return aboutView;
        default:
            return generalView;
    }
}

- (NSString*)identifierFromTag:(NSInteger)tag
{
    switch(tag)
    {
        case 0:
            return @"General";
        case 1:
            return @"About";
        default:
            return @"General";
    }
}

- (NSRect)calculateNewFrame:(NSView*)toView
{
    NSRect returnVal = [self.window frame];
    NSSize newSize = [self.window frameRectForContentRect:[toView frame]].size;
    returnVal.size = newSize;
    returnVal.origin.y -= (returnVal.size.height - [self.window frame].size.height);
    return returnVal;
}

@end

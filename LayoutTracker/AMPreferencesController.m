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

@interface AMPreferencesController(Helpers)
- (NSMutableAttributedString*)fillCell:(id)data;
- (void)switchSubviewHelper:(NSInteger)tag;
- (NSView*)viewFromTag:(NSInteger)tag;
- (NSString*)identifierFromTag:(NSInteger)tag;
- (NSRect)calculateNewFrame:(NSView*)toView;
@end

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
        AMAppInfo* appInfo = [keys objectAtIndex:row];
        
        returnVal = [self fillCell:appInfo];
    }
    
    if([[tableColumn identifier] isEqualToString:@"Layout"])
    {
        NSString *inputSourceID = [_applicationInputSourceMap objectForKey:[keys objectAtIndex:row]];
        
        AMInputSource *inputSource = [[AMInputSource alloc] initWithInputSourceID:inputSourceID];
        
        returnVal = [self fillCell:inputSource];
        
        [inputSource release];
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

#pragma mark - Helpers

- (NSMutableAttributedString*)fillCell:(id)data
{
    NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
    [(NSCell *) [attachment attachmentCell] setImage:[data icon]];
    
    NSMutableAttributedString *aString = [[[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy] autorelease];
    [[aString mutableString] appendFormat:@" %@", [data localizedName]];
    // Adjust vertical alignment so that image and text are flush.
    [aString addAttribute:NSBaselineOffsetAttributeName  value:[NSNumber numberWithFloat: -2.5] range:NSMakeRange(0, 1)];
    
    return aString;
}

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

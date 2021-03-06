//
//  AMAppInfo.h
//  LayoutTracker
//
//  Created by Andri Mar Jónsson on 1/28/12.
//  Copyright (c) 2012 Two Drunk Coders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMAppInfo : NSObject <NSCopying, NSCoding>
{
    NSString *_path;
    NSString *_localizedName;
    NSString *_bundleIdentifier;
    NSImage *_icon;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) NSString *bundleIdentifier;

- (id)init;
- (id)initWithNSRunningApplication:(NSRunningApplication*)application;
- (BOOL)isEqualToAppInfo:(AMAppInfo*)object;

@end

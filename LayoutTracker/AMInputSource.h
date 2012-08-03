//
//  AMInputSource.h
//  LanguageLock
//
//  Created by Andri Mar Jónsson on 12/26/11.
//  Copyright (c) 2011 Two Drunk Coders. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMInputSource : NSObject <NSCopying>
{
    TISInputSourceRef _ref;
    NSImage *_icon;
    NSString *_localizedName;
}

@property (nonatomic, readonly) NSString *localizedName;
@property (nonatomic, readonly) NSImage *icon;
@property (nonatomic, readonly) TISInputSourceRef inputSourceRef;

- (id)init;
- (id)initWithTISInputSource:(TISInputSourceRef)source;
- (void) dealloc;
@end

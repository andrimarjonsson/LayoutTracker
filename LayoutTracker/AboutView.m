//
//  AboutView.m
//  LayoutTracker
//
//  Created by Andri Mar Jónsson on 7/28/12.
//  Copyright (c) 2012 Two Drunk Coders. All rights reserved.
//

#import "AboutView.h"

@implementation AboutView

- (void)awakeFromNib
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"];
    NSData *rtfData = [NSData dataWithContentsOfFile:path];
    if(rtfData) 
    {
        NSAttributedString *rtfString = [[NSAttributedString alloc] initWithRTF:rtfData documentAttributes:NULL];
        [[textView textStorage] setAttributedString:rtfString];
        [rtfString release];
    }
    //Error reporting...
}

@end

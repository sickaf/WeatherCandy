//
//  WCFrontScrollView.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/4/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCFrontScrollView.h"

@implementation WCFrontScrollView

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesCancelled:touches withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.superview touchesEnded:touches withEvent:event];
    // Pass to parent
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end

//
//  GradientView.m
//  AssetGrid
//
//  Created by Joe Andolina on 10/18/12.
//
//

#import <QuartzCore/QuartzCore.h>
#import "WCAlphaGradientView.h"
#import "WCConstants.h"

@implementation WCAlphaGradientView

- (void)awakeFromNib
{
	self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 0.8, 1.0 };
	
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor, (__bridge id) endColor];
	
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
	
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
	CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
	
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextClip(context);
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *startColor = [UIColor clearColor];
	UIColor *endColor = kDefaultGreyColor;
	
	drawLinearGradient(context, rect, startColor.CGColor, endColor.CGColor);
}

@end

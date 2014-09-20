//
//  WCErrorView.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/19/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCErrorView.h"
#import "WCConstants.h"

@implementation WCErrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        UILabel *l = [[UILabel alloc] init];
        l.translatesAutoresizingMaskIntoConstraints = NO;
        l.font = kDefaultFontMedium(18);
        l.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        l.text = @"There was an error retrieving the weather. Please check your internet connection";
        l.numberOfLines = 0;
        l.lineBreakMode = NSLineBreakByWordWrapping;
        l.textAlignment = NSTextAlignmentCenter;
        self.lbl = l;
        [self addSubview:self.lbl];
        
        UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
        butt.translatesAutoresizingMaskIntoConstraints = NO;
        [butt setTitle:@"Retry" forState:UIControlStateNormal];
        [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [butt setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateHighlighted];
        [butt.titleLabel setFont:kDefaultFontMedium(18)];
        self.butt = butt;
        [self addSubview:self.butt];
        
        self.spacer1 = [UIView new];
        self.spacer2 = [UIView new];
        self.spacer1.translatesAutoresizingMaskIntoConstraints = NO;
        self.spacer2.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.spacer1];
        [self addSubview:self.spacer2];
    }
    return self;
}

- (void)updateConstraints
{
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_spacer1(==_spacer2)]-[_lbl]-(20)-[_butt(==44)]-[_spacer2(==_spacer1)]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_lbl, _butt, _spacer1, _spacer2)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_lbl]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lbl)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_butt]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_butt)]];
    
    [super updateConstraints];
}

@end

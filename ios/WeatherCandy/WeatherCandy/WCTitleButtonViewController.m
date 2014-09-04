//
//  WCTitleButtonViewController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCTitleButtonViewController.h"
#import "WCConstants.h"

@interface WCTitleButtonViewController ()

@property (nonatomic, strong) UIButton *titleButton;

@end

@implementation WCTitleButtonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kDefaultGreyColor;

    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    [butt setTitle:_titleButtonText forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    butt.titleLabel.font = kDefaultTitleFont;
    [butt addTarget:self action:@selector(pressedTitle:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = butt;
    _titleButton = butt;
}

- (void)setTitleButtonText:(NSString *)titleButtonText
{
    if (_titleButtonText == titleButtonText) return;
    _titleButtonText = titleButtonText;
    [_titleButton setTitle:_titleButtonText forState:UIControlStateNormal];
}

#pragma mark - Actions

// ovverride this in subclass

- (void)pressedTitle:(id)sender
{
    
}

@end

//
//  WCTitleButtonViewController.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/3/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCTitleButtonViewController.h"
#import "WCConstants.h"
#import "WCTitleButton.h"

@interface WCTitleButtonViewController ()

@property (nonatomic, strong) WCTitleButton *titleButton;

@end

@implementation WCTitleButtonViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kDefaultBackgroundColor;

    WCTitleButton *butt = [WCTitleButton new];
    butt.frame = CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    [butt setImage:[UIImage imageNamed:@"up_arrow"] forState:UIControlStateNormal];
    [butt setTitle:_titleButtonText forState:UIControlStateNormal];
    
    butt.titleEdgeInsets = UIEdgeInsetsMake(0, -butt.imageView.frame.size.width - 5, 0, butt.imageView.frame.size.width + 5);
    butt.imageEdgeInsets = UIEdgeInsetsMake(0, butt.titleLabel.frame.size.width, 0, -butt.titleLabel.frame.size.width);
    
    [butt addTarget:self action:@selector(pressedTitle:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = butt;
    _titleButton = butt;
}

#pragma mark - Actions

// override this in subclass

- (void)pressedTitle:(id)sender
{
    
}

@end

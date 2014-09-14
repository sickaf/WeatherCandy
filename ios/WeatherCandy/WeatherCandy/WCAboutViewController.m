//
//  WCAboutViewController.m
//  WeatherCandy
//
//  Created by dtown on 9/12/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCAboutViewController.h"

@interface WCAboutViewController ()

@end

@implementation WCAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"sick.af";
    NSString *fullURL = @"http://sick.af";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.aboutWebView loadRequest:requestObj];
}

@end

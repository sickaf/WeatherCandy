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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"sick.af";
    NSString *fullURL = @"http://sick.af";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.aboutWebView loadRequest:requestObj];}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

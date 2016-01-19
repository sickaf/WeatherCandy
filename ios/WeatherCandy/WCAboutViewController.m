//
//  WCAboutViewController.m
//  WeatherCandy
//
//  Created by dtown on 9/12/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCAboutViewController.h"

@interface WCAboutViewController () {
    UIActivityIndicatorView *_spinner;
}

@end

@implementation WCAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"sick.af";
    NSString *fullURL = @"http://sick.af";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.aboutWebView.delegate = self;
    [self.aboutWebView loadRequest:requestObj];
    
    UIActivityIndicatorView *spin = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spin.hidesWhenStopped = YES;
    _spinner = spin;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spin];
}

#pragma mark - Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_spinner stopAnimating];
}

@end

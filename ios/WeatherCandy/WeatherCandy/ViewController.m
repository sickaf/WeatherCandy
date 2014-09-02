//
//  ViewController.m
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>


@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    testObject[@"foo"] = @"bar";
    [testObject saveInBackground];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)getWeatherCandyDataButton:(id)sender {
    
//    __block NSString *serverResult[] = {};
    
    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
                       withParameters:@{@"cityName": self.cityTextField.text,@"date":self.dateTextField.text}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSString *weatherDataText = [result componentsSeparatedByString:@"IGURL"][0];
                                        self.cityNameLabel.text = [weatherDataText componentsSeparatedByString:@"\n"][0];
                                        self.weatherDataLabel.text = [weatherDataText componentsSeparatedByString:@"\n"][1];
                                        
                                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [result componentsSeparatedByString:@"IGURL"][1]]];
                                        self.igImageView.image = [UIImage imageWithData: imageData];
                                        
                                    }
                                }];
    
}
@end

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
//   stringToReturn =  ""+obj.name + "$"+obj.weather[0].description+"$"+(obj.main.temp-kelvin)+"$"+obj.main.temp_max+"$"+obj.main.temp_min+"$"+obj.IGPhotos[0].IGUrl;

    
    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
                       withParameters:@{@"cityName": self.cityTextField.text,@"date":self.dateTextField.text}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        self.cityNameLabel.text = [weatherDataText componentsSeparatedByString:@"$"][0];
                                        self.weatherDataLabel.text = [weatherDataText componentsSeparatedByString:@"$"][1];
                                        
                                        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [result componentsSeparatedByString:@"IGURL"][1]]];
                                        self.igImageView.image = [UIImage imageWithData: imageData];
                                        
                                    }
                                }];
    
}
@end

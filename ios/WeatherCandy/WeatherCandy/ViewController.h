//
//  ViewController.h
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *weatherDataLabel;
@property (weak, nonatomic) IBOutlet UIImageView *igImageView;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
- (IBAction)getWeatherCandyDataButton:(id)sender;



@end


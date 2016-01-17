//
//  WCChooseCategoryViewController.m
//  WeatherCandy
//
//  Created by dtown on 9/23/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCChooseCategoryViewController.h"
#import "WCSettings.h"
#import "WCConstants.h"
#import <QuartzCore/QuartzCore.h>


@interface WCChooseCategoryViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *chooseGirlsImageView;
@property (strong, nonatomic) IBOutlet UIImageView *chooseGuysImageView;
@property (strong, nonatomic) IBOutlet UIImageView *chooseAnimalsImageView;

- (IBAction)girlButton:(UIButton *)sender;
- (IBAction)guyButton:(UIButton *)sender;
- (IBAction)animalButton:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UIButton *guyButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *girlButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *animalButtonOutlet;

@end

@implementation WCChooseCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)girlButton:(UIButton *)sender {
    [[WCSettings sharedSettings] setHasChosenCategory:YES];
    [[WCSettings sharedSettings] setSelectedImageCategory:0];
    [self notify];
}

- (IBAction)guyButton:(UIButton *)sender {
    [[WCSettings sharedSettings] setHasChosenCategory:YES];
    [[WCSettings sharedSettings] setSelectedImageCategory:1];
    [self notify];
}

- (IBAction)animalButton:(UIButton *)sender {
    [[WCSettings sharedSettings] setHasChosenCategory:YES];
    [[WCSettings sharedSettings] setSelectedImageCategory:2];
    [self notify];
}

#pragma mark - Helpers

- (void)notify
{
    if ([self.delegate respondsToSelector:@selector(userDidChooseCategory)]) {
        [self.delegate userDidChooseCategory];
    }
}

@end

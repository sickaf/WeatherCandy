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
    self.girlButtonOutlet.titleLabel.font = kDefaultFontMedium(50);
    self.guyButtonOutlet.titleLabel.font = kDefaultFontMedium(50);
    self.animalButtonOutlet.titleLabel.font = kDefaultFontMedium(50);
    
}

- (void) viewDidLayoutSubviews
{
    //toss on the gradients
    [self addGradientView:self.chooseGirlsImageView];
    [self addGradientView:self.chooseGuysImageView];
    [self addGradientView:self.chooseAnimalsImageView];
}

- (void)addGradientView:(UIView *)parentView {
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = parentView.bounds;
    UIColor *top = [kDefaultBackgroundColor colorWithAlphaComponent:0.7];
    UIColor *bottom = [kDefaultBackgroundColor colorWithAlphaComponent:0.9];
    gradient.colors = [NSArray arrayWithObjects:(id)[top CGColor], (id)[bottom CGColor], nil];
    [parentView.layer insertSublayer:gradient atIndex:0];
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

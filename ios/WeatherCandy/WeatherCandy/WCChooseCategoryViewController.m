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
    
    [self addGradientToView: self.chooseGirlsImageView];
    [self addGradientToView: self.chooseGuysImageView];
    [self addGradientToView: self.chooseAnimalsImageView];
        
}

- (void)addGradientToView:(UIView *)parentView {
    UIView *view = [[UIView alloc] initWithFrame:parentView.bounds];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    UIColor *top = [kDefaultBackgroundColor colorWithAlphaComponent:0.6];
    UIColor *bottom = [kDefaultBackgroundColor colorWithAlphaComponent:0.8];
    gradient.colors = [NSArray arrayWithObjects:(id)[top CGColor], (id)[bottom CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    [parentView addSubview: view];
}

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

- (IBAction)girlButton:(UIButton *)sender {
    [[WCSettings sharedSettings] setSelectedImageCategory:0];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)guyButton:(UIButton *)sender {
    [[WCSettings sharedSettings] setSelectedImageCategory:1];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)animalButton:(UIButton *)sender {
    [[WCSettings sharedSettings] setSelectedImageCategory:2];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

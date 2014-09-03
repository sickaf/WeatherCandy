//
//  ViewController.m
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCMainViewController.h"
#import "WCCollectionViewCell.h"
#import "WCConstants.h"
#import "AFNetworking.h"
#import "WCSlideDownModalAnimation.h"
#import "WCCity.h"

#import <Parse/Parse.h>

@interface WCMainViewController () {
    NSArray *_imgData;
    NSMutableArray *_imgs;
    UIButton *_navButton;
}

@end

@implementation WCMainViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    self.view.backgroundColor = kDefaultGreyColor;
    
    _imgData = @[@"http://photos-a.ak.instagram.com/hphotos-ak-xpf1/10553999_1447827782154488_388662961_n.jpg",
                 @"http://photos-e.ak.instagram.com/hphotos-ak-xfa1/10012522_259935160847948_1011959515_n.jpg",
                 @"http://photos-d.ak.instagram.com/hphotos-ak-xaf1/10601929_1546280335592507_1297605176_n.jpg",
                 @"http://photos-h.ak.instagram.com/hphotos-ak-xaf1/10661088_579312335512287_864534314_n.jpg",
                 @"http://photos-h.ak.instagram.com/hphotos-ak-xaf1/10661088_579312335512287_864534314_n.jpg"];
    _imgs = [NSMutableArray new];
    
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.alignBottom = YES;
    
    UIButton *butt = [UIButton buttonWithType:UIButtonTypeCustom];
    [butt setTitle:@"Boston" forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [butt setTitleColor:[UIColor colorWithWhite:1 alpha:0.6] forState:UIControlStateHighlighted];
    butt.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22];
    [butt addTarget:self action:@selector(pressedCityName:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setTitleView:butt];
    _navButton = butt;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
}

- (void)getWeatherDataWithCityID:(NSString *)cityID
{
    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
                       withParameters:@{@"cityID": cityID, @"date":@"2014-09-11"}
                                block:^(NSDictionary *result, NSError *error) {
                                    if (!error) {
                                        _imgData = [result[@"IGPhotoSet"] valueForKeyPath:@"IGUrl"];
                                        [self.collectionView reloadData];
                                        
                                        NSNumber *curTemp = result[@"currentWeather"][@"main"][@"temp"];
                                        curTemp = [NSNumber numberWithInt:[curTemp intValue] - 273];
                                        self.mainTempLabel.text = [[curTemp stringValue] substringToIndex:2];
                                        
                                        self.descriptionLabel.text = result[@"currentWeather"][@"weather"][0][@"description"];
                                        
                                        NSNumber *curHigh = result[@"currentWeather"][@"main"][@"temp_max"];
                                        curHigh = [NSNumber numberWithInt:[curHigh intValue] - 273];
                                        self.highTempLabel.text = [[curHigh stringValue] substringToIndex:2];
                                        
                                        NSNumber *curLow = result[@"currentWeather"][@"main"][@"temp_min"];
                                        curLow = [NSNumber numberWithInt:[curLow intValue] - 273];
                                        self.lowTempLabel.text = [[curLow stringValue] substringToIndex:2];
                                    }
                                }];
}

#pragma mark - notifications

- (void)cityChanged:(NSNotification *)note
{
    NSDictionary *info = note.userInfo;
    WCCity *city = info[@"city"];
    [_navButton setTitle:city.name forState:UIControlStateNormal];
    [self getWeatherDataWithCityID:[city.cityID stringValue]];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imgData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.imageView.backgroundColor = [self random];
    cell.imageURL = _imgData[indexPath.row];
    return cell;
}
- (IBAction)pressedCityName:(id)sender
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCity"];

    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - animation delegate

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    WCSlideDownModalAnimation *slide = [WCSlideDownModalAnimation new];
    if (operation == UINavigationControllerOperationPop) {
        slide.presenting = YES;
    }
    return slide;
}

- (UIColor *)random
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
@end

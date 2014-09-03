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
#import "WCSlideBehindModalAnimation.h"
#import "WCNavigationController.h"
#import "WCCity.h"
#import "WCPhoto.h"

#import <Parse/Parse.h>

@interface WCMainViewController () {
    NSArray *_imgData;
}

@end

@implementation WCMainViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    self.view.backgroundColor = kDefaultGreyColor;
    
    _imgData = @[];
    
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.alignBottom = YES;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCity = [ud objectForKey:kLastSelectedCity];
    if (dataRepresentingCity)
    {
        WCCity *lastCity = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCity];
        [self changeToCity:lastCity];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
}

- (void)getWeatherDataWithCityID:(NSString *)cityID
{
    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
                       withParameters:@{@"cityID": cityID, @"date":[NSDate date]}
                                block:^(NSDictionary *result, NSError *error) {
                                    if (!error) {
                                        
                                        NSLog(@"%@", result);
                                        
                                        NSMutableArray *temp = [NSMutableArray new];
                                        for (NSDictionary *dict in result[@"IGPhotoSet"]) {
                                            WCPhoto *newPhoto = [WCPhoto new];
                                            newPhoto.photoURL = dict[@"IGUrl"];
                                            newPhoto.username = dict[@"IGUsername"];
                                            newPhoto.index = dict[@"PhotoNum"];
                                            [temp addObject:newPhoto];
                                        }
                                        
                                        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];

                                        _imgData = [temp sortedArrayUsingDescriptors:@[sortDescriptor]];
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

- (void)openProfileForIndexPath:(NSIndexPath *)indexPath
{
    WCPhoto *p = _imgData[indexPath.row];
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:p.username delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Instagram Profile", nil];
    [as showInView:self.view];
}

- (void)changeToCity:(WCCity *)city
{
    self.titleButtonText = city.name;
    [self getWeatherDataWithCityID:[city.cityID stringValue]];
}

#pragma mark - notifications

- (void)cityChanged:(NSNotification *)note
{
    NSDictionary *info = note.userInfo;
    WCCity *city = info[@"city"];
    [self changeToCity:city];
}

#pragma mark - Actions

- (IBAction)pressedAction:(id)sender
{
    if (self.collectionView.visibleCells.count) {
        NSIndexPath *ind = [self.collectionView indexPathForCell:self.collectionView.visibleCells[0]];
        if ([self collectionView:self.collectionView shouldSelectItemAtIndexPath:ind]) {
            [self openProfileForIndexPath:ind];
        }
    }
}

- (IBAction)pressedSettings:(id)sender
{
    if (!self.presentedViewController) {
        UIStoryboard *st = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [st instantiateViewControllerWithIdentifier:@"Settings"];
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.transitioningDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)pressedTitle:(id)sender
{
    WCTitleButtonViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCity"];
    vc.titleButtonText = self.titleButtonText;
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _imgData.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WCPhoto *photo = _imgData[indexPath.row];
    
    WCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.imageView.backgroundColor = [self random];
    cell.imageURL = photo.photoURL;
    return cell;
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WCPhoto *p = _imgData[indexPath.row];
    return p.username != nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    [self openProfileForIndexPath:indexPath];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *st = [NSString stringWithFormat:@"instagram://user?username=%@", actionSheet.title];
        NSURL *instagramURL = [NSURL URLWithString:st];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            [[UIApplication sharedApplication] openURL:instagramURL];
        }
    }
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

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    WCSlideBehindModalAnimation *slide = [WCSlideBehindModalAnimation new];
    slide.presenting = NO;
    return slide;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    WCSlideBehindModalAnimation *slide = [WCSlideBehindModalAnimation new];
    slide.presenting = YES;
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

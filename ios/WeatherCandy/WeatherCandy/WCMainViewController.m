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
#import "UIImage+ImageEffects.h"
#import "UIView+Snapshot.h"
#import "WCAddCityViewController.h"
#import "WCTempFormatter.h"

#import <Parse/Parse.h>

@interface WCMainViewController () {
    NSArray *_imgData;
    NSDictionary *_weatherData;
    UIImageView *_blurImageView;
}

@property (weak, nonatomic) IBOutlet UIScrollView *outerScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *innerScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *forecastCollectionView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) BOOL loading;

@end

@implementation WCMainViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    _imgData = @[];
    _weatherData = @{};
    
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.alignBottom = YES;
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _spinner.hidesWhenStopped = YES;
    _spinner.center = self.outerScrollView.center;
    [self.view addSubview:_spinner];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCity = [ud objectForKey:kLastSelectedCity];
    if (dataRepresentingCity)
    {
        WCCity *lastCity = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCity];
        [self changeToCity:lastCity];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempUnitToggled:) name:kReloadTempLabelsNotification object:nil];
    
    self.collectionView.backgroundColor = kDefaultGreyColor;
    self.forecastCollectionView.backgroundColor = kDefaultGreyColor;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (void)setLoading:(BOOL)loading
{
    _loading = loading;
    
    if (_loading) {
        [_spinner startAnimating];
        _spinner.hidden = NO;
        self.outerScrollView.alpha = 0;
    }
    else {
        [_spinner stopAnimating];
        [UIView animateWithDuration:0.2 animations:^{
            self.outerScrollView.alpha = 1;
        }];
        [self.collectionView reloadData];
    }
}

#pragma mark - Helpers

- (void)getWeatherDataWithCityID:(NSString *)cityID
{
    
    if (_loading) return;
    
    self.loading = YES;
    
    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
                       withParameters:@{@"cityID": cityID, @"date":[NSDate date]}
                                block:^(NSDictionary *result, NSError *error) {
                                    
                                    self.loading = NO;
                                    
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
                                        
                                        _weatherData = result;
        
                                        [self refreshTempLabels];
                                    }
                                }];
}

- (void)refreshTempLabels
{
    WCTempFormatter *formatter = [WCTempFormatter new];
    
    NSNumber *curTemp = _weatherData[@"currentWeather"][@"main"][@"temp"];
    self.mainTempLabel.text = [formatter formattedStringWithKelvin:[curTemp floatValue]];
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

- (void)tempUnitToggled:(NSNotification *)note
{
    [self refreshTempLabels];
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
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [st instantiateViewControllerWithIdentifier:@"Settings"];
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
    
}

- (void)pressedTitle:(id)sender
{
    
    UIImage *snap = [self.view convertViewToImage];
    UIImage *blurred = [snap applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.3 maskImage:nil];
    
    WCAddCityViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCity"];
    vc.titleButtonText = self.titleButtonText;
    vc.bgImg = blurred;
    
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.collectionView]) {
        return _imgData.count;
    }
    
    return 2;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.collectionView]) {
        WCPhoto *photo = _imgData[indexPath.row];
        
        WCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
        cell.imageURL = photo.photoURL;
        return cell;
    }
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"ForecastCell" forIndexPath:indexPath];
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

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isEqual:self.outerScrollView]) return;
    
    if (scrollView.contentOffset.y >= 0) {
        
        if (!_blurImageView) {
            _blurImageView = [[UIImageView alloc] initWithFrame:self.collectionView.bounds];
            _blurImageView.alpha = 0;
            if (!_blurImageView.image) {
                UIImage *snap = [self.collectionView convertViewToImage];
                UIImage *blurred = [snap applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:0.3] saturationDeltaFactor:1.3 maskImage:nil];
                _blurImageView.image = blurred;
            }
            [[self.collectionView.visibleCells[0] contentView] insertSubview:_blurImageView atIndex:1];
        }
        
        self.innerScrollView.contentOffset = CGPointMake(0, -scrollView.contentOffset.y);
    }
    else {
        
        [_blurImageView removeFromSuperview];
        _blurImageView.image = nil;
        _blurImageView = nil;
        
        self.innerScrollView.contentOffset = scrollView.contentOffset;
        
    }
    
    _blurImageView.alpha = scrollView.contentOffset.y / self.view.bounds.size.height * 5;
}

- (void)viewDidLayoutSubviews
{
    [self.outerScrollView setContentSize:CGSizeMake(320, 650)];
}
@end

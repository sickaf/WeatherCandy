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
#import "WCForecastCollectionViewCell.h"

#import <Parse/Parse.h>

@interface WCMainViewController () {
    NSArray *_imgData;
    NSDictionary *_currentWeatherData;
    NSArray *_forecastData;
    UIImageView *_blurImageView;
    NSDateFormatter *_dateFormatter;
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
    _currentWeatherData = @{};
    
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.alignBottom = YES;
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _spinner.hidesWhenStopped = YES;
    _spinner.center = self.outerScrollView.center;
    [self.view addSubview:_spinner];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_dateFormatter setDateFormat:@"ha"];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCity = [ud objectForKey:kLastSelectedCity];
    if (dataRepresentingCity)
    {
        WCCity *lastCity = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCity];
        [self changeToCity:lastCity];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempUnitToggled:) name:kReloadTempLabelsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:kImageDownloadedNotification object:nil];
    
    self.collectionView.backgroundColor = kDefaultBackgroundColor;
    self.forecastCollectionView.backgroundColor = kDefaultBackgroundColor;
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
                                        
                                        _currentWeatherData = result[@"currentWeather"];
                                        _forecastData = result[@"forecastList"];
        
                                        [self refreshTempLabels];
                                        [self.forecastCollectionView reloadData];
                                    }
                                }];
}

- (void)refreshTempLabels
{
    WCTempFormatter *formatter = [WCTempFormatter new];
    
    NSNumber *curTemp = _currentWeatherData[@"main"][@"temp"];
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

- (UIImage *)blurredImageOfCurrentView
{
    UIImage *snap = [self.view convertViewToImage];
    UIImage *blurred = [snap applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:0.5] saturationDeltaFactor:1.3 maskImage:nil];
    return blurred;
}

- (void)reloadBlurredBackgroundOnPresentedViewController
{
    if (![self.navigationController.topViewController isEqual:self]) {
        WCAddCityViewController *vc = (WCAddCityViewController *)self.navigationController.topViewController;
        vc.bgImg = [self blurredImageOfCurrentView];
    }
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
    [self.forecastCollectionView reloadData];
}

- (void)imageDownloaded:(NSNotification *)note
{
    [self blurCurrentImageWithScrollOffset:self.outerScrollView.contentOffset];
}

#pragma mark - Actions

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
    WCAddCityViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCity"];
    vc.titleButtonText = self.titleButtonText;
    vc.bgImg = [self blurredImageOfCurrentView];
    
    self.navigationController.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [collectionView isEqual:self.forecastCollectionView] ? 2 : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.collectionView]) {
        return _imgData.count;
    }
    
    if (_forecastData.count >= 8) {
        return 4;
    }
    
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.collectionView]) {
        WCPhoto *photo = _imgData[indexPath.row];
        
        WCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
        cell.imageURL = photo.photoURL;
        return cell;
    }
    
    WCForecastCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ForecastCell" forIndexPath:indexPath];
    WCTempFormatter *tf = [WCTempFormatter new];
    
    NSInteger ind = indexPath.row + 4 * indexPath.section;
    
    if (ind < _forecastData.count) {
        NSDictionary *data = _forecastData[indexPath.row + 4 * indexPath.section];
        cell.tempLabel.text = [tf formattedStringWithKelvin:[data[@"main"][@"temp"] floatValue]];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[data[@"dt"] longLongValue]];
        cell.timeLabel.text = [[_dateFormatter stringFromDate:date] lowercaseString];
    }
    else {
        cell.tempLabel.text = @"-";
        cell.timeLabel.text = @"-";
    }
   
    return cell;
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.forecastCollectionView]) return NO;
    
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

- (void)blurCurrentImageWithScrollOffset:(CGPoint)offset
{
    if (self.collectionView.visibleCells.count <= 0) return;
    
    WCCollectionViewCell *currentImageCell = self.collectionView.visibleCells[0];
    UIImage *currentImage = currentImageCell.imageView.image;
    
    if (!currentImage) return;
    
    if (offset.y > 0) {
        if (!_blurImageView) {
            _blurImageView = [[UIImageView alloc] initWithFrame:currentImageCell.contentView.bounds];
            _blurImageView.alpha = 0;
            UIImage *blurred = [currentImage applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:0.3] saturationDeltaFactor:1.3 maskImage:nil];
            _blurImageView.image = blurred;
            [currentImageCell.contentView insertSubview:_blurImageView atIndex:1];
        }
    }
    else {
        [_blurImageView removeFromSuperview];
        _blurImageView.image = nil;
        _blurImageView = nil;
    }
    
    _blurImageView.alpha = offset.y / self.view.bounds.size.height * 5;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isEqual:self.outerScrollView]) return;
    
    CGFloat yOffset = scrollView.contentOffset.y;
    CGFloat upperScrollLimit = 180;
    
    if (yOffset >= 0) {
        self.innerScrollView.contentOffset = CGPointMake(0, -yOffset);
        if (yOffset < upperScrollLimit) {
            self.collectionView.userInteractionEnabled = scrollView.contentOffset.y <= 0;
        }
        else {
            self.innerScrollView.contentOffset = CGPointMake(0, -upperScrollLimit);
        }
    }
    else {
        self.innerScrollView.contentOffset = scrollView.contentOffset;
    }
    
    [self blurCurrentImageWithScrollOffset:scrollView.contentOffset];
}

@end

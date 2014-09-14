//
//  ViewController.m
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Parse/Parse.h>

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
#import "UIViewController+BlurredSnapshot.h"
#import "WCForecastWeather.h"
#import "WCSettings.h"


@interface WCMainViewController () {
    NSArray *_imgData;
    NSDictionary *_currentWeatherData;
    NSArray *_forecastData;
    UIImageView *_blurImageView;
    NSDateFormatter *_dateFormatter;
    WCWeather *_currentWeather;
    BOOL _currentLocation;
}

//@property (weak, nonatomic) IBOutlet UIScrollView *outerScrollView;
//@property (weak, nonatomic) IBOutlet UIScrollView *innerScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *forecastCollectionView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL gettingData;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation WCMainViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Status bar
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    // Setup
    
    _imgData = @[];
    _currentWeatherData = @{};
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempUnitToggled:) name:kReloadTempLabelsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDownloaded:) name:kImageDownloadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_dateFormatter setDateFormat:@"ha"];
    [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    // UI
    
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _spinner.hidesWhenStopped = YES;
    _spinner.center = self.view.center;
    [self.view addSubview:_spinner];
    
    [self.titleButton.titleLabel setFont:kDefaultFontMedium(18)];
    self.mainTempLabel.font = kDefaultFontUltraLight(100);
    self.descriptionLabel.font = kDefaultFontBold(40);
    
    [self changeToBackgroundForType:WCBackgroundTypeBlue];
    
    self.forecastCollectionView.backgroundColor = [UIColor clearColor];
    
    // Switch to current city
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *dataRepresentingCity = [ud objectForKey:kLastSelectedCity];
    if (dataRepresentingCity)
    {
        WCCity *lastCity = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingCity];
        [self changeToCity:lastCity];
    }
    else {
        // No last city saved, update from current location
        [self loadDataFromCurrentLocation];
    }
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
        self.collectionView.alpha = 0;
        self.forecastCollectionView.alpha = 0;
        self.mainTempLabel.alpha = 0;
        self.descriptionLabel.alpha = 0;
        self.topGradientImageView.alpha = 0;
    }
}

- (void)setGettingData:(BOOL)gettingData
{
    _gettingData = gettingData;
    
    if (!_gettingData) {
        [_spinner stopAnimating];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.collectionView.alpha = 1;
            self.forecastCollectionView.alpha = 1;
            self.mainTempLabel.alpha = 1;
            self.descriptionLabel.alpha = 1;
            self.topGradientImageView.alpha = 1;
        } completion:nil];
        
        [self.collectionView reloadData];
        [self.forecastCollectionView reloadData];
    }
}

#pragma mark - Helpers

- (void)loadDataFromCurrentLocation
{
    self.loading = YES;
    
    if (!_locationManager) {
        CLLocationManager *manager = [CLLocationManager new];
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager = manager;
    }
    
    // Check if we need to use iOS8 methods
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            self.locationManager.delegate = self;
            [_locationManager requestWhenInUseAuthorization];
        }
        else {
            if ([self hasLocationAccess]) {
                self.locationManager.delegate = self;
                [_locationManager startUpdatingLocation];
            }
            else {
                [self handleLocationTurnedOff];
            }
        }
    }
    else {
        // Check if location service are enabled on iOS7
        if ([CLLocationManager locationServicesEnabled]) {
            [_locationManager startUpdatingLocation];
        }
        else {
            [self handleLocationTurnedOff];
        }
    }
}

- (BOOL)hasLocationAccess
{
    BOOL enabled = NO;
    
    if (!_locationManager) {
        CLLocationManager *manager = [CLLocationManager new];
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager = manager;
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        enabled = (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse);
        return enabled;
    }
    
    enabled = (status == kCLAuthorizationStatusAuthorized);
    
    return enabled;
}

- (void)getWeatherDataWithCityID:(NSString *)cityID longitude:(double)longitude latitude:(double)latitude
{
    self.loading = YES;
    self.gettingData = YES;
    
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    WCImageCategory category = [[WCSettings sharedSettings] selectedImageCategory];
    NSLog(@"category is %u",category);
    
    NSDictionary *params = @{};
    if (cityID) {
        params = @{@"cityID": cityID,
                   @"date":[NSDate date],
                   @"imageCategory":@(category),
                   @"timezone":@(tz.secondsFromGMT)};
    }
    else {
        params = @{@"lat": @(latitude),
                   @"lon": @(longitude),
                   @"date":[NSDate date],
                   @"imageCategory":@(category),
                   @"timezone":@(tz.secondsFromGMT)};
    }
    
    [PFCloud callFunctionInBackground:@"getWeatherCandyData"
                       withParameters:params
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
                                        
                                        NSDictionary *currentWeatherDict = result[@"currentWeather"];
                                        
                                        float currentTemp = [currentWeatherDict[@"temperature"] floatValue];
                                        NSTimeInterval sunrise = [currentWeatherDict[@"sunrise"] longLongValue];
                                        NSTimeInterval sunset = [currentWeatherDict[@"sunset"] longLongValue];
                                        NSTimeInterval localTime = [currentWeatherDict[@"dt"] longLongValue];
                                        NSInteger condition = [currentWeatherDict[@"condition"] integerValue];
                                        
                                        WCWeather *newCurrentWeather = [WCWeather new];
                                        newCurrentWeather.temperature = currentTemp;
                                        newCurrentWeather.sunrise = sunrise;
                                        newCurrentWeather.sunset = sunset;
                                        newCurrentWeather.currentLocalTime = localTime;
                                        newCurrentWeather.condition = (int)condition;
                                        _currentWeather = newCurrentWeather;
                                        
                                        NSMutableArray *newForecastData = [NSMutableArray new];
                                        for (NSDictionary *dict in result[@"forecastList"]) {
                                            WCForecastWeather *forecastWeather = [WCForecastWeather new];
                                            forecastWeather.temperature = [dict[@"temperature"] floatValue];
                                            forecastWeather.forecastTime = [dict[@"dt"] longLongValue];
                                            forecastWeather.condition = (int)[dict[@"condition"] integerValue];
                                            forecastWeather.sunrise = sunrise;
                                            forecastWeather.sunset = sunset;
                                            [newForecastData addObject:forecastWeather];
                                        }
                                        _forecastData = [NSArray arrayWithArray:newForecastData];
                                        
                                        // Make sure to change the title to the retrieved name if we're using current location
                                        if (_currentLocation) {
                                            NSString *currentCityName = currentWeatherDict[@"cityName"];
                                            [self.titleButton setTitle:currentCityName forState:UIControlStateNormal];
                                        }
                                        
                                        // Refresh all of the UI
                                        [self refreshTempUI];
                                    }
                                    
                                    self.loading = NO;
                                    self.gettingData = NO;
                                    _currentLocation = NO;
                                }];
}

- (void)refreshTempUI
{
    self.mainTempLabel.text = [_currentWeather tempString];
    self.descriptionLabel.text = [_currentWeather weatherDescription];
    
    if ([_currentWeather isDayTime]) {
        if ([_currentWeather condition] == WCWeatherConditionClear) {
            [self changeToBackgroundForType:WCBackgroundTypeOrange];
        }
        else {
            [self changeToBackgroundForType:WCBackgroundTypeBlue];
        }
    }
    else {
        [self changeToBackgroundForType:WCBackgroundTypePurple];
    }
}

- (void)changeToBackgroundForType:(WCBackgroundType)type
{
    NSString *imgName = @"";
    UIColor *bgColor;
    
    switch (type) {
        case WCBackgroundTypeBlue:
            imgName = kBackgroundImageNameBlue;
            bgColor = kBackgroundColorBlue;
            break;
        case WCBackgroundTypeOrange:
            imgName = kBackgroundImageNameOrange;
            bgColor = kBackgroundColorOrange;
            break;
        case WCBackgroundTypePurple:
            imgName = kBackgroundImageNamePurple;
            bgColor = kBackgroundColorPurple;
            break;
        default:
            imgName = kBackgroundImageNameBlue;
            bgColor = kBackgroundColorBlue;
            break;
    }
    
    self.view.backgroundColor = bgColor;
    self.collectionView.backgroundColor = bgColor;
    self.bgGradientImageView.image = [UIImage imageNamed:imgName];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    
    [self.bgGradientImageView.layer addAnimation:transition forKey:nil];
}

- (void)openProfileForIndexPath:(NSIndexPath *)indexPath
{
    WCPhoto *p = _imgData[indexPath.row];
    
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:p.username delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Instagram Profile", nil];
    [as showInView:self.view];
}

- (void)changeToCity:(WCCity *)city
{
    [self.titleButton setTitle:city.name forState:UIControlStateNormal];
    if (!city.currentLocation) {
        [self getWeatherDataWithCityID:[city.cityID stringValue] longitude:0 latitude:0];
    }
    else {
        _currentLocation = YES;
        [self loadDataFromCurrentLocation];
    }
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
    [self refreshTempUI];
    [self.forecastCollectionView reloadData];
}

- (void)imageDownloaded:(NSNotification *)note
{
//    [self blurCurrentImageWithScrollOffset:self.outerScrollView.contentOffset];
}

- (void)appBecameActive:(NSNotification *)note
{
    WCSettings *shared = [WCSettings sharedSettings];
    shared.locationEnabled = [self hasLocationAccess];
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

- (IBAction)pressedTitle:(id)sender
{
    if (_gettingData || _loading) return;
    
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCityNavController"];
    WCAddCityViewController *addCity = (WCAddCityViewController *)vc.topViewController;
    addCity.titleButtonText = self.titleButton.titleLabel.text;
    addCity.bgImg = [self blurredImageOfCurrentView];
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
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
    
    NSInteger ind = indexPath.row + 4 * indexPath.section;
    
    if (ind < _forecastData.count) {
        
        WCForecastWeather *forecastWeather = _forecastData[indexPath.row + 4 * indexPath.section];
        cell.tempLabel.text = [forecastWeather tempString];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:forecastWeather.forecastTime];
        cell.timeLabel.text = [[_dateFormatter stringFromDate:date] lowercaseString];
        cell.iconImage = [UIImage imageNamed:[forecastWeather iconNameForCurrentCondition]];
    }
    else {
        cell.tempLabel.text = @"-";
        cell.timeLabel.text = @"-";
    }
   
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.collectionView]) {
        return self.view.bounds.size;
    }
    
    return CGSizeMake((self.view.bounds.size.width - 50) / 4, 118);
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

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    
    WCSlideDownModalAnimation *slide = [WCSlideDownModalAnimation new];
    slide.presenting = NO;
    return slide;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    WCSlideDownModalAnimation *slide = [WCSlideDownModalAnimation new];
    slide.presenting = YES;
    return slide;
}

//#pragma mark - Scroll view delegate
//
//- (void)blurCurrentImageWithScrollOffset:(CGPoint)offset
//{
//    if (self.collectionView.visibleCells.count <= 0) return;
//    
//    WCCollectionViewCell *currentImageCell = self.collectionView.visibleCells[0];
//    UIImage *currentImage = currentImageCell.imageView.image;
//    
//    if (!currentImage) return;
//    
//    if (offset.y > 0) {
//        if (!_blurImageView) {
//            _blurImageView = [[UIImageView alloc] initWithFrame:currentImageCell.contentView.bounds];
//            _blurImageView.alpha = 0;
//            UIImage *blurred = [currentImage applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:0 alpha:0.3] saturationDeltaFactor:1.3 maskImage:nil];
//            _blurImageView.image = blurred;
//            [currentImageCell.contentView insertSubview:_blurImageView atIndex:1];
//        }
//    }
//    else {
//        [_blurImageView removeFromSuperview];
//        _blurImageView.image = nil;
//        _blurImageView = nil;
//    }
//    
//    _blurImageView.alpha = offset.y / self.view.bounds.size.height * 5;
//}

#pragma mark - Location Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"location not determined");
            break;
        case kCLAuthorizationStatusDenied: {
            WCSettings *settings = [WCSettings sharedSettings];
            [settings setLocationEnabled:NO];
            [self handleLocationTurnedOff];
            break;
        }
        case kCLAuthorizationStatusRestricted: {
            WCSettings *settings = [WCSettings sharedSettings];
            [settings setLocationEnabled:NO];
            [self handleLocationTurnedOff];
            break;
        }
        case kCLAuthorizationStatusAuthorized: {
            WCSettings *settings = [WCSettings sharedSettings];
            [settings setLocationEnabled:YES];
            // Location available, start updating if not already
            [_locationManager startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            WCSettings *settings = [WCSettings sharedSettings];
            [settings setLocationEnabled:YES];
            // Location available, start updating if not already
            [_locationManager startUpdatingLocation];
            break;
        }
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (!_gettingData) {
        CLLocation *location = locations.lastObject;
        CLLocationCoordinate2D coord = location.coordinate;
        _currentLocation = YES;
        [self getWeatherDataWithCityID:nil longitude:coord.longitude latitude:coord.latitude];
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (error != kCLErrorLocationUnknown) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was an error finding your current location. You can search for a city by tapping the city name above." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [err show];
            [self handleNoLocation];
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
        });
    }
}

- (void)handleLocationTurnedOff
{
    // No location, show weather for hard coded city
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was an error finding your current location. Please turn on location services for this app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [err show];
        [self handleNoLocation];
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    });
}

- (void)handleNoLocation
{
    // Remove delegate so that it doesn't respond anymore
    self.locationManager.delegate = nil;
    // Load weather for newport beach
    WCCity *np = [WCCity new];
    np.name = @"Newport Beach";
    np.cityID = @(5376890);
    [self changeToCity:np];
}

@end

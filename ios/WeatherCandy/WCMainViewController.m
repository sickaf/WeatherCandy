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
#import "WCErrorView.h"
#import "WCNetworkManager.h"

@interface WCMainViewController () {
    NSArray *_imgData;
    NSArray *_forecastData;
    NSDateFormatter *_dateFormatter;
    WCWeather *_currentWeather;
    WCCity *_currentCity;
}

@property (weak, nonatomic) IBOutlet UICollectionView *forecastCollectionView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) BOOL loading;
@property (assign, nonatomic) BOOL gettingData;
@property (assign, nonatomic) BOOL error;
@property (assign, nonatomic) BOOL currentLocation;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong,nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@property (strong, nonatomic) WCErrorView *errorView;

@property (strong, nonatomic) WCChooseCategoryViewController *categoryChooser;

@end

@implementation WCMainViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup
    
    _imgData = @[];
    
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
    
    self.mainTempLabel.font = kDefaultFontUltraLight(100);
    self.descriptionLabel.font = kDefaultFontBold(40);
    
    [self changeToBackgroundForType:WCBackgroundTypeBlue];
        
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, -self.titleButton.imageView.frame.size.width - 5, 0, self.titleButton.imageView.frame.size.width + 5);
    self.titleButton.imageEdgeInsets = UIEdgeInsetsMake(0, self.titleButton.titleLabel.frame.size.width, 0, -self.titleButton.titleLabel.frame.size.width);
    
    // User has already chosen a category, startup as usual
    
    WCSettings *settings = [WCSettings sharedSettings];
    
    if ([settings hasChosenCategory]) {
        // Get data
        [self getInitialData];
    }
    else {
        // Add OOBE as a child view controller
        UIStoryboard *oobe = [UIStoryboard storyboardWithName:@"OOBE" bundle:[NSBundle mainBundle]];
        WCChooseCategoryViewController *choose = (WCChooseCategoryViewController *)[oobe instantiateViewControllerWithIdentifier:@"OOBE"];
        choose.view.frame = self.view.bounds;
        choose.delegate = self;
        
        _categoryChooser = choose;
        
        [self.view addSubview:_categoryChooser.view];
        [self addChildViewController:_categoryChooser];
        [_categoryChooser didMoveToParentViewController:self];
    }
    
    // Subcribe to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempUnitToggled:) name:kReloadTempLabelsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImages:) name:kReloadImagesNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[self.navigationController viewControllers] firstObject] isKindOfClass:[WCChooseCategoryViewController class]])
    {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
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
        [self enableLoadingState];
    }
}

- (void)setGettingData:(BOOL)gettingData
{
    _gettingData = gettingData;
    
    if (!_gettingData) {
        
        if (self.error) {
            [self enableErrorState];
        }
        else {
            [self disableLoadingState];
        }
    }
}

#pragma mark - Helpers

- (void)getInitialData
{
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

- (void)enableLoadingState
{
    [_spinner startAnimating];
    _spinner.hidden = NO;
    self.collectionView.alpha = 0;
    self.forecastCollectionView.alpha = 0;
    self.mainTempLabel.alpha = 0;
    self.descriptionLabel.alpha = 0;
    self.topGradientImageView.alpha = 0;
    self.errorView.alpha = 0;
    _errorView.alpha = 0;
}

- (void)disableLoadingState
{
    [_spinner stopAnimating];
    [self.forecastCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.collectionView.alpha = 1;
        self.forecastCollectionView.alpha = 1;
        self.mainTempLabel.alpha = 1;
        self.descriptionLabel.alpha = 1;
        self.topGradientImageView.alpha = 1;
    } completion:nil];
    [self.collectionView reloadData];
    [self.forecastCollectionView reloadData];
    [self bumpForecast];

}

- (void)enableErrorState
{
    if (!_errorView) {
        
        WCErrorView *err = [[WCErrorView alloc] initWithFrame:self.view.bounds];
        err.userInteractionEnabled = YES;
        err.translatesAutoresizingMaskIntoConstraints = NO;
        [err.butt addTarget:self action:@selector(pressedRetry:) forControlEvents:UIControlEventTouchUpInside];
        self.errorView = err;
        [self.view addSubview:self.errorView];
        
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[err]|" options: NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"err": _errorView}];
        constraints = [constraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(60)-[err]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"err": _errorView}]];
        
        _errorView.alpha = 0;
        [self.view addConstraints:constraints];
    }
    
    [_spinner stopAnimating];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _errorView.alpha = 1;
    } completion:nil];
}

- (void)loadDataFromCurrentLocation
{
    self.loading = YES;
    
    if (!_locationManager) {
        CLLocationManager *manager = [CLLocationManager new];
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager = manager;
    }
    
    // Check if we need to use iOS8 methods
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (BOOL)hasLocationAccess
{
    BOOL enabled = NO;
    
    if (!_locationManager) {
        CLLocationManager *manager = [CLLocationManager new];
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager = manager;
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        enabled = (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse);
        return enabled;
    }
    
    enabled = (status == kCLAuthorizationStatusAuthorizedWhenInUse);
    
    return enabled;
}

- (void)getWeatherDataWithCityID:(NSString *)cityID longitude:(double)longitude latitude:(double)latitude
{
    // Cancel requests for current place weather
    [[WCNetworkManager sharedManager] cancelAllWeatherRequests];

    self.loading = YES;
    self.gettingData = YES;
    self.error = NO;
    
    void (^completion)(WCData *data, NSError *error) = ^void(WCData *data, NSError *error)
    {
        if (!error) {
            
            // Instagram photos
            
            _imgData = data.IGPhotos;
            [self.collectionView reloadData];
            
            // Weather
            
            _currentWeather = data.currentWeather;
            
            // Forecast
            
            _forecastData = data.forecastData;
            
            // Make sure to change the title to the retrieved name if we're using current location
            if (self.currentLocation) {
                [self.titleButton setTitle:data.cityName forState:UIControlStateNormal];
            }
            
            // Refresh all of the UI
            [self refreshTempUI];
            
            // Save date last updated for future refreshing
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"last_updated"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            self.error = YES;
        }
        
        self.loading = NO;
        self.gettingData = NO;
        self.currentLocation = NO;
    };
    
    if (cityID) {
        [[WCNetworkManager sharedManager] getDataWithCityID:cityID completion:completion];
    }
    else {
        [[WCNetworkManager sharedManager] getDataWithLon:longitude lat:latitude completion:completion];
    }
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
    
    _currentCity = city;
}

- (void)reloadBlurredBackgroundOnPresentedViewController
{
    if (![self.navigationController.topViewController isEqual:self]) {
        WCAddCityViewController *vc = (WCAddCityViewController *)self.navigationController.topViewController;
        vc.bgImg = [self blurredImageOfCurrentView];
    }
}

- (void)updateIfNeeded
{
    NSDate *savedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_updated"];
    NSDate *now = [NSDate date];
    NSTimeInterval difference = [now timeIntervalSince1970] - [savedDate timeIntervalSince1970];
    
    if (savedDate && difference > 60 * 10) {
        [self getInitialData];
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

- (void)appBecameActive:(NSNotification *)note
{
    WCSettings *shared = [WCSettings sharedSettings];
    shared.locationEnabled = [self hasLocationAccess];
    
    if ([[WCSettings sharedSettings] hasChosenCategory] && !self.loading) {
        [self updateIfNeeded];
    }
}

- (void)refreshImages:(NSNotification *)note
{
    [self changeToCity:_currentCity];
}

#pragma mark - Actions

- (IBAction)pressedSettings:(id)sender
{
    UIStoryboard *st = [UIStoryboard storyboardWithName:@"Settings" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [st instantiateViewControllerWithIdentifier:@"Settings"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)pressedTitle:(id)sender
{
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCityNavController"];
    WCAddCityViewController *addCity = (WCAddCityViewController *)vc.topViewController;
    addCity.titleButtonText = self.titleButton.titleLabel.text;
    addCity.bgImg = [self blurredImageOfCurrentView];
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)pressedRetry:(id)sender
{
    [self getInitialData];
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
    
    if (ind < _forecastData.count)
    {
        WCForecastWeather *forecastWeather = _forecastData[indexPath.row + 4 * indexPath.section];
        cell.tempLabel.text = [forecastWeather tempString];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:forecastWeather.forecastTime];
        cell.timeLabel.text = [[_dateFormatter stringFromDate:date] lowercaseString];
        cell.iconImage = [UIImage imageNamed:[forecastWeather iconNameForCurrentCondition]];
    }
    else {
        cell.tempLabel.text = @"-";
        cell.timeLabel.text = @"-";
        cell.iconImage = [UIImage imageNamed:kIconNameFogDay];
    }
   
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.collectionView]) {
        return self.view.bounds.size;
    }
    
    return CGSizeMake((self.view.bounds.size.width - 40) / 4, 118);
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.forecastCollectionView])
    {
        if (collectionView.frame.origin.x >= 0 && !indexPath.section)
        {
            [self bumpForecast];
        }
        return NO;
    }
    
    WCPhoto *p = _imgData[indexPath.row];
    return p.username != nil;
}

- (void)bumpForecast
{
    if (!self.animator) {
        
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        
        UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.forecastCollectionView]];
        [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -100, 0, 0)];
        [self.animator addBehavior:collisionBehaviour];
        
        self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.forecastCollectionView]];
        [self.animator addBehavior:self.gravityBehavior];
        
        self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.forecastCollectionView] mode:UIPushBehaviorModeInstantaneous];
        self.pushBehavior.magnitude = 0.0f;
        self.pushBehavior.angle = 0.0f;
        [self.animator addBehavior:self.pushBehavior];
        
        UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.forecastCollectionView]];
        itemBehaviour.elasticity = 0.45f;
        [self.animator addBehavior:itemBehaviour];
    }
    
    self.gravityBehavior.gravityDirection = CGVectorMake(1.0f, 0.0f);
    self.pushBehavior.pushDirection = CGVectorMake(-7.0f, 0.0f);
    self.pushBehavior.active = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

#pragma mark - Choose category delegate

- (void)userDidChooseCategory
{
    // Get initial data
    [self getInitialData];
    
    // Animate out the category chooser
    [UIView animateWithDuration:0.2 animations:^{
        [_categoryChooser.view setAlpha:0];
    } completion:^(BOOL finished) {
        [_categoryChooser willMoveToParentViewController:nil];
        [_categoryChooser.view removeFromSuperview];
        [_categoryChooser removeFromParentViewController];
        _categoryChooser = nil;
    }];
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
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
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
    CLLocation *location = locations.lastObject;
    CLLocationCoordinate2D coord = location.coordinate;
    _currentLocation = YES;
    
    WCCity *c = [WCCity new];
    c.currentLocation = YES;
    c.name = @"Current Location";
    _currentCity = c;
    
    [self getWeatherDataWithCityID:nil longitude:coord.longitude latitude:coord.latitude];
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] != kCLErrorLocationUnknown && [error code] != kCLErrorDenied) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"There was an error finding your current location. You can search for a city by tapping the city name above." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [err show];
            [self handleNoLocation];
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
            
            WCCity *c = [WCCity new];
            c.currentLocation = YES;
            c.name = @"Current Location";
            _currentCity = c;
        });
    }
}

- (void)handleLocationTurnedOff
{
    // No location, show weather for hard coded city
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
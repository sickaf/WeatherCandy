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
#import "WCErrorView.h"
#import "Apsalar.h"

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

@property (strong, nonatomic) UINavigationController *categoryChooser;

@end

@implementation WCMainViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup
    
    _imgData = @[];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cityChanged:) name:kCityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempUnitToggled:) name:kReloadTempLabelsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImages:) name:kReloadImagesNotification object:nil];
    
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
        UINavigationController *choose = [oobe instantiateViewControllerWithIdentifier:@"OOBE"];
        choose.view.frame = self.view.bounds;
        
        _categoryChooser = choose;
        WCChooseCategoryViewController *chooseVC = (WCChooseCategoryViewController *)[_categoryChooser topViewController];
        chooseVC.delegate = self;
        
        [self.view addSubview:_categoryChooser.view];
        [self addChildViewController:_categoryChooser];
        [_categoryChooser didMoveToParentViewController:self];
        
    }
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
        self.locationManager.delegate = self;
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
    self.error = NO;
    
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
                                        
                                        //NSLog(@"%@", result);
                                        
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
                                        if (self.currentLocation) {
                                            NSString *currentCityName = currentWeatherDict[@"cityName"];
                                            [self.titleButton setTitle:currentCityName forState:UIControlStateNormal];
                                        }
                                        
                                        // Refresh all of the UI
                                        [self refreshTempUI];
                                    }
                                    else {
                                        self.error = YES;
                                    }
                                    
                                    self.loading = NO;
                                    self.gettingData = NO;
                                    self.currentLocation = NO;
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

    //analytics
    NSString *rowStr = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    NSDictionary *analyticsDimensions = @{
                                            @"didTapPhoto" : @"1",
                                            @"category" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] selectedImageCategory]],
                                            @"notificationsOn" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] notificationsOn]],
                                            @"username" : p.username,
                                            @"photoIndex": rowStr
                                          };
    [Apsalar event:@"photoEvent_Test" withArgs:analyticsDimensions];
    
    
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
    
    _currentCity = city;
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

- (void)appBecameActive:(NSNotification *)note
{
    WCSettings *shared = [WCSettings sharedSettings];
    shared.locationEnabled = [self hasLocationAccess];
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
    if (_gettingData || _loading) return;
    
    UINavigationController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"AddCityNavController"];
    WCAddCityViewController *addCity = (WCAddCityViewController *)vc.topViewController;
    addCity.titleButtonText = self.titleButton.titleLabel.text;
    addCity.bgImg = [self blurredImageOfCurrentView];
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)pressedAction:(id)sender
{
    if (_gettingData || _loading || !_imgData.count) return;

    UICollectionViewCell *current = [[self.collectionView visibleCells] firstObject];
    NSIndexPath *currentInd = [self.collectionView indexPathForCell:current];
    
    [self openProfileForIndexPath:currentInd];
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
        //Analytics
        NSDictionary *analyticsDimensions = @{
                                              @"didTapForecast" : @"1",
                                              @"category" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] selectedImageCategory]],
                                              @"currentTemperatureUnit" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] tempUnit]],
                                              @"notificationsOn" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] notificationsOn]],
                                              };
        // Send the dimensions to Parse
        [Apsalar event:@"weatherEvent_Test" withArgs:analyticsDimensions];
        
        if (collectionView.frame.origin.x >= 0 && !indexPath.section) {
            
            // Bump animation
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
        
        return NO;
    }

    
    WCPhoto *p = _imgData[indexPath.row];
    return p.username != nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self openProfileForIndexPath:indexPath];
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

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *analyticsDimensions = nil;
    
    if (buttonIndex == 0)
    {
        NSString *st = [NSString stringWithFormat:@"instagram://user?username=%@", actionSheet.title];
        NSURL *instagramURL = [NSURL URLWithString:st];
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            [[UIApplication sharedApplication] openURL:instagramURL];
        }
        else {
            UIAlertView *sry = [[UIAlertView alloc] initWithTitle:@"Uh oh" message:@"You don't have Instagram installed. Please install it and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [sry show];
        }
        
        //Analytics
        analyticsDimensions = @{
                                @"didGoToInstagram" : @"1",
                                @"category" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] selectedImageCategory]],
                                @"notificationsOn" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] notificationsOn]],
                                @"username" : actionSheet.title,
                                };
        
        // Send the dimensions to Parse
    }
    else //cancelled action sheet
    {
        //analytics
        analyticsDimensions = @{
                                @"didCancelActionSheet" : @"1",
                                @"category" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] selectedImageCategory]],
                                @"notificationsOn" : [NSString stringWithFormat:@"%d", [[WCSettings sharedSettings] notificationsOn]],
                                @"username" : actionSheet.title,
                                };

    }
    [Apsalar event:@"photoEvent_Test" withArgs:analyticsDimensions];

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
        
        WCCity *c = [WCCity new];
        c.currentLocation = YES;
        c.name = @"Current Location";
        _currentCity = c;
    }
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

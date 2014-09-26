//
//  WCSettings.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSettings.h"

static NSString *const kWCTemperatureTypeKey        = @"WCTemperatureType";
static NSString *const kWCNotificationsKey          = @"WCNotificationsKey";
static NSString *const kWCNotificationsAllowedKey   = @"WCNotificationsAllowedKey";
static NSString *const kWCCategoryKey               = @"WCCategoryKey";
static NSString *const kWCHasChosenCategoryKey      = @"WCChosenCategory";

@implementation WCSettings

+ (id)sharedSettings
{
    static WCSettings *sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    return sharedSettings;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Get user defaults
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        // Get the last set temp unit from storage
        WCTemperatureUnit unit = kWCFahrenheit;
        if ([ud objectForKey:kWCTemperatureTypeKey])
        {
            unit = [[ud objectForKey:kWCTemperatureTypeKey] intValue];
        }
        self.tempUnit = unit; // Set the property

        //get the category from storage
        WCImageCategory category = WCImageCategoryGirl;
        if ([ud integerForKey:kWCCategoryKey])
        {
            category = (int)[ud integerForKey:kWCCategoryKey];
        }
        self.selectedImageCategory = category; // Set the property
        
        // Check if the user has chosen a category already
        BOOL hasChosenCategory = NO;
        if ([ud boolForKey:kWCHasChosenCategoryKey])
        {
            hasChosenCategory = [ud boolForKey:kWCHasChosenCategoryKey];
        }
        
        self.hasChosenCategory = hasChosenCategory;
        
        // Get the bool from storage
        BOOL notifications = NO;
        if ([ud boolForKey:kWCNotificationsKey])
        {
            notifications = [ud boolForKey:kWCNotificationsKey];
        }
        
        // Set the property
        self.notificationsOn = notifications;
        
        // Get the bool from storage
        BOOL notificationsAllowed = NO;
        if ([ud boolForKey:kWCNotificationsAllowedKey])
        {
            notificationsAllowed = [ud boolForKey:kWCNotificationsAllowedKey];
        }
        
        // Set the property
        self.notificationsAllowed = notificationsAllowed;
        
    }
    return self;
}


- (void)setTempUnit:(WCTemperatureUnit)tempUnit
{
    _tempUnit = tempUnit;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithInt:tempUnit] forKey:kWCTemperatureTypeKey];
    [ud synchronize];
}

- (void)setSelectedImageCategory:(WCImageCategory)selectedImageCategory
{
    _selectedImageCategory = selectedImageCategory;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setInteger:_selectedImageCategory forKey:kWCCategoryKey];
    [ud synchronize];
}

- (void)setNotificationsOn:(BOOL)notificationsOn
{
    _notificationsOn = notificationsOn;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:notificationsOn forKey:kWCNotificationsKey];
    [ud synchronize];
}

- (void)setNotificationsAllowed:(BOOL)notificationsAllowed
{
    _notificationsAllowed = notificationsAllowed;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:notificationsAllowed forKey:kWCNotificationsAllowedKey];
    [ud synchronize];
}

- (void)setHasChosenCategory:(BOOL)hasChosenCategory
{
    _hasChosenCategory = hasChosenCategory;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:_hasChosenCategory forKey:kWCHasChosenCategoryKey];
    [ud synchronize];
}

- (void)clearSavedCities
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"cities"];
    [ud synchronize];
}

@end

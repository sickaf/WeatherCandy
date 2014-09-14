//
//  WCSettings.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSettings.h"

static NSString *const kWCTemperatureTypeKey = @"WCTemperatureType";
static NSString *const kWCNotificationsKey   = @"WCNotificationsKey";
static NSString *const kWCCategoryKey        = @"WCCategoryKey";

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
        WCTemperatureUnit unit = kWCCelsius;
        if ([ud objectForKey:kWCTemperatureTypeKey])
        {
            unit = [[ud objectForKey:kWCTemperatureTypeKey] intValue];
        }
        self.tempUnit = unit; // Set the property

        //get the category from storage
        WCImageCategory category = WCImageCategoryGirl;
        if ([ud integerForKey:kWCCategoryKey])
        {
            category = [ud integerForKey:kWCCategoryKey];
        }
        self.selectedImageCategory = category; // Set the property
        
        // Get the bool from storage
        BOOL notifications = NO;
        if ([ud boolForKey:kWCNotificationsKey])
        {
            notifications = [ud boolForKey:kWCNotificationsKey];
        }
        
        // Set the property
        self.notificationsOn = notifications;
        
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

- (void)clearSavedCities
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:@"cities"];
    [ud synchronize];
}

@end

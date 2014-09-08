//
//  WCSettings.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCSettings.h"

static NSString *const kWCTemperatureTypeKey = @"WCTemperatureType";

@implementation WCSettings

- (void)setTempUnit:(WCTemperatureUnit)tempUnit
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithInt:tempUnit] forKey:kWCTemperatureTypeKey];
    [ud synchronize];
}

- (WCTemperatureUnit)tempUnit
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    WCTemperatureUnit unit = kWCFahrenheit;
    if ([ud objectForKey:kWCTemperatureTypeKey]) {
        unit = [[ud objectForKey:kWCTemperatureTypeKey] intValue];
    }
    
    return unit;
}


@end

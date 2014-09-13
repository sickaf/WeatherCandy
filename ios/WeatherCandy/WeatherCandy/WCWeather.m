//
//  WCWeather.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/13/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCWeather.h"
#import "WCTempFormatter.h"

@implementation WCWeather {
    WCTempFormatter *_tempFormatter;
}

- (id)init
{
    self = [super init];
    if (self) {
        _tempFormatter = [WCTempFormatter new];
    }
    return self;
}

- (NSString *)getTempString
{
    return [_tempFormatter formattedStringWithKelvin:self.temperature];
}

- (NSString *)getDescriptionString
{
    return [self stringWithWeatherCondition:self.condition];
}

- (NSString *)stringWithWeatherCondition:(WCWeatherCondition)condition
{
    switch (condition) {
        case WCWeatherConditionThunderstorm:
            return @"Thunderstorms";
            break;
        case WCWeatherConditionDrizzle:
            return @"Drizzle";
            break;
        case WCWeatherConditionRain:
            return @"Raining";
            break;
        case WCWeatherConditionClear: {
            if ([self isDayTime]) {
                return @"Sunny";
            }
            return @"Clear";
            break;
        }
        case WCWeatherConditionHaze:
            return @"Haze";
            break;
        case WCWeatherConditionOvercast:
            return  @"Cloudy";
            break;
        case WCWeatherConditionPartyCloudy:
            return @"Party Cloudy";
            break;
        case WCWeatherConditionSnow:
            return @"Snowing";
            break;
        default:
            return @"Unknown";
            break;
    }
}

- (BOOL)isDayTime
{
    if (self.currentLocalTime > self.sunrise && self.currentLocalTime < self.sunset) {
        return YES;
    }
    
    return NO;
}

@end

//
//  WCForecastWeather.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/13/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCForecastWeather.h"

@implementation WCForecastWeather

- (NSString *)iconNameForCurrentCondition
{
    return [self iconStringWithWeatherCondition:self.condition];
}

- (NSString *)iconStringWithWeatherCondition:(WCWeatherCondition)condition
{
    switch (condition) {
        case WCWeatherConditionThunderstorm:
            return kIconNameStorm;
            break;
        case WCWeatherConditionDrizzle:
            return kIconNameDrizzle;
            break;
        case WCWeatherConditionRain:
            return kIconNameRain;
            break;
        case WCWeatherConditionClear: {
            if ([self isDayTime]) {
                return kIconNameClearDay;
            }
            return kIconNameClearNight;
            break;
        }
        case WCWeatherConditionHaze:
            if ([self isDayTime]) {
                return kIconNameFogDay;
            }
            return kIconNameFogNight;
            break;
        case WCWeatherConditionOvercast:
            return  kIconNameClouds;
            break;
        case WCWeatherConditionPartyCloudy:
            if ([self isDayTime]) {
                return kIconNamePartlyCloudyDay;
            }
            return kIconNamePartlyCloudyNight;
            break;
        case WCWeatherConditionSnow:
            return kIconNameSnow;
            break;
        default:
            if ([self isDayTime]) {
                return kIconNameFogDay;
            }
            return kIconNameFogNight;
            break;
    }
}

- (BOOL)isDayTime
{
    if (self.forecastTime > self.sunrise && self.forecastTime < self.sunset) {
        return YES;
    }
    
    if (self.forecastTime > (self.sunrise + 24*60*60) && self.forecastTime < (self.sunset + 24*60*60)) {
        return YES;
    }
    
    return NO;
}

@end
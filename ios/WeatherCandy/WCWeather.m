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

- (NSString *)tempString
{
    return [_tempFormatter formattedStringWithKelvin:self.temperature];
}

- (NSString *)weatherDescription
{
    return [self descriptionStringWithWeatherCondition:self.condition];
}

- (NSString *)iconNameForCurrentCondition
{
    return @"";
}

- (NSString *)descriptionStringWithWeatherCondition:(WCWeatherCondition)condition
{
    switch (condition) {
        case WCWeatherConditionThunderstorm:
            return kConditionStringThunderstorm;
            break;
        case WCWeatherConditionDrizzle:
            return kConditionStringDrizzle;
            break;
        case WCWeatherConditionRain:
            return kConditionStringRaining;
            break;
        case WCWeatherConditionClear: {
            if ([self isDayTime]) {
                return kConditionStringClearDay;
            }
            return kConditionStringClearNight;
            break;
        }
        case WCWeatherConditionHaze:
            return kConditionStringHaze;
            break;
        case WCWeatherConditionOvercast:
            return  kConditionStringCloudy;
            break;
        case WCWeatherConditionPartyCloudy:
            return kConditionStringPartlyCloudy;
            break;
        case WCWeatherConditionSnow:
            return kConditionStringSnow;
            break;
        default:
            return kConditionStringUnknown;
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

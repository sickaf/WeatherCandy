//
//  WCWeather.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/13/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

typedef enum {
    WCWeatherConditionThunderstorm = 1,
    WCWeatherConditionDrizzle,
    WCWeatherConditionRain,
    WCWeatherConditionSnow,
    WCWeatherConditionHaze,
    WCWeatherConditionClear,
    WCWeatherConditionPartyCloudy,
    WCWeatherConditionOvercast,
} WCWeatherCondition;

#import <Foundation/Foundation.h>
#import "WCSettings.h"

@interface WCWeather : NSObject

@property (nonatomic, assign) float temperature;
@property (nonatomic, assign) WCWeatherCondition condition;
@property (nonatomic, assign) NSTimeInterval currentLocalTime;
@property (nonatomic, assign) NSTimeInterval sunrise;
@property (nonatomic, assign) NSTimeInterval sunset;

- (NSString *)getTempString;
- (NSString *)getDescriptionString;
- (BOOL)isDayTime;

@end

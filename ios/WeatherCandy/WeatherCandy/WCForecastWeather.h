//
//  WCForecastWeather.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/13/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCWeather.h"

@interface WCForecastWeather : WCWeather

@property (nonatomic, assign) NSTimeInterval forecastTime;

- (NSString *)iconNameForCurrentCondition;

@end

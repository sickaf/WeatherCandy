//
//  WCData.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/24/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCWeather.h"
#import "WCForecastWeather.h"

@interface WCData : NSObject

@property (nonatomic, strong) NSArray *IGPhotos;
@property (nonatomic, strong) WCWeather *currentWeather;
@property (nonatomic, strong) NSArray *forecastData;
@property (nonatomic, strong) NSString *cityName;

@end

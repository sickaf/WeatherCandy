//
//  WCSettings.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kWCCelsius=0,
    kWCFahrenheit=1,
} WCTemperatureUnit;

@interface WCSettings : NSObject

@property (nonatomic, assign) WCTemperatureUnit tempUnit;
@property (nonatomic, assign) BOOL notificationsOn;


@end

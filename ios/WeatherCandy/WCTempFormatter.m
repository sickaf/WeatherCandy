//
//  WCTempFormatter.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCTempFormatter.h"

@implementation WCTempFormatter

- (NSString *)formattedStringWithKelvin:(float)temp
{
    NSInteger formattedTemp = 0;
    
    WCTemperatureUnit unit = [[WCSettings sharedSettings] tempUnit];
    if (unit == kWCCelsius) {
        formattedTemp = temp - 273;
    }
    else {
        formattedTemp = 1.8 * (temp - 273) + 32;
    }
    
    return [NSString stringWithFormat:@"%li", (long)formattedTemp];
}

@end

//
//  WCTempFormatter.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/8/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCSettings.h"

@interface WCTempFormatter : NSObject

- (NSString *)formattedStringWithKelvin:(float)temp;

@end

//
//  WCCity.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCCity : NSObject <NSCoding>

@property (nonatomic, strong) NSNumber *cityID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *country;

@end

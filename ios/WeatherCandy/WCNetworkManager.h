//
//  WCNetworkManager.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/24/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WCData.h"

@interface WCNetworkManager : NSObject

+ (id)sharedManager;

// Network Requests

// Returns an array of WCCity objects
- (void)findCitiesWithSearchText:(NSString *)text completion:(void (^)(NSArray *cities, NSError *error))completion;
- (void)getDataWithCityID:(NSString *)cityID completion:(void (^)(WCData *data, NSError *error))completion;
- (void)getDataWithLon:(double)lon lat:(double)lat completion:(void (^)(WCData *data, NSError *error))completion;


// Canceling

- (void)cancelAllWeatherRequests;
- (void)cancelAllAddCityRequests;

@end

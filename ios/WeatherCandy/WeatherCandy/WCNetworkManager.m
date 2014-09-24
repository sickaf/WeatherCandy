//
//  WCNetworkManager.m
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/24/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCNetworkManager.h"
#import "AFNetworking.h"
#import "WCCity.h"

#define kFindCityURL @"http://api.geonames.org/searchJSON"

@interface WCNetworkManager ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *mainManager;
@property (strong, nonatomic) AFHTTPRequestOperationManager *addCityManager;

@end

@implementation WCNetworkManager

+ (id)sharedManager
{
    static WCNetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}

#pragma mark - Methods

- (void)findCitiesWithSearchText:(NSString *)text completion:(void (^)(NSArray *cities, NSError *error))completion
{
    NSDictionary *params = @{@"name": text,
                             @"name_startsWith": text,
                             @"cities": @"cities1000",
                             @"maxRows": @"50",
                             @"isNameRequired": @"true",
                             @"orderby": @"relevance",
                             @"featureClass":@"P",
                             @"username": @"codyko"};
    
    
    [self.addCityManager GET:kFindCityURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (!operation.isCancelled) {
            
            NSDictionary *dict = responseObject;
            
            NSMutableArray *searchResults = [NSMutableArray new];
            
            for (NSDictionary *cityDict in dict[@"geonames"]) {
                WCCity *newCity = [WCCity new];
                newCity.cityID = cityDict[@"geonameId"];
                newCity.name = cityDict[@"name"];
                newCity.adminName = cityDict[@"adminName1"];
                newCity.country = cityDict[@"countryCode"];
                
                [searchResults addObject:newCity];
            }
            
            if (completion) completion(searchResults, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            if (completion) completion(nil, error);
        }
    }];
}

- (void)cancelAllWeatherRequests
{
    [self.mainManager.operationQueue cancelAllOperations];
}

- (void)cancelAllAddCityRequests
{
    [self.addCityManager.operationQueue cancelAllOperations];
}

#pragma mark - Properties

- (AFHTTPRequestOperationManager *)mainManager
{
    if (!_mainManager) {
        _mainManager = [AFHTTPRequestOperationManager manager];
        [_mainManager.operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return _mainManager;
}

- (AFHTTPRequestOperationManager *)addCityManager
{
    if (!_addCityManager) {
        _addCityManager = [AFHTTPRequestOperationManager manager];
        [_addCityManager.operationQueue setMaxConcurrentOperationCount:1];
    }
    
    return _addCityManager;
}

@end

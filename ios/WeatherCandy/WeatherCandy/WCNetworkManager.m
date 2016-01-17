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
#import "WCSettings.h"

#define kFindCityURL @"http://api.geonames.org/searchJSON"
//#define kGetWeatherURL @"https://api.parse.com/1/functions/getWeatherCandyData"
#define kGetWeatherURL @"http://localhost:9000"

#define kParseAppID @"p8AF2BKCLQ7fr3oJXPg43fOL6LXAK3mwAb5Ywnke" //prod
#define kParseAPIKey @"v8C3jQHw0b8JkoCMy3Vn9QgqLdl3F7TxptAKfSVx" //prod

//#define kParseAppID @"fc28JBIZOa74iIGVJaPqLGL48UOWOOapDpyeWzia" //dev
//#define kParseAPIKey @"WgCOeII34VaTj105iXOt2ts00BcdRfjRJ8Ojew20" //dev 


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

- (void)getDataWithCityID:(NSString *)cityID
               completion:(void (^)(WCData *data, NSError *error))completion
{
    [[WCNetworkManager sharedManager] getDataWithLon:0 lat:0 cityID:cityID completion:completion];
}

- (void)getDataWithLon:(double)lon lat:(double)lat
            completion:(void (^)(WCData *data, NSError *error))completion;
{
    [[WCNetworkManager sharedManager] getDataWithLon:lon lat:lat cityID:nil completion:completion];
}

- (void)getDataWithLon:(double)lon
                    lat:(double)lat
                      cityID:(NSString *)cityID
                  completion:(void (^)(WCData *data, NSError *error))completion
{
    NSTimeZone *tz = [NSTimeZone systemTimeZone];
    WCImageCategory category = [[WCSettings sharedSettings] selectedImageCategory];
    
    NSString *dateString = [NSString stringWithFormat:@"%i", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *tzString = [NSString stringWithFormat:@"%li", (long)tz.secondsFromGMT];
    NSString *categoryString = [NSString stringWithFormat:@"%i",category];
    
    NSDictionary *params;
    
    if (cityID) {
        params = @{@"cityID": cityID,
                                 @"date": dateString,
                                 @"imageCategory": categoryString,
                                 @"timezone": tzString};
    }
    else {
        params = @{@"lat": [NSString stringWithFormat:@"%f",lat],
                   @"lon": [NSString stringWithFormat:@"%f",lon],
                   @"date":dateString,
                   @"imageCategory":categoryString,
                   @"timezone":tzString};
    }
    
    
    

//    self.mainManager.responseSerializer.acceptableContentTypes = [self.mainManager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    AFHTTPRequestSerializer *serializer = self.mainManager.requestSerializer;
//    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:kGetWeatherURL parameters:nil error:nil];
    NSLog(@"LMAO");

    NSMutableURLRequest *request = [serializer requestWithMethod:@"POST" URLString:kGetWeatherURL parameters:params error:nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    request.HTTPBody = data;
    [self.mainManager GET:kGetWeatherURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {

//    AFHTTPRequestOperation *op = [self.mainManager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"LOL");
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *result = responseObject[@"result"];
        
        // Instagram
        
        NSMutableArray *temp = [NSMutableArray new];
        for (NSDictionary *dict in result[@"IGPhotoSet"]) {
            WCPhoto *newPhoto = [WCPhoto new];
            newPhoto.photoURL = dict[@"IGUrl"];
            newPhoto.username = dict[@"IGUsername"];
            newPhoto.index = dict[@"PhotoNum"];
            [temp addObject:newPhoto];
        }
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        NSArray *finalImgData = [temp sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        // Current weather
        
        NSDictionary *currentWeatherDict = result[@"currentWeather"];
        
        float currentTemp = [currentWeatherDict[@"temperature"] floatValue];
        NSTimeInterval sunrise = [currentWeatherDict[@"sunrise"] longLongValue];
        NSTimeInterval sunset = [currentWeatherDict[@"sunset"] longLongValue];
        NSTimeInterval localTime = [currentWeatherDict[@"dt"] longLongValue];
        NSInteger condition = [currentWeatherDict[@"condition"] integerValue];
        
        WCWeather *newCurrentWeather = [WCWeather new];
        newCurrentWeather.temperature = currentTemp;
        newCurrentWeather.sunrise = sunrise;
        newCurrentWeather.sunset = sunset;
        newCurrentWeather.currentLocalTime = localTime;
        newCurrentWeather.condition = (int)condition;
        
        // Forecast data
        
        NSMutableArray *newForecastData = [NSMutableArray new];
        for (NSDictionary *dict in result[@"forecastList"]) {
            WCForecastWeather *forecastWeather = [WCForecastWeather new];
            forecastWeather.temperature = [dict[@"temperature"] floatValue];
            forecastWeather.forecastTime = [dict[@"dt"] longLongValue];
            forecastWeather.condition = (int)[dict[@"condition"] integerValue];
            forecastWeather.sunrise = sunrise;
            forecastWeather.sunset = sunset;
            [newForecastData addObject:forecastWeather];
        }
        
        NSArray *finalForecastData = [NSArray arrayWithArray:newForecastData];
        
        // City name
        
        NSString *currentCityName = currentWeatherDict[@"cityName"];
        
        // Call completion handler
        
        WCData *dataToReturn = [WCData new];
        dataToReturn.IGPhotos = finalImgData;
        dataToReturn.currentWeather = newCurrentWeather;
        dataToReturn.forecastData = finalForecastData;
        dataToReturn.cityName = currentCityName;
        
        if (!operation.isCancelled) {
            if (completion) completion(dataToReturn, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"FUCK");
        NSLog(@"Error serializing %@", error);
        if (!operation.isCancelled) {
            if (completion) completion(nil, error);
        }
    }];
    
//    [self.mainManager.operationQueue addOperation:op];
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
        
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        [serializer setValue:kParseAppID forHTTPHeaderField:@"X-Parse-Application-Id"];
        [serializer setValue:kParseAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        _mainManager.requestSerializer = serializer;
        _mainManager.responseSerializer = [AFJSONResponseSerializer serializer];
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

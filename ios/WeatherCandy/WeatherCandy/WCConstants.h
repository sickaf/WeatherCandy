//
//  WCConstants.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#define kDefaultBackgroundColor       [UIColor colorWithWhite:0.15 alpha:1.000]
#define kDefaultFont            [UIFont fontWithName:@"HelveticaNeue-Light" size:16]
#define kDefaultTitleFont       [UIFont fontWithName:@"HelveticaNeue" size:15]

#define kDefaultFontBold(s)             [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:s]
#define kDefaultFontUltraLight(s)		[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:s]
#define kDefaultFontMedium(s)           [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:s]

#define kBackgroundImageNameBlue    @"cloudy_plus"
#define kBackgroundImageNameOrange  @"sunny_plus"
#define kBackgroundImageNamePurple  @"night_plus"
#define kBackgroundColorBlue        [UIColor colorWithRed:0.146 green:0.293 blue:0.434 alpha:1.000]
#define kBackgroundColorOrange      [UIColor colorWithRed:0.886 green:0.256 blue:0.252 alpha:1.000]
#define kBackgroundColorPurple      [UIColor colorWithRed:0.115 green:0.000 blue:0.359 alpha:1.000]

#define kConditionStringThunderstorm    @"storming"
#define kConditionStringDrizzle         @"drizzle"
#define kConditionStringRaining         @"raining"
#define kConditionStringClearDay        @"sunny"
#define kConditionStringClearNight      @"clear"
#define kConditionStringHaze            @"haze"
#define kConditionStringCloudy          @"cloudy"
#define kConditionStringPartlyCloudy    @"partly cloudy"
#define kConditionStringSnow            @"snowing"
#define kConditionStringUnknown         @"unknown"


#define kIconNameClouds             @"clouds"
#define kIconNameFogDay             @"fog_day"
#define kIconNameFogNight           @"fog_night"
#define kIconNameDrizzle            @"little_rain"
#define kIconNameClearNight         @"moon"
#define kIconNamePartlyCloudyDay    @"partly_cloudy_day"
#define kIconNamePartlyCloudyNight  @"partly_cloudy_night"
#define kIconNameRain               @"rain"
#define kIconNameSnow               @"snow"
#define kIconNameStorm              @"storm"
#define kIconNameClearDay           @"sun"

static NSString *const kCityChangedNotification         = @"WCCityChangedNotification";
static NSString *const kReloadTempLabelsNotification    = @"WCReloadTempLabelsNotification";
static NSString *const kReloadImagesNotification        = @"WCReloadImages";
static NSString *const kImageDownloadedNotification     = @"WCImageDownloadedNotification";

static NSString *const kLastSelectedCity = @"WCLastSelectedCity";


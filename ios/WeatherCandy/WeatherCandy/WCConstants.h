//
//  WCConstants.h
//  WeatherCandy
//
//  Created by Cody Kolodziejzyk on 9/2/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#define kDefaultBackgroundColor       [UIColor colorWithWhite:0.230 alpha:1.000]
#define kDefaultFont            [UIFont fontWithName:@"HelveticaNeue-Light" size:16]
#define kDefaultTitleFont       [UIFont fontWithName:@"HelveticaNeue" size:15]

#define kDefaultFontBold(s)             [UIFont fontWithName:@"AvenirNextCondensed-Bold" size:s]
#define kDefaultFontUltraLight(s)		[UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:s]
#define kDefaultFontMedium(s)           [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:s]

static NSString *const kCityChangedNotification         = @"WCCityChangedNotification";
static NSString *const kReloadTempLabelsNotification    = @"WCReloadTempLabelsNotification";
static NSString *const kImageDownloadedNotification     = @"WCImageDownloadedNotification";

static NSString *const kLastSelectedCity = @"WCLastSelectedCity";


//
//  AppDelegate.m
//  WeatherCandy
//
//  Created by dtown on 8/31/14.
//  Copyright (c) 2014 sickaf. All rights reserved.
//

#import "WCAppDelegate.h"
#import "WCSettings.h"
#import "Apsalar.h"
#import <Parse/Parse.h>
#import <Crashlytics/Crashlytics.h>

@interface WCAppDelegate ()

@end

@implementation WCAppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Status bar
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    // Parse
    [Parse setApplicationId:@"p8AF2BKCLQ7fr3oJXPg43fOL6LXAK3mwAb5Ywnke"
                  clientKey:@"1XJhUPLe2s8FFDiNHG7izpTxnU173WsGA4MRGmdh"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [Crashlytics startWithAPIKey:@"7ce2c109a52bd76cf97eacb387877d4289329a2d"];    
    
#ifdef __IPHONE_8_0
    //Right, that is the point
    if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
#endif
    //register to receive notifications
    UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    
    
    UIViewController *mainVC;
    
    if (![[WCSettings sharedSettings] hasChosenCategory]) {
        UIStoryboard *oobe = [UIStoryboard storyboardWithName:@"OOBE" bundle:[NSBundle mainBundle]];
        UIViewController *choose = [oobe instantiateViewControllerWithIdentifier:@"OOBE"];
        mainVC = choose;
    }
    else {
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *main = [mainSB instantiateInitialViewController];
        mainVC = main;
    }
    
    self.window.rootViewController = mainVC;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [Apsalar startSession:@"sickaf" withKey:@"JOrEiHc9"];
    [Apsalar setBatchesEvents:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [Apsalar startSession:@"sickaf" withKey:@"JOrEiHc9" andURL:url];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

#endif


@end

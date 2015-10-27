//
//  AppDelegate.m
//  iTravelPocket
//
//  Created by Joanna on 2015/4/20.
//  Copyright (c) 2015年 Joanna. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import "GAITracker.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize mmDrawerController;
@synthesize exchangeRateForNTDController;
@synthesize rightDrawerController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Initialize database.
    [self createDatabase];
    
    // >>> Google Analytics <<<
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-65312459-1"];
    // Enable IDFA collection.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    
    // Light content, for use on dark backgrounds.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Setting center, right or left drawer of mmDrawerController.
    exchangeRateForNTDController = [[ExchangeRateForNTD alloc] initWithNibName:[[Utility sharedInstance]  xibFileName:@"ExchangeRateForNTD"] bundle:nil];
    rightDrawerController = [[RightDrawerController alloc] initWithNibName:[[Utility sharedInstance]xibFileName:@"RightDrawerController"] bundle:nil];
    
    mmDrawerController = [[MMDrawerController alloc]
                          initWithCenterViewController:exchangeRateForNTDController
                          leftDrawerViewController:nil
                          rightDrawerViewController:rightDrawerController];
    MyNavigationController *navigationController = [[MyNavigationController alloc] initWithRootViewController:mmDrawerController];
    navigationController.navigationBarHidden = YES;
    
    NSLog(@"[%@ : %@] mmDrawerController=%@ mmDelegate=%@",
          NSStringFromClass([self class]),
          NSStringFromSelector(_cmd),
          mmDrawerController,
          mmDrawerController.centerViewController);
    [exchangeRateForNTDController setMMDrawerDelegate];
    
    [mmDrawerController setMaximumRightDrawerWidth:150.0];
    [mmDrawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [mmDrawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window.rootViewController = navigationController;
    
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

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)createDatabase {
    // Home Path: /var/mobile/Containers/Data/Application/E42AF3AB-53EC-4278-9E26-80BD4CE9BBFD
    NSString *homePath = NSHomeDirectory();
    NSLog(@"[%@ : %@] homePath = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), homePath);
    
    // Document Path: /var/mobile/Containers/Data/Application/E42AF3AB-53EC-4278-9E26-80BD4CE9BBFD/Documents
    NSArray *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [docDirectory objectAtIndex:0];
    NSLog(@"[%@ : %@] docDirectory = %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), documentPath);
    
    NSString *dbDirectory = [documentPath stringByAppendingPathComponent:@"database"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbDirectory])
    {
        // New dbPath.
        [[NSFileManager defaultManager] createDirectoryAtPath:dbDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *dbPath = [dbDirectory stringByAppendingPathComponent:@"iTravelEx.db"];
    
    self.fmdbq = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    NSLog(@"[%@] fmdbq = %@", NSStringFromClass([self class]), self.fmdbq);
    
    [self.fmdbq inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS rateTable (id INTEGER PRIMARY KEY AUTOINCREMENT, currency TEXT, select_rate TEXT, rate FLOAT, updateTime TEXT)"];
        [db executeUpdate:@"CREATE TABLE IF NOT EXISTS abTable (id INTEGER PRIMARY KEY AUTOINCREMENT, filename TEXT, travel_country TEXT DEFAULT NULL, currency1 TEXT DEFAULT NULL, currency2 TEXT DEFAULT NULL)"];
    }];
}

@end

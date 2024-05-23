//
//  AppDelegate.m
//  ECoreEngineDemo
//
//  Created by migu on 2022/2/7.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "GLESDemoController.h"
#import "NewSceneViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //......
    CGRect screenBounds = [[UIScreen mainScreen] bounds] ;
    self.window = [[UIWindow alloc] initWithFrame: screenBounds]; //window的大小始终是垂直方向。
    
    GLESDemoController* rootPage = [[GLESDemoController alloc] init];
//    NewSceneViewController* rootPage = [[NewSceneViewController alloc] init];
    UINavigationController* navigator = [[UINavigationController alloc] initWithRootViewController:rootPage];
    [navigator setNavigationBarHidden:true];
    
    self.rootvc = navigator;
    
    self.window.rootViewController = navigator ;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end

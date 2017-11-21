//
//  AppDelegate.m
//  WindowDemo
//
//  Created by xqwang on 2017/4/17.
//
//

#import "AppDelegate.h"
#import "YDAssistiveTouch.h"

@interface AppDelegate ()

@property(nonatomic, strong)YDAssistiveTouch* touch;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController* topVC = [[UIViewController alloc] init];
    [topVC.view setBackgroundColor:[UIColor whiteColor]];
    [self.window setRootViewController:topVC];
    [self.window makeKeyAndVisible];
    
    self.touch = [[YDAssistiveTouch alloc] init];
    
    UIButton* firstTool = [[UIButton alloc] init];
    [firstTool setTag:100];
    [firstTool setImage:[UIImage imageNamed:@"float_window"] forState:UIControlStateNormal];
    [firstTool addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* secondTool = [[UIButton alloc] init];
    [secondTool setTag:200];
    [secondTool setImage:[UIImage imageNamed:@"float_window"] forState:UIControlStateNormal];
    [secondTool addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* thirdTool = [[UIButton alloc] init];
    [thirdTool setTag:300];
    [thirdTool setImage:[UIImage imageNamed:@"float_window"] forState:UIControlStateNormal];
    [thirdTool addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* lastTool = [[UIButton alloc] init];
    [lastTool setTag:400];
    [lastTool setImage:[UIImage imageNamed:@"float_window"] forState:UIControlStateNormal];
    [lastTool addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray* tools = [NSArray arrayWithObjects:firstTool, secondTool, thirdTool, lastTool, nil];
    [self.touch setTools:tools];
    [self.touch showWindow];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)btnClick:(id)sender
{
    NSInteger tag = [sender tag];
    if (tag == 100) {
        [self.touch setWindowStatus:DialogWindow];
        UIViewController* vc = [[UIViewController alloc] init];
        [vc.view setBackgroundColor:[UIColor yellowColor]];
        [self.touch setRootViewController:vc];
    }else if (tag == 200){
        [self.touch setWindowStatus:MainWindow];
        UIViewController* vc = [[UIViewController alloc] init];
        [vc.view setBackgroundColor:[UIColor redColor]];
        [self.touch setRootViewController:vc];
    }else if (tag == 300){
        
    }else {
        
    }
}

@end

#import "FTPClientAppDelegate.h"
#import "FTPClientViewController.h"

@implementation FTPClientAppDelegate

// プロパティとメンバー変数の設定
@synthesize window=_window;
@synthesize viewController=_viewController;

// アプリケーションの初期化
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // ナビゲーションコントローラの用意
    navController = [[UINavigationController alloc]
                     initWithRootViewController:self.viewController];
    
    // ナビゲーションバーを隠す
    [navController setNavigationBarHidden:YES];
    
    // ナビゲーションコントローラの先頭のビューを表示する
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    [navController release];
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end

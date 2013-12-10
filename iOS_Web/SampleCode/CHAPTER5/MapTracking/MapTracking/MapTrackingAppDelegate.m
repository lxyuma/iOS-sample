#import "MapTrackingAppDelegate.h"
#import "MapTrackingViewController.h"

// 「MapTrackingAppDelegate」クラスの実装
@implementation MapTrackingAppDelegate

// プロパティとメンバー変数の設定
@synthesize window;
@synthesize viewController;

// アプリケーション起動時の処理
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // ナビゲーションコントローラを作成する
    _navController = [[UINavigationController alloc]
                      initWithRootViewController:viewController];
    
    // ナビゲーションバーは使用しないので隠す
    [_navController setNavigationBarHidden:YES];
    
    // ナビゲーションツールバーは使用するので表示する
    [_navController setToolbarHidden:NO];
    
    // ウインドウにナビゲーションコントローラを追加する
    self.window.rootViewController = _navController;
    
    // ウインドウを表示する
    [self.window makeKeyAndVisible];
	
    return YES;
}

// アプリケーションがサスペンドされるときに呼ばれるメソッド
- (void)applicationWillResignActive:(UIApplication *)application
{
}

// アプリケーションがバックグラウンドになるときに呼ばれるメソッド
- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

// アプリケーションが最前面になるときに呼ばれるメソッド
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

// アプリケーションがアクティブになった直後に呼ばれるメソッド
- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

// アプリケーションが終了される直前に呼ばれるメソッド
- (void)applicationWillTerminate:(UIApplication *)application
{
}

// メモリー不足のときに呼ばれるメソッド
- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
}

// 解放処理
- (void)dealloc
{
    [_navController release];
    [viewController release];
    [window release];
    [super dealloc];
}


@end

#import "MessagePushAppDelegate.h"
#import "MessagePushViewController.h"

// 「MessagePushAppDelegate」クラスの実装
@implementation MessagePushAppDelegate

// プロパティとメンバー変数の設定
@synthesize window = _window;
@synthesize viewController = _viewController;

// アプリケーションが起動した直後に呼ばれるメソッド
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // ビューを表示する
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
    return YES;
}

// 解放処理
- (void)dealloc
{
    [_viewController release];
    [_window release];
    [super dealloc];
}

// APNsにデバイスを登録できたときに呼ばれるメソッド
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // このサンプルアプリケーションでは、ビューコントローラ側で処理する
    [self.viewController
     didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// APNsにデバイスを登録できなかったときに呼ばれるメソッド
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // このサンプルアプリケーションでは、ビューコントローラ側で処理する
    [self.viewController
     didFailToRegisterForRemoteNotificationsWithError:error];
}

// プッシュ通知を受け取ったときに呼ばれるメソッド
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // このサンプルアプリケーションでは、ビューコントローラ側で処理する
    [self.viewController didReceiveRemoteNotification:userInfo];
}

@end

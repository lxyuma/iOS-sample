#import <UIKit/UIKit.h>

// 「MapTrackingViewController」クラスが存在することを宣言する
@class MapTrackingViewController;

// 「MapTrackingAppDelegate」クラスのインターフェイス宣言
@interface MapTrackingAppDelegate : NSObject <UIApplicationDelegate>
{
    // ウインドウ
    UIWindow *window;
    
    // 地図を表示するビューのビューコントローラ
    MapTrackingViewController *viewController;
    
    // ナビゲーションコントローラ
    UINavigationController *_navController;
}

// プロパティの定義
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet
	MapTrackingViewController *viewController;

@end


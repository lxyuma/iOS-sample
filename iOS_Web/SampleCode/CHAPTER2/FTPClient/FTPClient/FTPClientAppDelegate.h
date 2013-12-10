#import <UIKit/UIKit.h>

@class FTPClientViewController;

// 「FTPClientAppDelegate」クラスの宣言
@interface FTPClientAppDelegate : NSObject <UIApplicationDelegate>
{
    // ナビゲーションコントローラ
    UINavigationController *navController;
}

// プロパティの定義
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) 
    IBOutlet FTPClientViewController *viewController;

@end

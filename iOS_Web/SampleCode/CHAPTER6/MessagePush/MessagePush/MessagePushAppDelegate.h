#import <UIKit/UIKit.h>

// 「MessagePushViewController」クラスが存在することを宣言する
@class MessagePushViewController;

// 「MessagePushAppDelegate」クラスのインターフェイス宣言
@interface MessagePushAppDelegate : NSObject <UIApplicationDelegate>
{
}

// プロパティ定義
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MessagePushViewController *viewController;

@end


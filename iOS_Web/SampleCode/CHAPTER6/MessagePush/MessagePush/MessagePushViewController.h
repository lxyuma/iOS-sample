#import <UIKit/UIKit.h>

// 「ConnectionViewController」クラスが存在することを宣言する
@class ConnectionViewController;

// 「MessagePushViewController」クラスのインターフェイス宣言
@interface MessagePushViewController : UIViewController
{
    // プッシュ通知を受け取るか設定するスイッチ
    UISwitch *_receiveNotificationSwitch;
    
    // 通信画面
    ConnectionViewController *_connectionViewController;
    
    // メッセージを表示するラベル
    UILabel *_messageLabel;
}

// プロパティの定義
@property (nonatomic, retain) 
	IBOutlet UISwitch *receiveNotificationSwitch;
@property (nonatomic, retain) 
	ConnectionViewController *connectionViewController;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;

// プッシュ通知を受け取るか設定するスイッチの状態を
// 変更したときに呼ばれるメソッド
- (IBAction)toggleReceiveNotification:(id)sender;

// APNsにデバイスを登録できたときに呼ばれるメソッド
- (void)didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)deviceToken;

// バイナリデータを16進ダンプした文字列に変換する
- (NSString *)hexDumpString:(NSData *)data;

// POSTで渡せるように、辞書に格納された文字列から
// 「application/x-www-form-urlencoded」形式の
// データを作成する
- (NSData *)formEncodedDataFromDictionary:(NSDictionary *)dict;

// APNsにデバイスを登録できなかったときに呼ばれるメソッド
- (void)didFailToRegisterForRemoteNotificationsWithError:
(NSError *)error;

// プッシュ通知を受け取ったときに呼び出すメソッド
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end


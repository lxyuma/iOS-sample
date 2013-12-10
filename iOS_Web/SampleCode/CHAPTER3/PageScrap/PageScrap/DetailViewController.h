#import <UIKit/UIKit.h>

// 「ConnectionViewController」クラスが存在することを宣言
@class ConnectionViewController;

// 「DetailViewController」クラスの宣言
@interface DetailViewController : UIViewController
{
    // URLを表示するラベル
    UILabel *_urlLabel;
    
    // 内容を表示するテキストビュー
    UITextView *_contentTextView;
    
    // 通信画面
    ConnectionViewController *_connectionViewController;
    
    // 表示する情報のID
    NSString *_recordID;
}

// プロパティの定義
@property (retain, nonatomic) IBOutlet UILabel *urlLabel;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (retain, nonatomic) NSString *recordID;
@property (retain, nonatomic)
ConnectionViewController *connectionViewController;

// アクションの定義
- (IBAction)openURL:(id)sender;

// 受信したデータを解析して、表示情報を設定するメソッド
- (void)reloadFromReceivedData;

@end

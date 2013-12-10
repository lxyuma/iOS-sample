#import <UIKit/UIKit.h>

// 「ServiceInfoViewController」クラスのインターフェイス宣言
@interface ServiceInfoViewController : UIViewController
<NSNetServiceDelegate>
{
    // ネットサービス
    NSNetService *_netService;
    
    // 情報を表示するテキストビュー
    UITextView *_textView;
}

// プロパティの定義
@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, retain) IBOutlet UITextView *textView;

// ネットサービスの情報をテキストビューに表示する処理
- (void)showNetServiceInfo;

@end

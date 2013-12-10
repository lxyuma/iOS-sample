#import <UIKit/UIKit.h>

// 「FTPClientViewController」クラスのインターフェイス宣言
@interface FTPClientViewController : UIViewController
<UITextFieldDelegate>
{
    // FTPサーバアドレスを入力するテキストフィールド
    UITextField *_urlField;
    // ユーザー名を入力するテキストフィールド
    UITextField *_userNameField;
    // パスワードを入力するテキストフィールド
    UITextField *_passwordField;
    // 「Login」ボタン
    UIButton *_loginButton;
}

// プロパティの定義
@property (retain, nonatomic) IBOutlet UITextField *urlField;
@property (retain, nonatomic) IBOutlet UITextField *userNameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;

// 「Login」ボタンの処理
- (IBAction)login:(id)sender;

@end

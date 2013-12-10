#import <UIKit/UIKit.h>

@interface AccountEditViewController : UIViewController
<UITextViewDelegate>
{
    // ユーザー名を入力するテキストフィールド
    UITextField     *_userNameField;
    
    // パスワードを入力するテキストフィールド
    UITextField     *_passwordField;
    
    // 認証要求
    NSURLAuthenticationChallenge    *_authenticationChallenge;
}
// プロパティの定義
@property (retain, nonatomic) IBOutlet UITextField *userNameField;
@property (retain, nonatomic) IBOutlet UITextField *passwordField;
@property (retain, nonatomic)
NSURLAuthenticationChallenge* authenticationChallenge;

// 「Log In」ボタンの処理
- (IBAction)logIn:(id)sender;

// 「Cancel」ボタンの処理
- (IBAction)cancel:(id)sender;

@end

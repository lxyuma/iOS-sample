#import "AccountEditViewController.h"

@implementation AccountEditViewController

// プロパティとメンバー変数の設定
@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize authenticationChallenge = _authenticationChallenge;

// nibファイルを使って初期化するイニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _authenticationChallenge = nil;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_authenticationChallenge release];
    [_userNameField release];
    [_passwordField release];
    [super dealloc];
}

// ソフトウェアキーボードの「Next」ボタン、もしくは
// 「Go」ボタンが押されたときの処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.userNameField])
    {
        // ユーザー名入力フィールドのときは、
        // パスワード入力フィールドに移動する
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    else if ([textField isEqual:self.passwordField])
    {
        // パスワード入力フィールドのときは、
        // 「Log In」ボタンが押されたときの処理を行う
        [self logIn:nil];
        return NO;
    }
    else
    {
        return YES; // デフォルトの処理を行う
    }
}

// 指定された方向に対応するかどうかを返す
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも対応する
    return YES;
}

// 「Log In」ボタンの処理
- (IBAction)logIn:(id)sender
{
    // 認証を行う必要があるか
    NSURLAuthenticationChallenge *challenge;
    challenge = self.authenticationChallenge;
	
    if (challenge)
    {
        // 認証情報を作成する
        NSURLCredential *credential;
        
        credential = [NSURLCredential
                      credentialWithUser:self.userNameField.text
                      password:self.passwordField.text
					  persistence:NSURLCredentialPersistenceForSession];
        
        // 認証を行う
        [[challenge sender] useCredential:credential
               forAuthenticationChallenge:challenge];
    }
    
    // モーダル処理終了
    // アニメーション中に「DownloadViewController」クラス内の
    // 「dismissModalViewControllerAnimated:」メソッドが
    // 呼ばれることを防止するために、ここではアニメーションしない
    [self dismissModalViewControllerAnimated:NO];
}

// 「Cancel」ボタンの処理
- (IBAction)cancel:(id)sender
{
    // 認証をキャンセルする
    NSURLAuthenticationChallenge *challenge;
    challenge = self.authenticationChallenge;
	
    [[challenge sender] cancelAuthenticationChallenge:challenge];
	
    // モーダル処理終了
    // アニメーション中に「DownloadViewController」クラス内の
    // 「dismissModalViewControllerAnimated:」メソッドが
    // 呼ばれることを防止するために、ここではアニメーションしない
    [self dismissModalViewControllerAnimated:NO];
}

@end

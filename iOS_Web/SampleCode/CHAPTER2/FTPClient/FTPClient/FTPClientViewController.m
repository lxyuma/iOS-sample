#import "FTPClientViewController.h"
#import "FTPBrowseViewController.h"

@implementation FTPClientViewController

// プロパティとメンバー変数の設定
@synthesize urlField = _urlField;
@synthesize userNameField = _userNameField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;

// 解放処理
- (void)dealloc
{
    [_loginButton release];
    [_urlField release];
    [_userNameField release];
    [_passwordField release];
    [super dealloc];
}

// 「Login」ボタンの処理
- (IBAction)login:(id)sender
{
    // ソフトウェアキーボードを隠す
    [self.urlField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    
    
    // URLを作成する
    NSURL *url = [NSURL URLWithString:self.urlField.text];
    
    if (!url)
    {
        // URLが作成できないときはエラー表示
        NSString *errMsg, *errTitle, *cancelButton;
        UIAlertView *alertView;
        
        // 表示する文字列
        errTitle = @"Error";
        errMsg = @"The URL is invalid.";
        cancelButton = @"OK";
        
        // アラートビューを表示する
        alertView = [[UIAlertView alloc] initWithTitle:errTitle
                                               message:errMsg
                                              delegate:nil
                                     cancelButtonTitle:cancelButton
                                     otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        
        // 処理終了
        return;
    }
    
    // 読み込みストリームを作成する
    CFReadStreamRef readStream = nil;
    BOOL ret = NO;
    
    readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault,
                                              (CFURLRef)url);
    if (readStream)
    {
        // ユーザー名とパスワードを読み込みストリームに設定する
        CFReadStreamSetProperty(readStream,
                                kCFStreamPropertyFTPUserName,
                                (CFTypeRef)self.userNameField.text);
        CFReadStreamSetProperty(readStream, 
                                kCFStreamPropertyFTPPassword,
                                (CFTypeRef)self.passwordField.text);
        
        // パッシブモードで接続するかどうかを設定する
        // ここではパッシブモードで接続する
        CFReadStreamSetProperty(readStream,
                                kCFStreamPropertyFTPUsePassiveMode,
                                (CFTypeRef)kCFBooleanTrue);
        
        // ストリームを開く
        ret = CFReadStreamOpen(readStream);
        
        // 接続されるまで待機する
        if (ret)
        {
            while (1)
            {
                NSAutoreleasePool *pool =
				[[NSAutoreleasePool alloc] init];
                
                // 状態を取得する
                CFStreamStatus status;
                
                status = CFReadStreamGetStatus(readStream);
                if (status == kCFStreamStatusOpen)
                {
                    // 接続完了
                    ret = YES;
                    [pool drain];
                    break;
                }
                else if (status != kCFStreamStatusOpening)
                {
                    // エラーが発生した
                    ret = NO;
                    [pool drain];
                    break;
                }
                
                // まだ、接続処理中なのでランループを走らせる
                [[NSRunLoop currentRunLoop] runUntilDate:
                 [NSDate dateWithTimeIntervalSinceNow:0.1]];
                
                [pool drain];
            }
        }
    }
    
    if (ret)
    {
        // 接続成功
        // FTPブラウズ画面を表示する
        FTPBrowseViewController *vc;
        
        vc = [[FTPBrowseViewController alloc]
              initWithNibName:nil bundle:nil];
        
        // ユーザー名を設定する
        [vc setUserName:self.userNameField.text];
        
        // パスワードを設定する
        [vc setPassword:self.passwordField.text];
        
        // URLを設定する
        [vc setDirectoryURL:url];
        
        // ビューを表示する
        [[self navigationController] pushViewController:vc
                                               animated:YES];
        [vc release];
    }
    else
    {
        // 接続失敗
        // エラーメッセージを表示する
        NSString *errMsg, *errTitle, *cancelButton;
        UIAlertView *alertView;
        
        // 表示する文字列
        errTitle = @"Error";
        errMsg = @"Couldn't open the connection.";
        cancelButton = @"OK";
        
        // アラートビューを表示する
        alertView = [[UIAlertView alloc] initWithTitle:errTitle
                                               message:errMsg
                                              delegate:nil
                                     cancelButtonTitle:cancelButton
                                     otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    // ストリームを閉じて解放する
    if (readStream)
    {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
}

// ソフトウェアキーボードでリターンキーが押されたときの処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL ret = NO;
    
    // どのテキストフィールドかを判定する
    if ([self.urlField isEqual:textField])
    {
        // URLを入力するテキストフィールド
        // ユーザー名を入力するテキストフィールドに移動する
        [self.userNameField becomeFirstResponder];
    }
    else if ([self.userNameField isEqual:textField])
    {
        // ユーザー名を入力するテキストフィールド
        // パスワードを入力するテキストフィールドに移動する
        [self.passwordField becomeFirstResponder];
    }
    else if ([self.passwordField isEqual:textField])
    {
        // パスワードを入力するテキストフィールド
        // ログインを実行する
        [self.passwordField resignFirstResponder];
        [self login:nil];
    }
    else
    {
        // デフォルトの処理を行う
        ret = YES;
    }
    
    return ret;
}

// ビューが表示されるときの処理
- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewWillAppear:animated];
    
    // ナビゲーションバーを非表示にする
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
    
    // ツールバーを非表示にする
    [self.navigationController setToolbarHidden:YES
                                       animated:animated];
}

@end

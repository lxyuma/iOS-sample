#import "DownloadViewController.h"
#import "AccountEditViewController.h"

// HTTPステータスコードを渡すということを通知するためのエラードメイン
static NSString *HTTPErrorDomain = @"HTTPErrorDomain";

@implementation DownloadViewController

// プロパティとメンバー変数の設定
@synthesize urlField = _urlField;
@synthesize progressView = _progressView;
@synthesize syncDownloadButton = _syncDownloadButton;
@synthesize asyncDownloadButton = _asyncDownloadButton;
@synthesize urlConnection = _urlConnection;
@synthesize downloadedFileHandle = _downloadedFileHandle;
@synthesize downloadedFilePath = _downloadedFilePath;

// nibファイルを読み込むイニシャライザメソッド
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _urlConnection = nil;
        _downloadedFileHandle = nil;
        _downloadedFilePath = nil;
        _downloadedFileSize = 0;
        _expectedFileSize = 0;
    }
    return self;
}

// インスタンスが解放されるときに呼ばれるメソッド
- (void)dealloc
{
    [_downloadedFilePath release];
    [_downloadedFileHandle release];
    [_urlConnection release];
    [_asyncDownloadButton release];
    [_syncDownloadButton release];
    [_progressView release];
    [_urlField release];
    [super dealloc];
}

// ビューがロードされたときに呼ばれるメソッド
- (void)viewDidLoad
{
    // 親クラスの処理を呼び出す
    [super viewDidLoad];    
}

// 指定された方向に対応するかどうかを返す
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも対応する
    return YES;
}

// ソフトウェアキーボードの「Done」ボタンが押されたときの処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // URLを入力するテキストフィールドかどうをチェックする
    // しかし、実際には、このオブジェクトをデリゲートに指定した
    // テキストフィールドは一つなので、このif文は常に成り立つ
    if ([textField isEqual:self.urlField])
    {
        // ソフトウェアキーボードを閉じる
        [self.urlField resignFirstResponder];
		
        return NO;  // テキストフィールドのデフォルト処理は行わない
    }
    else
    {
        return YES; // テキストフィールドのデフォルト処理を行う
    }
}

// キャンセルボタンの処理
- (IBAction)cancel:(id)sender
{
    // プロパティ「urlConnection」が「nil」でないときは、非同期接続中と見なす
    if (self.urlConnection)
    {
        // 接続処理をキャンセルする
        [self.urlConnection cancel];
        
        // 後処理を呼び出す
        [self connectionDidFailed];
    }
    else
    {
        // ビューコントローラを閉じる
        [self dismissModalViewControllerAnimated:YES];
    }
}

// 同期ダウンロードボタンの処理
- (IBAction)syncDownload:(id)sender
{
	
    // 入力されているURLを取得する
    NSURL *url = [NSURL URLWithString:self.urlField.text];
    
    // URLの構文が間違っているときなど、「NSURL」のインスタンスが
    // 作成できないときはエラーメッセージを表示する
    if (!url)
    {
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
    
    // URLからダウンロードする
    NSError *error = nil;
    NSData *data;
    BOOL isSuccessed = NO;
    
    data = [NSData dataWithContentsOfURL:url
                                 options:0
                                   error:&error];
    
    // ダウンロードに成功したらファイルに保存して、ダウンロード画面を閉じる
    if (data)
    {
        // ダウンロード成功
        // ファイル名を決定する
        NSString *filePath = [self newFilePathWithURL:url];
		
        // ファイルに保存する
        isSuccessed = [data writeToFile:filePath
                                options:NSDataWritingAtomic
                                  error:&error];
    }
    
    // ファイルの保存まで成功したらダウンロード画面を閉じる
    if (isSuccessed)
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    else
    {
        // エラーメッセージを表示する
        NSString *errMsg, *errTitle, *cancelButton;
        UIAlertView *alertView;
        
        // 表示する文字列
        errTitle = @"Download Error";
        cancelButton = @"OK";
        errMsg = @"Couldn't download the file. ";
		
        // エラー情報が取得できたときは、エラー情報からの文字列を追加する
        if (error)
        {
            errMsg = [errMsg stringByAppendingString:
                      [error localizedDescription]];
        }
        
        // アラートビューを表示する
        alertView = [[UIAlertView alloc] initWithTitle:errTitle
                                               message:errMsg
                                              delegate:nil
                                     cancelButtonTitle:cancelButton
                                     otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

// 新しいファイルのファイルパスを取得する
- (NSString *)newFilePathWithURL:(NSURL *)url
{
    // URLからベースになっているファイル名を取得する
    NSString *baseName = [[[url path] lastPathComponent]
                          stringByDeletingPathExtension];
    
    // ファイル名が取得できなかったときは、固定の名前を使用する
    if ([baseName length] == 0 || [baseName isEqual:@"/"])
    {
        baseName = @"NewFile";
    }
    
    // 拡張子を取得する
    NSString *extension = [[url path] pathExtension];
    
    // 「Documents」ディレクトリのパスを取得する
    NSString *docDirPath =
	[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
										 NSUserDomainMask,
										 YES) lastObject];
    
    // ループさせながらユニークなファイル名を決定する
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInteger counter = 1;
    NSString *newFilePath = nil;
    
    while (1)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // ファイルパスを作成する
        NSString *tempFilePath;
        
        if (counter == 1)
        {
            // まずは連番をつけずに、元ファイルの名前をそのまま使用する
            tempFilePath =
            [docDirPath stringByAppendingPathComponent:baseName];
        }
        else
        {
            // 元ファイルの名前に連番を追加する
            tempFilePath =
            [NSString stringWithFormat:@"%@%d", baseName, counter];
            
            tempFilePath =
            [docDirPath stringByAppendingPathComponent:tempFilePath];
        }
        
        // 拡張子があれば追加する
        if ([extension length] > 0)
        {
            tempFilePath =
            [tempFilePath stringByAppendingPathExtension:extension];
        }
        
        // ファイルが存在するかチェックする
        if (![fileManager fileExistsAtPath:tempFilePath])
        {
            // ユニークなファイル名が決まったので、終了する
            // このループで作成した文字列は「[pool drain];」で
            // 解放されてしまうため、「retain」メソッドを呼んでいる
            newFilePath = [tempFilePath retain];
			[pool drain];
            break;
        }
        
        counter++;
        [pool drain];
    }
    
    // ループの中で、「retain」メソッドで参照カウンタが増やされているため
    // 「autorelease」メソッドを呼び出してから戻す
    return [newFilePath autorelease];
}

// 非同期ダウンロードボタンの処理
- (IBAction)asyncDownload:(id)sender
{
    // 入力されているURLを取得する
    NSURL *url = [NSURL URLWithString:self.urlField.text];
    
    // URLの構文が間違っているときなど、「NSURL」のインスタンスが
    // 作成できないときはエラー
    if (!url)
    {
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
    
    // ソフトウェアキーボードを非表示にする
    [self.urlField resignFirstResponder];
    
    // ダウンロードしたファイルを書き込むファイルを作成する
    NSString *filePath = [self newFilePathWithURL:url];
    
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:nil
                                          attributes:nil];
    [self setDownloadedFilePath:filePath];
    
    
    [self setDownloadedFileHandle:
     [NSFileHandle fileHandleForWritingAtPath:filePath]];
    
    // 取得要求の作成
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    // 接続開始
    [self setUrlConnection:
     [NSURLConnection connectionWithRequest:urlRequest
                                   delegate:self]];
	
    // ダウンロード中はボタンは無効にする
    [self.syncDownloadButton setEnabled:NO];
    [self.asyncDownloadButton setEnabled:NO];
    
    // プログレスビューをリセットしてから表示する
    [self.progressView setProgress:0];
    [self.progressView setHidden:NO];
	
    // ファイルサイズをクリアする
    _expectedFileSize = _downloadedFileSize = 0;
}

// ダウンロード完了時に呼ばれるメソッド
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // ダウンロードが完了したので、ファイルハンドルを閉じる
    [self.downloadedFileHandle synchronizeFile];
    [self.downloadedFileHandle closeFile];
    [self setDownloadedFileHandle:nil];
    
    // ダウンロード画面を閉じる
    [self dismissModalViewControllerAnimated:YES];
    
    // 接続情報を破棄
    [self setUrlConnection:nil];
    [self setDownloadedFilePath:nil];
}

// 読み込み失敗時に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // エラーメッセージを表示する
    NSString *errMsg, *errTitle, *cancelButton;
    UIAlertView *alertView;
    
    // 表示する文字列
    errTitle = @"Download Error";
    cancelButton = @"OK";
    errMsg = @"Couldn't download the file. ";
    
    // エラー情報が取得できたときは、エラー情報からの文字列を追加する
    if (error)
    {
        errMsg = [errMsg stringByAppendingString:
                  [error localizedDescription]];
    }
    
    // アラートビューを表示する
    alertView = [[UIAlertView alloc] initWithTitle:errTitle
                                           message:errMsg
                                          delegate:nil
                                 cancelButtonTitle:cancelButton
                                 otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    // 後処理を呼び出す
    [self connectionDidFailed];
}

// レスポンスを受け取った直後に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    // もし、「response」が「NSHTTPURLResponse」ならば
    // HTTPのステータスコードもチェックする
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        // HTTPのステータスコードが400以上ならエラー扱いとする
        NSInteger statusCode =
        [(NSHTTPURLResponse *)response statusCode];
        
        if (statusCode >= 400)
        {
            // HTTPのステータスコードとエラーメッセージを渡す
            NSError *error;
            NSString *errStr;
            NSDictionary *userInfo = nil;
            
            errStr = [NSHTTPURLResponse
                      localizedStringForStatusCode:statusCode];
            if (errStr)
            {
                // 「NSError」クラスの「localizedDescription」
                // メソッドで取得されるエラーメッセージを設定する
                userInfo = [NSDictionary dictionaryWithObject:errStr
													   forKey:NSLocalizedDescriptionKey];
            }
            
            error = [NSError errorWithDomain:HTTPErrorDomain
                                        code:statusCode
                                    userInfo:userInfo];
            [self connection:connection
            didFailWithError:error];
            
            return;
        }
    }
    
    // ダウンロードするファイルのファイルサイズを取得する
    _expectedFileSize = [response expectedContentLength];
}

// データ受信時に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    // 受信したデータをファイルに書き込む
    [self.downloadedFileHandle writeData:data];
    
    // ダウンロードするファイルのファイルサイズが取得できていたら
    // プログレスビューを更新する
    _downloadedFileSize += [data length];
    
    if (_expectedFileSize > 0)
    {
        [self.progressView setProgress:
         (double)_downloadedFileSize / (double)_expectedFileSize];
    }
}

// 接続処理失敗時の後処理を行う
- (void)connectionDidFailed
{
    // ダウンロードが失敗したので、ファイルを閉じる
    [self.downloadedFileHandle synchronizeFile];
    [self.downloadedFileHandle closeFile];
    [self setDownloadedFileHandle:nil];
    
    // 中途半端になっているので、ファイルも削除する
    [[NSFileManager defaultManager]
     removeItemAtPath:self.downloadedFilePath
     error:NULL];
    
    // ダウンロードに関する情報を破棄する
    [self setUrlConnection:nil];
    [self setDownloadedFilePath:nil];
    
    // URLを入力し直して、ダウンロードできるようにボタンを
    // 有効化する
    [self.syncDownloadButton setEnabled:YES];
    [self.asyncDownloadButton setEnabled:YES];
    
    // プログレスビューを非表示
    [self.progressView setHidden:YES];
}

//// 認証情報が要求されたときに呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:
(NSURLAuthenticationChallenge *)challenge
{
    // 認証の失敗回数を取得する
    NSInteger count = [challenge previousFailureCount];
    
    if (count == 0)
    {
        // 最初の認証要求なのでアカウント入力画面を表示する
        NSString *method;
        method = [[challenge protectionSpace] authenticationMethod];
        
        // HTTPベーシック認証のみ対応する
        if ([method isEqualToString:
             NSURLAuthenticationMethodHTTPBasic])
        {
            // アカウント入力画面を表示する
            AccountEditViewController *accountView;
            
            accountView = [[AccountEditViewController alloc]
                           initWithNibName:nil
                           bundle:nil];
            [accountView setAuthenticationChallenge:challenge];
            [self presentModalViewController:accountView
                                    animated:YES];
            [accountView release];
        }
        else
        {
            // 対応していない認証方法なのでキャンセルして、
            // エラーメッセージを表示する
            [[challenge sender]
             cancelAuthenticationChallenge:challenge];
            
            // エラーメッセージを表示する
            NSString *title = @"Authentication Error";
            NSString *msg =
			@"The authentication method is not supported.";
            
            UIAlertView *alertView;
            
            alertView = [[UIAlertView alloc] initWithTitle:title
                                                   message:msg
                                                  delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
        }
    }
    else
    {
        // 既に失敗しているのでキャンセルして、エラーメッセージを表示する
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        
        // エラーメッセージを表示する
        NSString *title = @"Authentication Error";
        NSString *msg = @"User Name or Password is invalid";
        UIAlertView *alertView;
        
        alertView = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil];
        
        [alertView show];
        [alertView release];
    }
}


@end

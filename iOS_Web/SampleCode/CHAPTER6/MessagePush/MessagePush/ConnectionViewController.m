#import "ConnectionViewController.h"

// HTTPのステータスコードを格納したエラー情報を示すドメイン
static NSString *HTTPErrorDomain = @"HTTPErrorDomain";

@implementation ConnectionViewController

// プロパティとメンバー変数の設定
@synthesize urlRequest = _urlRequest;
@synthesize connection = _connection;
@synthesize downloadedData = _downloadedData;
@synthesize response = _response;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数の初期化
        _urlRequest = nil;
        _connection = nil;
        _downloadedData = nil;
        _response = nil;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_urlRequest release];
    [_connection release];
    [_downloadedData release];
    [_response release];
    [super dealloc];
}

// デバイスを回転させるか判定する処理
- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation
{
    // どの方向でも回転させる
    return YES;
}

// ビューが表示された直後に呼ばれるメソッド
// ここでは、通信を始める
- (void)viewDidAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewDidAppear:animated];
    
    // 接続要求を取得する
    NSURLRequest *request = self.urlRequest;
    if (!request)
    {
        // 接続要求が設定されていなければエラーを表示して閉じる
        UIAlertView *alert;
        
        alert = [[UIAlertView alloc]
                 initWithTitle:@"Connection Error"
                       message:@"Couldn't open the connection"
                      delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        // 通信画面を閉じる
        // 即座に閉じたいのでアニメーションは行わない
        [self dismissModalViewControllerAnimated:NO];
        return;
    }
    
    // ダウンロードデータのクリア
    [self setDownloadedData:nil];
    // レスポンスのクリア
    [self setResponse:nil];
    
    // 接続開始
    [self setConnection:[NSURLConnection connectionWithRequest:request
                                                      delegate:self]];
}

// データ取得完了時に呼ばれるメソッド
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 通信画面を閉じる
    // 即座に閉じたいのでアニメーションは行わない
    [self dismissModalViewControllerAnimated:NO];
}

// データ取得失敗時に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // エラーメッセージを表示する
    UIAlertView *alert;
    NSString *errMsg = @"Error occurred. ";
    
    // エラー情報が取得できたときは、情報を結合する
    if (error)
    {
        errMsg = [errMsg stringByAppendingString:
                  [error localizedDescription]];
    }
    
    alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                       message:errMsg
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    // 通信画面を閉じる
    // 即座に閉じたいのでアニメーションは行わない
    [self dismissModalViewControllerAnimated:NO];
}

// レスポンスを受け取った直後に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    // レスポンスを記憶する
    [self setResponse:response];
    
    // もし、「response」が「NSHTTPURLResponse」ならば
    // HTTPのステータスコードもチェックする
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        // HTTPのステータスコードが400以上ならエラー扱いとする
        NSInteger statusCode = 
        [(NSHTTPURLResponse *)response statusCode];
        
        if (statusCode >= 400)
        {
            // 通信を中断する
            [connection cancel];
            
            // エラー情報を構築する
            NSError *error;
            NSString *errStr;
            NSDictionary *userInfo = nil;
            
            errStr = [NSHTTPURLResponse
                      localizedStringForStatusCode:statusCode];
            if (errStr)
            {
                // 「NSError」クラスの「localizedDescription」
                // メソッドで取得されるエラーメッセージを表示する
                userInfo = [NSDictionary dictionaryWithObject:errStr
                                   forKey:NSLocalizedDescriptionKey];
            }
            
            error = [NSError errorWithDomain:HTTPErrorDomain
                                        code:statusCode
                                    userInfo:userInfo];
            // エラー発生時の処理を呼び出す
            [self connection:connection
            didFailWithError:error];
        }
    }
}

// データ受信時に呼ばれるメソッド
- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    // 格納先のバッファを確保する
    NSMutableData *downloadedData = self.downloadedData;
    
    if (!downloadedData)
    {
        // 格納先のバッファを確保する
        downloadedData = [NSMutableData dataWithCapacity:0];
        [self setDownloadedData:downloadedData];
    }
    
    // 受信したデータを追加する
    [downloadedData appendData:data];
}

// キャンセルボタンが押されたときのメソッド
- (IBAction)cancel:(id)sender
{
    // 通信処理をキャンセルする
    [self.connection cancel];
    
    // 通信画面を閉じる
    [self dismissModalViewControllerAnimated:NO];
}

@end

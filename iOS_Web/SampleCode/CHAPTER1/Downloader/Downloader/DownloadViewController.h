#import <UIKit/UIKit.h>

// 「DownloadViewController」クラスのインターフェイス宣言
@interface DownloadViewController : 
UIViewController<UITextFieldDelegate>
{
    // URLを入力するテキストフィールド
    UITextField     *_urlField;
    
    // プログレスビュー
    UIProgressView  *_progressView;
    
    // 「Sync Download」ボタン
    UIButton        *_syncDownloadButton;
    
    // 「Async Download」ボタン
    UIButton        *_asyncDownloadButton;
    
    // 非同期接続処理の管理
    NSURLConnection *_urlConnection;
    
    // ダウンロード中のデータを書き込むファイルハンドル
    NSFileHandle    *_downloadedFileHandle;
    
    // ダウンロード中のファイルのファイルパス
    NSString        *_downloadedFilePath;
    
    // ダウンロード済みのファイルサイズ
    long long       _downloadedFileSize;
    
    // ダウンロードするファイルのファイルサイズ
    long long       _expectedFileSize;
}

// プロパティの定義
@property(retain, nonatomic) IBOutlet UITextField *urlField;
@property(retain, nonatomic) IBOutlet UIProgressView *progressView;
@property(retain, nonatomic) IBOutlet UIButton *syncDownloadButton;
@property(retain, nonatomic) IBOutlet UIButton *asyncDownloadButton;
@property(retain, nonatomic) NSURLConnection *urlConnection;
@property(retain, nonatomic) NSFileHandle *downloadedFileHandle;
@property(copy, nonatomic) NSString *downloadedFilePath;

// キャンセルボタンの処理
- (IBAction)cancel:(id)sender;

// 同期ダウンロードボタンの処理
- (IBAction)syncDownload:(id)sender;

// 非同期ダウンロードボタンの処理
- (IBAction)asyncDownload:(id)sender;

// 新しいファイルのファイルパスを取得する
- (NSString *)newFilePathWithURL:(NSURL *)url;

// 接続処理失敗時の後処理を行う
- (void)connectionDidFailed;

@end

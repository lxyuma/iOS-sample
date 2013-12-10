#import <UIKit/UIKit.h>

// 「TransferViewController」クラスの宣言
@interface TransferViewController : UIViewController
{
    // 転送状況を示すプログレスビュー
    UIProgressView  *_progressView;
    // ラベル
    UILabel         *_label;
    // ユーザー名
    NSString        *_userName;
    // パスワード
    NSString        *_password;
    // 読み込みストリーム
    CFReadStreamRef _readStream;
    // 書き込みストリーム
    CFWriteStreamRef _writeStream;
    // 動作モード
    // YESならアップロード、NOならダウンロード
    BOOL            _uploadMode;
    // アップロードもしくはダウンロードするファイルサイズ
    uint64_t        _fileSize;
    // アップロードもしくはダウンロード済みのデータサイズ
    uint64_t        _transferedSize;
    // リモートURL
    NSURL           *_remoteURL;
    // ローカルURL
    NSURL           *_localURL;
}

// プロパティの定義
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *password;
@property (retain, nonatomic) NSURL *remoteURL;
@property (retain, nonatomic) NSURL *localURL;
@property (assign, nonatomic) uint64_t fileSize;
@property (assign, nonatomic) BOOL uploadMode;

// アップロード開始
- (void)uploadURL:(NSURL *)localURL
            toURL:(NSURL *)remoteURL;

// ダウンロード処理
- (void)downloadURL:(NSURL *)remoteURL
              toURL:(NSURL *)localURL
       withFileSize:(uint64_t)fileSize;

// ストリームを閉じて解放する
- (void)releaseStream;

// FTP上のファイルに対する読み込みストリームを作成する
- (CFReadStreamRef)createFTPReadStream:(NSURL *)url;

// FTP上のファイルに対する書き込みストリームを作成する
- (CFWriteStreamRef)createFTPWriteStream:(NSURL *)url;

// ストリームのイベント処理メソッド
- (void)handleEvent:(CFStreamEventType)event;

// データを受信したときの処理
- (void)handleBytesAvailable;

// データを最後まで受信したときの処理
- (void)handleEndEncountered;

// データを書き込めるとき
- (void)handleCanAcceptBytes;

// エラーが起きたとき
- (void)handleErrorOccurred;

@end

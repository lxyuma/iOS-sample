#import <UIKit/UIKit.h>

// 「FTPBrowseViewController」クラスの宣言
@interface FTPBrowseViewController : UITableViewController
{
    // ユーザー名
    NSString    *_userName;
    // パスワード
    NSString    *_password;
    // ディレクトリのURL
    NSURL       *_directoryURL;
    // ディレクトリ内容
    NSArray *_directoryContents;
    // 読み込みストリーム
    CFReadStreamRef _readStream;
    // 読み込み中のデータ
    NSMutableData *_receivedData;
}

// プロパティの定義
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *password;
@property (retain, nonatomic) NSURL *directoryURL;

// 読み込みストリームを閉じて解放する
- (void)releaseReadStream;

// イベントハンドラメソッド。ストリームに関するイベントを処理する
- (void)handleEvent:(CFStreamEventType)eventType;

// データを受信したとき呼ばれる
- (void)handleHasBytesAvailable;

// 最後まで受信したに呼ばれる
- (void)handleEndEncountered;

// エラーが起きたときに呼ばれる
- (void)handleErrorOccurred;

@end

#import <UIKit/UIKit.h>

// 「ConnectionViewController」クラスの宣言
@interface ConnectionViewController : UIViewController
{
    // 接続要求
    NSURLRequest *_urlRequest;
    
    // サーバとの通信管理
    NSURLConnection *_connection;
    
    // ダウンロードしたデータ
    NSMutableData *_downloadedData;
    
    // サーバからのレスポンス
    NSURLResponse *_response;
}

// プロパティの定義
@property (retain, nonatomic) NSURLRequest *urlRequest;
@property (retain, nonatomic) NSURLConnection *connection;
@property (retain, nonatomic) NSMutableData *downloadedData;
@property (retain, nonatomic) NSURLResponse *response;

// アクションの定義
- (IBAction)cancel:(id)sender;

@end

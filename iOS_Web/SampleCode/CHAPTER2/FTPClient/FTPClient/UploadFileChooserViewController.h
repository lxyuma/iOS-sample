#import <UIKit/UIKit.h>

// 「UploadFileChooserViewController」クラスの宣言
@interface UploadFileChooserViewController : UITableViewController
{
    // テーブルビューに表示するファイルの配列
    NSArray *_pathArray;
    // アップロード先のディレクトリ
    NSURL *_remoteDirURL;
    // ユーザー名
    NSString *_userName;
    // パスワード
    NSString *_password;
}

// プロパティの定義
@property (retain, nonatomic) NSArray *pathArray;
@property (retain, nonatomic) NSURL *remoteDirURL;
@property (retain, nonatomic) NSString *userName;
@property (retain, nonatomic) NSString *password;

@end

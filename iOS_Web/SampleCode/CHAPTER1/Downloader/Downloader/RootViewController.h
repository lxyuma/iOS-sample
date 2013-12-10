#import <UIKit/UIKit.h>

// 「RootViewController」クラスのインターフェイス宣言
@interface RootViewController : UITableViewController
{
    // ファイルパスの配列
    NSMutableArray *_filePathArray;
}

// プロパティの定義
@property (nonatomic, retain) NSMutableArray *filePathArray;

// 「Documents」ディレクトリ内を走査して、ファイルを取得する
- (NSMutableArray *)scanDocumentsDirectory;

// 対応するファイルかどうかを判定する
- (BOOL)isSupportedFile:(NSString *)filePath;

@end

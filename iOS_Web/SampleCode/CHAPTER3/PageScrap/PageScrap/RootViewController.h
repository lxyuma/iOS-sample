#import <UIKit/UIKit.h>

// 「ConnectionViewController」クラスが存在することを宣言
@class ConnectionViewController;

// 「RootViewController」クラスの宣言
@interface RootViewController : UITableViewController 
{
    // テーブルビューに表示する情報の配列
    // 配列のアイテムは「NSDictionary」クラスのインスタンスとする
    NSArray *_itemArray;
    
    // 通信画面
    ConnectionViewController *_connectionViewController;
}

// プロパティの定義
@property (retain, nonatomic) NSArray *itemArray;
@property (retain, nonatomic) 
ConnectionViewController *connectionViewController;

// 受信したデータを解析して表示項目を設定するメソッド
- (void)reloadFromReceivedData;

@end

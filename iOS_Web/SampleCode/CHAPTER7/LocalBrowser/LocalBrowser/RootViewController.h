#import <UIKit/UIKit.h>

// 「RootViewController」クラスのインターフェイス宣言
@interface RootViewController : UITableViewController
<NSNetServiceBrowserDelegate>
{
	// サーチバー
	UISearchBar *_searchBar;
	
	// ネットサービスを検索するためのサービスブラウザ
	NSNetServiceBrowser *_serviceBrowser;
	
	// 見つけたネットサービスを入れる配列
	NSMutableArray *_services;
}

// プロパティの定義
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, retain) NSMutableArray *services;

@end

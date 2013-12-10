#import <UIKit/UIKit.h>

// 「ConnectionViewController」クラスが存在することを宣言
@class ConnectionViewController;

// 「XMLParam」クラスが存在することを宣言
@class XMLParam;

// 現在の状態を管理するための定数
enum
{
    RootViewControllerInitialState, // 初期状態
    RootViewControllerGettingBlogs, // ブログ情報を取得中
    RootViewControllerGettingPages, // ページの一覧情報を取得中
    RootViewControllerGettingPosts  // 投稿記事の一覧情報を取得中
};

// 「RootViewController」クラスのインターフェイス宣言
@interface RootViewController : UITableViewController
<UIActionSheetDelegate>
{
    // 通信画面
    ConnectionViewController *_connectionViewController;
    
    // ブログ情報
    XMLParam *_userBlog;
    
    // 固定ページ情報の一覧
    NSArray *_pagesArray;
    
    // ブログの投稿記事情報の一覧
    NSArray *_postsArray;
    
    // 状態
    NSInteger _state;
}

// プロパティの定義
@property (retain, nonatomic) 
ConnectionViewController *connectionViewController;
@property (retain, nonatomic) XMLParam *userBlog;
@property (retain, nonatomic) NSArray *pagesArray;
@property (retain, nonatomic) NSArray *postsArray;
@property (assign, nonatomic) NSInteger state;

// 「Load More」ボタンの処理
- (IBAction)loadMore:(id)sender;

// 通信を開始するメソッド
- (void)requestWithNextState:(NSInteger)nextState;

// 「wp.getUsersBlogs」メソッドへの送信データを作成する
- (NSData *)dataForRequestGetUsersBlogs;

// 「wp.getPages」メソッドへの送信データを作成する
- (NSData *)dataForRequestGetPages;

// 「metaWeblog.getRecentPosts」メソッドへの送信データを作成する
- (NSData *)dataForRequestGetRecentPosts;

// 受信したデータを解析する
- (void)parseResponse;

// 「wp.getUsersBlogs」メソッドで受け取った情報を解析する
- (void)parseGetUsersBlogsParam:(XMLParam *)firstParam;

// 「wp.getPages」メソッドで受け取った情報を解析する
- (void)parseGetPagesParam:(XMLParam *)firstParam;

// 「metaWeblog.getRecentPosts」メソッドで受け取った情報を解析する
- (void)parseGetRecentPostsParam:(XMLParam *)firstParam;

@end

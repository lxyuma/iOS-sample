#import <UIKit/UIKit.h>

// 「ConnectionViewController」クラスが存在することを宣言する
@class ConnectionViewController;

// 「XMLParam」クラスが存在することを宣言する
@class XMLParam;

// 「EditViewController」クラスのインターフェイス宣言
@interface EditViewController : UIViewController
{
    // タイトルを入力するテキストフィールド
    UITextField *_titleField;
    
    // 本文を入力するテキストフィールド
    UITextView *_textView;
    
    // 通信画面
    ConnectionViewController *_connectionViewController;
    
    // 投稿記事情報、もしくは、ページ情報
    // 新規登録のときは「nil」にする
    XMLParam *_pageOrPostInfo;
    
    // ページの編集かどうか
    // 値が「YES」のときはページの編集、「NO」のときは投稿記事の編集
    BOOL _isPageEditing;
    
    // ブログID
    XMLParam *_blogID;
    
    // キーボードを表示中かどうか
    BOOL _keyboardVisible;
}

// プロパティの定義
@property (retain, nonatomic) IBOutlet UITextField *titleField;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) 
ConnectionViewController *connectionViewController;
@property (retain, nonatomic) XMLParam *pageOrPostInfo;
@property (assign, nonatomic) BOOL isPageEditing;
@property (retain, nonatomic) XMLParam *blogID;

// 投稿記事の情報、もしくは、ページ情報を表示する
- (void)reloadFromInfo:(XMLParam *)info;

// レスポンスデータを解析する
- (BOOL)parseResponse;

// 「Save」ボタンが押されたときの処理
- (void)save:(id)sender;

// ページの編集結果を保存するための送信データを作成する
- (NSData *)dataForSavePageEditing;

// 投稿記事の編集結果を保存するための送信データを作成する
- (NSData *)dataForSavePostEditing;

// ページの新規登録を行うための送信データを作成する
- (NSData *)dataForNewPage;

// 投稿記事の新規登録を行うための送信データを作成する
- (NSData *)dataForNewPost;

@end

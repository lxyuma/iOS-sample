#import <UIKit/UIKit.h>

// 「WebPageViewController」クラスのインターフェイス宣言
@interface WebPageViewController : UIViewController
{
    // 表示するURL
    NSURL *_url;
    
    // Webページを表示するビュー
    UIWebView *_webView;
}

// プロパティの定義
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end

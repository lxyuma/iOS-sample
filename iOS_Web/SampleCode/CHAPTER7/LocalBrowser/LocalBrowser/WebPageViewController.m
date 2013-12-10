#import "WebPageViewController.h"

// 「WebPageViewController」クラスの実装
@implementation WebPageViewController

// プロパティとメンバー変数の設定
@synthesize url = _url;
@synthesize webView = _webView;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _url = nil;
    }
    return self;
}

// デバイスの回転に対応するか返すメソッド
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも回転させる
    return YES;
}

// 解放処理
- (void)dealloc
{
    [_url release];
    [_webView release];
    [super dealloc];
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Webページを開く
    // URLへの接続要求を作成する
    NSURLRequest *req;
    req = [NSURLRequest requestWithURL:self.url];
    
    // URLからロードする
    [self.webView loadRequest:req];
    
    // ナビゲーションツールバーに表示するボタンを作成する
    NSMutableArray *array;
    array = [NSMutableArray arrayWithCapacity:0];
    
    // 「Back」ボタンを作成する
    UIBarButtonItem *button;
    
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Back"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(goBack:)];
    [array addObject:button];
    [button release];
    
    // 「Forward」ボタンを作成する
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Forward"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(goForward:)];
    [array addObject:button];
    [button release];
    
    // 再読込ボタンは右端に置きたいので、伸縮可能なスペースを作成する
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:
			  UIBarButtonSystemItemFlexibleSpace
              target:nil
              action:nil];
    [array addObject:button];
    [button release];
    
    // 再読込ボタンを作成する
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
              target:self
              action:@selector(reload:)];
    [array addObject:button];
    [button release];
    
    // ナビゲーションツールバーを表示する
    [self.navigationController setToolbarHidden:NO
                                       animated:animated];
    
    // ナビゲーションツールバーにボタンをセットする
    [self setToolbarItems:array]; 
}

// ビューが閉じられる直前に呼ばれるメソッド
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // ナビゲーションツールバーを閉じる
    [self.navigationController setToolbarHidden:YES
                                       animated:animated];
}

// Webページの読み込みが完了したときに呼ばれるメソッド
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Webページのタイトルを取得する
    // 「UIWebView」クラスには、タイトルを直接取得できるプロパティなどが
    // ないため、JavaScript経由で取得する
    NSString *str;
    str = [webView stringByEvaluatingJavaScriptFromString:
           @"document.title"];
    
    // タイトルを表示する
    [self setTitle:str];
}

// 「Back」ボタンがタップされたときに呼ばれるメソッド
- (void)goBack:(id)sender
{
    [self.webView goBack];
}

// 「Forward」ボタンがタップされたときに呼ばれるメソッド
- (void)goForward:(id)sender
{
    [self.webView goForward];
}

// 再読込ボタンがタップされたときに呼ばれるメソッド
- (void)reload:(id)sender
{
    [self.webView reload];
}

@end

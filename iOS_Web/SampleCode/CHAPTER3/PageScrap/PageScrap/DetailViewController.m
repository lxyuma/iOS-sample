#import "DetailViewController.h"
#import "ConnectionViewController.h"
#import "APIURL.h"
#import "EditViewController.h"

@implementation DetailViewController

// プロパティとメンバー変数の設定
@synthesize urlLabel = _urlLabel;
@synthesize contentTextView = _contentTextView;
@synthesize recordID = _recordID;
@synthesize connectionViewController = _connectionViewController;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        _recordID = nil;
        _connectionViewController = nil;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_urlLabel release];
    [_contentTextView release];
    [_recordID release];
    [_connectionViewController release];
    [super dealloc];
}

// デバイスを回転させるか判定する処理
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向でも回転させる
    return YES;
}

// ビューが表示された直後の処理
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 通信画面が閉じた後に表示されたのか、そうでないかの判定を行う
    if (self.connectionViewController)
    {
        // 通信画面が閉じた後に表示されたタイミングなので
        // 受信データから表示データを用意する
        [self reloadFromReceivedData];
        
        // 通信画面は必要なくなったので解放する
        [self setConnectionViewController:nil];
    }
    else
    {
        // 通信前なので、サーバと通信する
        // 接続先のURLを作成する
        // ここでの接続先は、情報を取得するAPIへのURL
        NSURL *url = [NSURL URLToGetDetail:self.recordID];
        
        // 接続要求を作成する
        NSURLRequest *req;
        req = [NSURLRequest requestWithURL:url];
        
        // 通信画面を表示して、通信を開始する
        ConnectionViewController *vc;
        vc = [[ConnectionViewController alloc] initWithNibName:nil
                                                        bundle:nil];
        [vc setUrlRequest:req];
        [self presentModalViewController:vc
                                animated:NO];
        
        // もし、通信画面が既に非表示になっていたら、通信を開始できなかった
        // ということなので、プロパティにセットしない
        if (vc.view.window)
        {
            [self setConnectionViewController:vc];
        }
        
        [vc release];
    }
}

// 受信したデータを解析して、表示情報を設定するメソッド
- (void)reloadFromReceivedData
{
    // 通信に成功したのか失敗したのかチェックする
    NSURLResponse *response = self.connectionViewController.response;
    
    // HTTPのステータスコードが400未満なら成功と見なす
    if ([response isKindOfClass:[NSHTTPURLResponse class]] &&
        [(NSHTTPURLResponse *)response statusCode] < 400)
    {
        // データを取得する
        NSData *data = self.connectionViewController.downloadedData;
        
        // 文字列化する
        NSString *text;
        text = [[[NSString alloc] initWithData:data
                                      encoding:NSUTF8StringEncoding]
                autorelease];
        
        // ID, タイトル, URL, 内容の順番に並んでいる
        // 先頭の行はIDなので、読み飛ばす
        NSScanner *scanner = [NSScanner scannerWithString:text];
        NSString *str;
        BOOL ret;
        
        ret = [scanner scanUpToString:@"\n"
                           intoString:&str];
        
        // タイトルを読み込む
        NSString *titleStr = nil;
        if (ret)
        {
            ret = [scanner scanUpToString:@"\n"
                               intoString:&titleStr];
        }
        
        // URLを読み込む
        NSString *urlStr = nil;
        if (ret)
        {
            ret = [scanner scanUpToString:@"\n"
                               intoString:&urlStr];
        }
        
        // 内容を読み込む。内容は残り全部となる
        NSString *contentStr = nil;
        if (ret && [scanner scanLocation] < [text length])
        {
            contentStr = [text substringFromIndex:
                          [scanner scanLocation]];
        }
        
        // 読み込んだ内容を表示する
        if (titleStr)
            [self setTitle:titleStr];
        if (urlStr)
            [self.urlLabel setText:urlStr];
        if (contentStr)
            [self.contentTextView setText:contentStr];
    }
}

// URLをSafariで開く
- (IBAction)openURL:(id)sender
{
    // ラベルからURLを取得する
    NSString *urlStr = self.urlLabel.text;
    
    // URLを作成する
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Safariで開く
    if (url)
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 「Edit」ボタンを作成する
    UIBarButtonItem *button;
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
              target:self
              action:@selector(edit:)];
    
    // ナビゲーションバーに追加する
    [self.navigationItem setRightBarButtonItem:button];
    
    [button release];
}

// ビューが非表示になる直前に呼ばれるメソッド
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 「viewWillAppear:」で追加した「Edit」ボタンを削除する
    [self.navigationItem setRightBarButtonItem:nil];
}

// 「Edit」ボタンが押されたときの処理
- (IBAction)edit:(id)sender
{
    // 登録情報編集画面を作成する
    EditViewController *vc;
    
    vc = [[EditViewController alloc] initWithNibName:nil
                                              bundle:nil];
    
    // 現在のURLとタイトル、IDを設定する
    [vc setRecordTitle:self.title];
    [vc setUrlString:self.urlLabel.text];
    [vc setRecordID:self.recordID];
    
    // 画面を表示する
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
    [vc release];
}

@end

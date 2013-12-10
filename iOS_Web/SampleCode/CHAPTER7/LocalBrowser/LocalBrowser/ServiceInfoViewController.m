#import "ServiceInfoViewController.h"
#import <sys/types.h>
#import <sys/socket.h>
#import "WebPageViewController.h"

// 「ServiceInfoViewController」クラスの実装
@implementation ServiceInfoViewController

// プロパティとメンバー変数の設定
@synthesize netService = _netService;
@synthesize textView = _textView;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _netService = nil;
    }
    return self;
}

// デバイスの回転に対応するか判定するメソッド
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation 
{
    // どの方向にも回転させる
    return YES;
}

// ビューをロードしたときに呼ばれるメソッド
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // ネットサービス名をタイトルとして表示する
    [self setTitle:self.netService.name];
	
    // 渡されたネットサービスの情報を取得していないときのみ実行する
    if ([self.netService.addresses count] == 0)
    {
        // ネットサービスの情報を取得する
        // ネットサービスのデリゲートとして、
        // 「ServiceInfoViewController」クラスを設定する
        [self.netService setDelegate:self];
        
        // 情報取得開始
        [self.netService resolveWithTimeout:60];
    }
    else
    {
        // 取得済みの時は、情報を表示する
        [self showNetServiceInfo];
    }
}

// 解放処理
- (void)dealloc
{
    // ネットサービスのデリゲートをクリアする
    [_netService setDelegate:nil];
    
    [_netService release];
    [_textView release];
    [super dealloc];
}

// ネットサービスの情報取得が終わったときに呼ばれる
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    // 取得した情報を表示する
    [self showNetServiceInfo];
}

// ネットサービスの情報が取得できなかったときに呼ばれる
- (void)netService:(NSNetService *)sender
     didNotResolve:(NSDictionary *)errorDict
{
    // エラーメッセージを表示する
    UIAlertView *alert;
    NSString *msg = @"Couldn't resolve the service";
    alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                       message:msg
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
    [alert release];
}

// ネットサービスの情報をテキストビューに表示する処理
- (void)showNetServiceInfo
{
    // 表示する情報を文字列で作成する
    NSMutableString *infoStr;
    infoStr = [NSMutableString stringWithCapacity:0];
    
    // 文字列に名前を追加する
    [infoStr appendFormat:@"name=%@\n",
     self.netService.name];
    
    // 文字列にサービスタイプを追加する
    [infoStr appendFormat:@"type=%@\n",
     self.netService.type];
    
    // 文字列にドメインを追加する
    [infoStr appendFormat:@"domain=%@\n",
     self.netService.domain];
    
    // 文字列にホスト名を追加する
    [infoStr appendFormat:@"hostName=%@\n",
     self.netService.hostName];
    
    // 文字列にTXTレコードデータを追加する
    // TXTレコードデータを取得して、文字列に変換する
    NSString *str = nil;
    NSData *data = self.netService.TXTRecordData;
    
    if (data)
    {
        // UTF-8の文字列として扱う
        str = [[[NSString alloc] initWithData:data
									 encoding:NSUTF8StringEncoding]
               autorelease];
    }
    
    // 文字列に追加する
    [infoStr appendFormat:@"TXTRecordData=%@\n", str];
    
    // 文字列にポート番号を追加する
    [infoStr appendFormat:@"port=%d\n", self.netService.port];
    
    // 文字列にアドレスを追加する
    // アドレスの配列を取得する
    NSArray *array = self.netService.addresses;
	
    // 配列の各アイテムは、「sockaddr」構造体を
    // 「NSData」クラスを使ってバイト列にしている
    // 各アイテムを取得して、文字列にアドレスを追加する
    [infoStr appendString:@"addresses=\n"];
    
    [array enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         // 構造体として取得する
         const struct sockaddr *p;
         p = (const struct sockaddr *)[obj bytes];
         
         // 文字列にして追加する
         [infoStr appendFormat:@"  %u.%u.%u.%u\n",
          (uint8_t)p->sa_data[2],
          (uint8_t)p->sa_data[3],
          (uint8_t)p->sa_data[4],
          (uint8_t)p->sa_data[5]];
     }];
    
    // 作成した文字列をテキストビューに設定する
    [self.textView setText:infoStr];
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // サービスタイプが「_http._tcp.」のときは、
    // ナビゲーションバーに「Open」ボタンを追加する
    if ([self.netService.type isEqualToString:@"_http._tcp."])
    {
        // 「Open」ボタンを作成する
        UIBarButtonItem *button;
        
        button = [[UIBarButtonItem alloc]
                  initWithTitle:@"Open"
                  style:UIBarButtonItemStylePlain
                  target:self
                  action:@selector(open:)];
        
        // ナビゲーションバーの右端にボタンをセットする
        [self.navigationItem setRightBarButtonItem:button
                                          animated:animated];       
        [button release];
    }
}   

// 「Open」ボタンがタップされたときの処理
- (void)open:(id)sender
{
    // Webページ表示画面を作成する
    WebPageViewController *vc;
    
    vc = [[WebPageViewController alloc] initWithNibName:nil
                                                 bundle:nil];
    
    // ネットサービスのURLを作成する
    // ホスト名を取得する
    NSString *hostName = self.netService.hostName;
    
    // ポート番号を取得する
    NSInteger port = self.netService.port;
    
    // パスを取得する
    NSString *path = nil;
    NSDictionary *dict;
    
    dict = [NSNetService dictionaryFromTXTRecordData:
            self.netService.TXTRecordData];
    if (dict)
    {
        path = [[[NSString alloc] initWithData:
                 [dict objectForKey:@"path"]
                                      encoding:NSUTF8StringEncoding]
                autorelease];
    }
    
    // URLの文字列を作成する
    NSString *urlStr;
    urlStr = [NSString stringWithFormat:@"http://%@:%d/",
              hostName, port];
    
    // パスが取得できていたら、URLに追加する
    if (path && [path length] > 0)
    {
        urlStr = [urlStr stringByAppendingPathComponent:path];
    }
    
    // URLを作成する
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Webページ表示画面に設定する
    [vc setUrl:url];
    
    // Webページ表示画面を表示する
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
    [vc release];
}

@end

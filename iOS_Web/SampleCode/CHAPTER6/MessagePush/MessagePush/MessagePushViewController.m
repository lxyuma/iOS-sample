#import "MessagePushViewController.h"
#import "ConnectionViewController.h"

// ユーザーデフォルトのキー
// プッシュ通知を受け取るかどうかを記憶する
static NSString *kReceiveNotification = @"receiveNotification";

// プロバイダの登録APIのURL
// テスト環境に合わせて、変更する必要がある
static NSString *kURL =
@"http://mac-pro-8.local/MessagePush/register.php";

// 「MessagePushViewController」クラスの実装
@implementation MessagePushViewController

// プロパティとメンバー変数の設定
@synthesize receiveNotificationSwitch = _receiveNotificationSwitch;
@synthesize connectionViewController = _connectionViewController;
@synthesize messageLabel = _messageLabel;

// イニシャライザ
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // メンバー変数を初期化する
        _connectionViewController = nil;
    }
    return self;
}

// ビューがロードされたときの処理
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // プッシュ通知を受け取る設定になっているかをユーザーデフォルトから
    // 取得する
    NSUserDefaults *userDefaults;
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:kReceiveNotification])
    {
        // 受け取る設定になっている
        
        // プッシュ通知で、効果音とメッセージを受け取る
        int types;
        types = (UIRemoteNotificationTypeSound |
                 UIRemoteNotificationTypeAlert);
        
        // デバイスを登録する
        UIApplication *app;
        app = [UIApplication sharedApplication];
        [app registerForRemoteNotificationTypes:types];
        
        // スイッチをオンにする
        self.receiveNotificationSwitch.on = YES;
    }
}

// デバイスの向きにあわせて回転させるかを返すメソッド
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも回転させる
    return YES;
}

// 解放処理
- (void)dealloc
{
    [_messageLabel release];
    [_connectionViewController release];
    [_receiveNotificationSwitch release];
    [super dealloc];
}

// プッシュ通知を受け取るか設定するスイッチの状態を
// 変更したときに呼ばれるメソッド
- (IBAction)toggleReceiveNotification:(id)sender
{
    // スイッチの状態によって処理を変更する
    if (self.receiveNotificationSwitch.on)
    {
        // オンになっているので、プッシュ通知を受け取る
        // プッシュ通知で、効果音とメッセージを受け取る
        int types;
        types = (UIRemoteNotificationTypeSound |
                 UIRemoteNotificationTypeAlert);
        
        // デバイスを登録する
        UIApplication *app;
        app = [UIApplication sharedApplication];
        [app registerForRemoteNotificationTypes:types];     
    }
    else
    {
        // オフになっているので、プッシュ通知を受け取らないようにする
        UIApplication *app;
        app = [UIApplication sharedApplication];
        [app unregisterForRemoteNotifications];
    }
}

// APNsにデバイスを登録できたときに呼ばれるメソッド
- (void)didRegisterForRemoteNotificationsWithDeviceToken:
(NSData *)deviceToken
{
    // デバイストークンを16進ダンプする
    NSString *str;
    str = [self hexDumpString:deviceToken];
    if (!str)
        return; // 作成できなかった
    
    // プロバイダに送信するデータを作成する
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObject:str
                                       forKey:@"token"];
    NSData *data;
    data = [self formEncodedDataFromDictionary:dict];
    
    // プロバイダにデバイストークンを送信する
    // 接続要求を作成する
    NSURL *url = [NSURL URLWithString:kURL];
    NSMutableURLRequest *req;
    req = [NSMutableURLRequest requestWithURL:url];
    
    // HTTPのメソッドをPOSTに設定する
    [req setHTTPMethod:@"POST"];
    
    // POSTのデータを設定する
    [req setHTTPBody:data];
    
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
        
        // ユーザーデフォルトに、通知をオンにしたことを記憶する
        NSUserDefaults *userDefaults;
        userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES
                       forKey:kReceiveNotification];
    }
    
    [vc release];
}

// バイナリデータを16進ダンプした文字列に変換する
- (NSString *)hexDumpString:(NSData *)data
{
    // 格納先の文字列を確保する
    NSMutableString *str;
    str = [NSMutableString stringWithCapacity:0];
    
    // 変数「data」に格納されたバイト列を取得する
    const unsigned char *p = (const unsigned char *)[data bytes];
    const unsigned char *pend = p + [data length];
    
    // 1バイトずつ16進数に変換していく
    for (; p != pend; p++)
    {
        [str appendFormat:@"%02X", *p];
    }
    return str;
}

// POSTで渡せるように、辞書に格納された文字列から
// 「application/x-www-form-urlencoded」形式の
// データを作成する
- (NSData *)formEncodedDataFromDictionary:(NSDictionary *)dict
{
    NSMutableString *str;
    
    str = [NSMutableString stringWithCapacity:0];
    
    // 「キー=値」のペアを「&」で結合して列挙する
    // キーと値はどちらもURLエンコードを行い、スペースは「+」に置き換える
    for (NSString *key in [dict allKeys])
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString *value = [dict objectForKey:key];
        
        // スペースを「+」に置き換える
        key = [key stringByReplacingOccurrencesOfString:@" "
                                             withString:@"+"];
        value = [value stringByReplacingOccurrencesOfString:@" "
                                                 withString:@"+"];
        // URLエンコードを行う
        key = [key stringByAddingPercentEscapesUsingEncoding:
               NSUTF8StringEncoding];
        value = [value stringByAddingPercentEscapesUsingEncoding:
                 NSUTF8StringEncoding];
        
        // 文字列を連結する
        if ([str length] > 0)
        {
            [str appendString:@"&"];
        }
        
        [str appendFormat:@"%@=%@", key, value];
        
        [pool drain];
    }
    
    // 作成した文字列をUTF-8で符号化する
    NSData *data;
    data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

// APNsにデバイスを登録できなかったときに呼ばれるメソッド
- (void)didFailToRegisterForRemoteNotificationsWithError:
(NSError *)error
{
    // 失敗してしまったので、スイッチをオフにする
    self.receiveNotificationSwitch.on = NO;
    
    // ユーザーデフォルトに、通知をオフにしたことを記憶する
    NSUserDefaults *userDefaults;
    userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:NO
                   forKey:kReceiveNotification];
    
    // エラーメッセージを表示する
    UIAlertView *alert;
    NSString *str = [error localizedDescription];
    
    alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                       message:str
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
    [alert release];
}

// プッシュ通知を受け取ったときに呼び出すメソッド
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 通知されたメッセージを取得する
    NSString *message;
    message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    // ラベルにセットする
    [self.messageLabel setText:message];
    
    // ビューの背景色を取得する
    NSString *colorStr;
    colorStr = [userInfo objectForKey:@"color"];
    
    if (colorStr)
    {
        // 16進数の文字列を数値に変換する
        NSScanner *scanner;
        scanner = [NSScanner scannerWithString:colorStr];
        
        unsigned u;
        if ([scanner scanHexInt:&u])
        {
            // RGBに分解する
            double b = (u & 0xFF);
            double g = ((u >> 8) & 0xFF);
            double r = ((u >> 16) & 0xFF);
            
            // 「UIColor」クラスのインスタンスを作成する
            UIColor *color;
            color = [UIColor colorWithRed:(r / 255.0)
                                    green:(g / 255.0)
                                     blue:(b / 255.0)
                                    alpha:1.0];
            
            // ビューの背景色として設定する
            [self.view setBackgroundColor:color];
            
            // ビューを再描画する
            [self.view setNeedsDisplay];
        }
    }
    
}

@end

#import "EditViewController.h"
#import "ConnectionViewController.h"
#import "APIURL.h"

@implementation EditViewController

// プロパティとメンバー変数の設定
@synthesize urlTextField = _urlTextField;
@synthesize titleTextField = _titleTextField;
@synthesize urlString = _urlString;
@synthesize recordTitle = _recordTitle;
@synthesize recordID = _recordID;
@synthesize connectionViewController = _connectionViewController;
@synthesize deleteButton = _deleteButton;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数の初期化
        _urlString = nil;
        _recordTitle = nil;
        _recordID = nil;
        _connectionViewController = nil;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_deleteButton release];
    [_urlTextField release];
    [_titleTextField release];
    [_urlString release];
    [_recordTitle release];
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

// ビューの初期化処理
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 情報編集機能の場合は、プロパティに値が設定されているので
    // テキストフィールドに設定する
    if (self.urlString)
        [self.urlTextField setText:self.urlString];
    if (self.recordTitle)
        [self.titleTextField setText:self.recordTitle];
}


// ビューが表示される直前の処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ナビゲーションバーに「Save」ボタンを追加する
    // ボタンが押されたときは、「save:」メソッドを呼び出すようにする
    UIBarButtonItem *button;
    SEL sel = @selector(save:);
    
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
              target:self
              action:sel];
    [self.navigationItem setRightBarButtonItem:button];
    [button release];
    
    // 登録情報編集機能のときだけ、「Delete」ボタンを表示する
    if ([self.recordID length] > 0)
    {
        [self.deleteButton setHidden:NO];
    }
    else
    {
        [self.deleteButton setHidden:YES];
    }
}

// ビューが表示された直後の処理
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 通信画面が閉じた後に表示されたのか、そうでないかの判定を行う
    if (self.connectionViewController)
    {
        // 通信画面が閉じた後に表示されたタイミングなので
        // エラーが発生していないかチェックする
        if ([self checkSuccessWithReceivedData])
        {
            // 成功したので、このビューを閉じる
            // 通信画面を解放する
            [self setConnectionViewController:nil];
            
            // 情報編集画面を閉じる
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            // エラーメッセージを表示する
            UIAlertView *alert;
			
            alert = [[UIAlertView alloc]
                     initWithTitle:@"Connection Error"
                     message:@"Failed to communicate to the server."
                     delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

// ビューが非表示になる直前に呼ばれる
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 「viewWillAppear:」メソッドでセットしたボタンを
    // 削除する
    [self.navigationItem setRightBarButtonItem:nil];
}

// 「Save」ボタンが押されたときの処理
- (IBAction)save:(id)sender
{
    // 入力されたURLとタイトルを取得する
    NSString *urlStr = self.urlTextField.text;
    NSString *titleStr = self.titleTextField.text;
    
    // URLとタイトルが入力されていなければ何もしない
    if ([urlStr length] > 0 &&
        [titleStr length] > 0)
    {
        // 接続先のURLを作成する
        // ここで接続先は、情報編集機能と情報登録機能とで異なる
        NSString *recordID = self.recordID;
        NSURL *url = nil;
        
        if ([recordID length] > 0)
        {
            // 情報編集機能のURLを取得する
            url = [NSURL URLToDoUpdate];
        }
        else
        {
            // 新規登録機能のURLを取得する
            url = [NSURL URLToDoInsert];
        }
        
        // 接続要求を作成する
        NSMutableURLRequest *req;
        req = [NSMutableURLRequest requestWithURL:url];
        
        // HTTPのメソッドをPOSTに設定する
        [req setHTTPMethod:@"POST"];
        
        // POSTで送信するデータを作成する
        NSMutableDictionary *dict;
        
        dict = [NSMutableDictionary dictionaryWithCapacity:0];
        [dict setObject:urlStr forKey:@"URL"];
        [dict setObject:titleStr forKey:@"title"];
        
        if ([recordID length] > 0)
            [dict setObject:recordID forKey:@"ID"];
        
        NSData *data;
        data = [self formEncodedDataFromDictionary:dict];
        
        // POSTのデータとして設定する
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
        }
        
        [vc release];
    }
}

// 受信したデータから成功したかどうかを判定する
- (BOOL)checkSuccessWithReceivedData
{
    BOOL ret = NO;
    
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
        
        // 「1」が取得できていたら成功
        if ([text integerValue] == 1)
        {
            ret = YES;
        }
    }
    
    return ret;
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

// ソフトウェアキーボードで「Return」キーが押されたときの処理
// ここでは、「Next」と「Done」を表示するようにしているが
// どちらの場合でもこのメソッドが呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL ret = YES;
    
    // テキストフィールドによって処理を変更する
    if ([textField isEqual:self.urlTextField])
    {
        // 「Next」ボタンが表示されているので、
        // 次のテキストフィールドに移動する
        [self.titleTextField becomeFirstResponder];
        ret = NO;
    }
    else if ([textField isEqual:self.titleTextField])
    {
        // 「Done」が表示されているので、保存処理を呼び出す
        [self save:nil];
        ret = NO;
    }
    
    return ret;
}

// 「Delete」ボタンが押されたときの処理
- (IBAction)deleteRecord:(id)sender
{
    // 接続先のURLを作成する
    // ここでの接続先は、情報を削除するAPIへのURL
    NSURL *url = [NSURL URLToDoDelete];
    
    // 接続要求を作成する
    NSMutableURLRequest *req;
    req = [NSMutableURLRequest requestWithURL:url];
    
    // HTTPのメソッドをPOSTに設定する
    [req setHTTPMethod:@"POST"];
    
    // POSTで送信するデータを作成する
    NSMutableDictionary *dict;
    
    dict = [NSMutableDictionary dictionaryWithCapacity:0];
    [dict setObject:self.recordID forKey:@"ID"];
    
    NSData *data;
    data = [self formEncodedDataFromDictionary:dict];
    
    // POSTのデータとして設定する
    [req setHTTPBody:data];
	
    // ページリスト画面まで戻す
    // ただし、この時点でビューコントローラが解放されると困るので
    // 参照カウンタを増やす
    [self retain];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    // 通信画面を表示して、通信を開始する
    ConnectionViewController *vc;
    vc = [[ConnectionViewController alloc] initWithNibName:nil
                                                    bundle:nil];
    [vc setUrlRequest:req];
    [self presentModalViewController:vc
                            animated:NO];
    [vc release];
    
    // 上で参照カウンタを増やしているので、ここで解放する
    [self release];
}

@end

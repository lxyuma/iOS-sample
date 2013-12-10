#import "FTPBrowseViewController.h"
#import <sys/dirent.h>
#import "TransferViewController.h"
#import "UploadFileChooserViewController.h"


// バッファサイズ
static const size_t kBufferSize = 512;

// 読み込みストリームから呼ばれるコールバック関数
static void callbackProc(CFReadStreamRef stream,
                         CFStreamEventType event,
                         void *context)
{
    // Objective-Cの外側でのコールバック関数なので
    // 念のため、自動解放プールで囲む
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // ビューコントローラを取得する
    FTPBrowseViewController *viewController;
    viewController = (FTPBrowseViewController *)context;
    
    // イベントハンドラを呼び出す
    [viewController handleEvent:event];
    
    [pool drain];
}


@implementation FTPBrowseViewController

// プロパティとメンバー変数の設定
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize directoryURL = _directoryURL;

// イニシャライザメソッド
- (id)initWithNibName:(NSString *)nibName
               bundle:(NSBundle *)bundle
{
    self = [super initWithNibName:nibName
                           bundle:bundle];
    if (self)
    {
        // メンバー変数の初期化
        _userName = nil;
        _password = nil;
        _directoryURL = nil;
        _readStream = nil;
        _receivedData = nil;
        _directoryContents = nil;
    }
    return self;
}

// テーブルビューに表示するセクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// テーブルビューに表示する項目数を返す
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // ディレクトリ内容の項目数を返す
    return [_directoryContents count];
}

// テーブルビューに表示する項目を返す
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // セルを作成する
    // セルによって、「>」記号があるものとないものがあるので
    // セルを再利用しない
    UITableViewCell *cell;
    cell = [[[UITableViewCell alloc]
             initWithStyle:UITableViewCellStyleDefault
             reuseIdentifier:nil] autorelease];
    
    // 情報を取得する
    NSDictionary *dirItem;
    dirItem = [_directoryContents objectAtIndex:indexPath.row];
    
    // 項目のタイトルを設定する
    cell.textLabel.text =
    [dirItem objectForKey:(id)kCFFTPResourceName];
    
    // サブディレクトリの場合は、さらに潜れることを示すため
    // 「>」記号を表示する
    NSInteger resType;
    resType = [[dirItem objectForKey:(id)kCFFTPResourceType]
               integerValue];
    if (resType == DT_DIR)
    {
        cell.accessoryType = 
        UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

// テーブルビューの項目を選択したときの処理
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択された項目の情報を取得する
    NSDictionary *itemDict;
    itemDict = [_directoryContents objectAtIndex:indexPath.row];
    
    // 選択された項目がサブディレクトリかどうかを判定する
    NSInteger resType;
    resType = [[itemDict objectForKey:(id)kCFFTPResourceType]
               integerValue];
	
    if (resType == DT_DIR)
    {
        // 選択された項目がサブディレクトリだったので、
        // 選択されたサブディレクトリへのURLを作成する
        NSURL *newURL;      
        NSString *str;
        
        // ディレクトリ名を取得
        str = [itemDict objectForKey:(id)kCFFTPResourceName];
        // 文字列をURLエンコードする
        str = [str stringByAddingPercentEscapesUsingEncoding:
               NSASCIIStringEncoding];
        // ディレクトリへのURLなので、「/」を末尾に付ける
        str = [str stringByAppendingString:@"/"];
        
        // 相対URLを作成する
        newURL = [NSURL URLWithString:str
                        relativeToURL:self.directoryURL];
        
        // 絶対URLに変換する
        newURL = [newURL absoluteURL];
        
        // URLが作成できたら接続する
        if (newURL)
        {
            // 新しいビューコントローラを作成する
            FTPBrowseViewController *vc;
            
            vc = [[FTPBrowseViewController alloc]
                  initWithNibName:nil
                  bundle:nil];
            
            // URLとユーザー名、パスワードをセット
            [vc setUserName:self.userName];
            [vc setPassword:self.password];
            [vc setDirectoryURL:newURL];
            
            // 作成したビューコントローラを表示する
            [self.navigationController pushViewController:vc
                                                 animated:YES];
            
            [vc release];
        }
    }
}

// 解放処理
- (void)dealloc
{
    [_directoryContents release];
    [_receivedData release];
    [_userName release];
    [_password release];
    [_directoryURL release];
    [super dealloc];
}

// ディレクトリのURLの設定
- (void)setDirectoryURL:(NSURL *)url
{
    if (url != _directoryURL)
    {
        [_directoryURL release];
        _directoryURL = [url retain];
        
        // ビューコントローラのタイトルをディレクトリ名にする
        NSString *name = [[url path] lastPathComponent];        
		
        if (!name || [name length] == 0)
        {
            // ルートディレクトリでURLが「/」で終わっていないと
            // 名前が取得できない
            name = @"/";
        }
        
        [self setTitle:name];
    }
}

// ビューコントローラが表示されたときの処理
- (void)viewDidAppear:(BOOL)animated
{
    // 親クラスの処理を実行
    [super viewDidAppear:animated];
    
    // 読み込みストリームを作成する
    BOOL ret = NO;
    _readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault,
											   (CFURLRef)self.directoryURL);
    
    // ストリームにユーザー名を設定する
    CFReadStreamSetProperty(_readStream, 
                            kCFStreamPropertyFTPUserName,
                            (CFTypeRef)self.userName);
    // ストリームにパスワードを設定する
    CFReadStreamSetProperty(_readStream,
                            kCFStreamPropertyFTPPassword,
                            (CFTypeRef)self.password);
    // ストリームにパッシブモードを設定する
    CFReadStreamSetProperty(_readStream,
                            kCFStreamPropertyFTPUsePassiveMode,
                            kCFBooleanTrue);
    
    // ストリームにコールバックを設定する
    // コールバック関数から、このインスタンスを参照できるようにする
    CFStreamClientContext myContext;
    
    myContext.version = 0;
    myContext.info = (void *)self;
    myContext.retain = NULL;
    myContext.release = NULL;
    myContext.copyDescription = NULL;
    
    // コールバック関数を呼び出すイベントの設定
    CFOptionFlags events;
    events = (kCFStreamEventHasBytesAvailable |
              kCFStreamEventErrorOccurred |
              kCFStreamEventEndEncountered);
    
    // コールバック関数を設定する
    if (CFReadStreamSetClient(_readStream,
                              events,
                              callbackProc,
                              &myContext))
    {
        // ランループにセットする
        CFReadStreamScheduleWithRunLoop(_readStream,
                                        CFRunLoopGetCurrent(),
                                        kCFRunLoopCommonModes);
        
        // ストリームを開く
        if (CFReadStreamOpen(_readStream))
        {
            [_receivedData release];
            _receivedData = [[NSMutableData alloc]
                             initWithCapacity:0];
            ret = YES;
        }
    }
    
    // エラーが起きていたらストリームを解放して、エラーメッセージを表示する
    if (!ret)
    {
        // ストリームを解放する
        [self releaseReadStream];
        
        // エラーメッセージを表示する
        UIAlertView *alert;
        
        alert = [[UIAlertView alloc]
                 initWithTitle:@"Error"
                 message:@"Couldn't open the connection."
                 delegate:nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        // このビューコントローラを閉じて、前の画面に戻る
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

// ビューが非表示になる直前
- (void)viewWillDisappear:(BOOL)animated
{
    // 親クラスの処理を実行
    [super viewWillDisappear:animated];
    
    // ストリームが開かれていたら、閉じて、解放する
    [self releaseReadStream];
}

// 読み込みストリームを閉じて解放する
- (void)releaseReadStream
{
    if (_readStream)
    {
        CFReadStreamUnscheduleFromRunLoop(_readStream,
                                          CFRunLoopGetCurrent(),
                                          kCFRunLoopCommonModes);
        CFReadStreamClose(_readStream);
        CFRelease(_readStream);
        _readStream = nil;
    }
}   

// イベントハンドラメソッド。ストリームに関するイベントを処理する
- (void)handleEvent:(CFStreamEventType)eventType
{
    if (eventType == kCFStreamEventHasBytesAvailable)
    {
        // データを受信した
        [self handleHasBytesAvailable];
    }
    else if (eventType == kCFStreamEventEndEncountered)
    {
        // 最後まで受信した
        [self handleEndEncountered];
    }
    else if (eventType == kCFStreamEventErrorOccurred)
    {
        // エラーが起きた
        [self handleErrorOccurred];
    }
}

// データを受信したとき呼ばれる
- (void)handleHasBytesAvailable
{
    // ストリームから読み込む
    CFIndex numOfBytes;
    unsigned char buf[kBufferSize];
    
    numOfBytes = CFReadStreamRead(_readStream, 
                                  buf,
                                  kBufferSize);
    if (numOfBytes > 0)
    {
        // 読み込んだデータを内部バッファに追加する
        [_receivedData appendBytes:buf
                            length:numOfBytes];
    }
}

// 最後まで受信したに呼ばれる
- (void)handleEndEncountered
{   
    // ステータスが終了状態になっているか確認する
    if (CFReadStreamGetStatus(_readStream) != kCFStreamStatusAtEnd)
    {
        return;
    }
    
    // 受信したディレクトリ内容を解析する
    // バイト列を取得
    const UInt8 *p = (const UInt8 *)[_receivedData bytes];
    // 残りの長さ
    NSInteger remainBytes = [_receivedData length];
    
    // ループさせながら一項目ずつ解析する
    BOOL succssed = YES;
    NSMutableArray *dirContents;
    dirContents = [NSMutableArray arrayWithCapacity:0];
    while (remainBytes > 0)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // 解析する
        CFDictionaryRef parsedDict = nil;
        CFIndex bytesParsed;
        bytesParsed =
        CFFTPCreateParsedResourceListing(kCFAllocatorDefault,
                                         p,
                                         remainBytes,
                                         &parsedDict);
        if (bytesParsed > 0)
        {
            // 正しく解析できた
            [dirContents addObject:(id)parsedDict];
            CFRelease(parsedDict);
            
            // 次の項目の解析のために値を更新する
            p += bytesParsed;
            remainBytes -= bytesParsed;
        }
        else if (bytesParsed == 0)
        {
            // 解析終了
            [pool drain];
            break;
        }
        else
        {
            // エラーが発生したので、解析を中止する
            succssed = NO;
            [pool drain];
            break;
        }
        
        
        [pool drain];
    }
    
    // メンバー変数の内容を更新する
    [_directoryContents release];
    _directoryContents = nil;
    
    if (succssed)
    {
        _directoryContents = [dirContents copy];
    }
    
    // テーブルビューを再読み込みする
    [self.tableView reloadData];
    
    // ストリームを閉じる
    [self releaseReadStream];
}

// エラーが起きたときに呼ばれる
- (void)handleErrorOccurred
{
    // ストリームを閉じる
    [self releaseReadStream];
	
    // エラーメッセージを表示する
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:@"Couldn't get the directory contents."
             delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    // このビューコントローラを閉じて、前の画面に戻る
    [[self navigationController] popViewControllerAnimated:YES];
    
}

// ビューが読み込まれたときの処理
- (void)viewDidLoad
{
    // 親クラスの処理を呼び出す
    [super viewDidLoad];
    
    // ナビゲーションバーに「Disconnect」ボタンを追加する
    // ナビゲーションバーを表示する
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
    
    // ボタンを作成
    UIBarButtonItem *newButton;
    
    newButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"Disconnect"
                 style:UIBarButtonItemStylePlain
                 target:self
                 action:@selector(disconnect:)];
    
    // ナビゲーションバーに追加する
    [self.navigationItem setRightBarButtonItem:newButton];
    
    [newButton release];
    
    // ツールバーにボタンを追加する
    // ボタンを中央に揃えたいので、左右には伸縮可能なスペースを配置する
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:0];
    
    // 伸縮可能なスペースを作成する
    newButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:
				 UIBarButtonSystemItemFlexibleSpace
                 target:nil
                 action:0];
    [items addObject:newButton];
    [newButton release];
    
    // ダウンロードボタンを作成する
    newButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"Download"
                 style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(download:)];
    [items addObject:newButton];
    [newButton release];
    
    // アップロードボタンを作成する
    newButton = [[UIBarButtonItem alloc]
                 initWithTitle:@"Upload"
                 style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(upload:)];
    [items addObject:newButton];
    [newButton release];
    
    // 伸縮可能なスペースを作成する
    newButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:
				 UIBarButtonSystemItemFlexibleSpace
                 target:nil
                 action:0];
    [items addObject:newButton];
    [newButton release];
    
    // ツールバーにボタンをセットする
    [self setToolbarItems:items];
}

// 「Disconnect」ボタンが押されたときの処理
- (void)disconnect:(id)sender
{
    // ストリームを閉じる
    [self releaseReadStream];
    
    // 接続画面に戻る
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// ビューが表示される直前の処理
- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewWillAppear:animated];
    
    // ツールバーを表示する
    [self.navigationController setToolbarHidden:NO
                                       animated:YES];
}

// 「Download」ボタンが押されたときの処理
- (void)download:(id)sender
{
    // 選択されている項目を取得する
    NSIndexPath *indexPath;
    indexPath = [self.tableView indexPathForSelectedRow];
    if (!indexPath)
        return;
    
    // 選択されている項目がファイルかどうかを調べる
    NSDictionary *dict;
    dict = [_directoryContents objectAtIndex:indexPath.row];
    
    if ([[dict objectForKey:(id)kCFFTPResourceType]
         integerValue] != DT_REG)
    {
        // ファイルではないので、何もしない
        return;
    }
    
    // リモートファイルへのURLを作成する
    NSString *str;
    str = [dict objectForKey:(id)kCFFTPResourceName];
    // 文字列をURLエンコードする
    str = [str stringByAddingPercentEscapesUsingEncoding:
           NSASCIIStringEncoding];
	
    // 相対URLを作成する
    NSURL *remoteURL = [NSURL URLWithString:str
                              relativeToURL:self.directoryURL];
    // 絶対URLに変換する
    remoteURL = [remoteURL absoluteURL];
    
    // ローカルファイルへのURLを作成する
    str = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                               NSUserDomainMask,
                                               YES) lastObject];
    str = [str stringByAppendingPathComponent:
           [dict objectForKey:(id)kCFFTPResourceName]];
    
    NSURL *localURL = [NSURL fileURLWithPath:str];
    
    // ダウンロードするファイルのサイズを取得する
    uint64_t fileSize;
    fileSize = [[dict objectForKey:(id)kCFFTPResourceSize]
                unsignedLongLongValue];
    
    // 準備ができたので転送画面を表示し、ダウンロードを始める
    TransferViewController *vc;
    vc = [[TransferViewController alloc] initWithNibName:nil
                                                  bundle:nil];
    
    // ユーザー名を設定
    [vc setUserName:self.userName];
    
    // パスワードを設定
    [vc setPassword:self.password];
    
    // ダウンロード情報を設定
    [vc setRemoteURL:remoteURL];
    [vc setLocalURL:localURL];
    [vc setFileSize:fileSize];
    [vc setUploadMode:NO];
	
    // ビューを表示する
    [self presentModalViewController:vc
                            animated:YES];
	
    [vc release];
}

// 「Upload」ボタンが押されたときの処理
- (void)upload:(id)sender
{
    // ファイル選択画面を表示する
    UploadFileChooserViewController *vc;
    vc = [[UploadFileChooserViewController alloc]
          initWithNibName:nil
          bundle:nil];
    
    // 必要な情報を設定する
    [vc setUserName:self.userName];
    [vc setPassword:self.password];
    [vc setRemoteDirURL:self.directoryURL];
    
    // ビューを表示する
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
    [vc release];
}

@end


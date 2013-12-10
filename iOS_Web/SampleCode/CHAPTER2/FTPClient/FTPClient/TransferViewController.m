#import "TransferViewController.h"

// バッファサイズ
static const size_t kBufferSize = 512;

// 読み込みストリームのコールバック関数
static void readCallbackProc(CFReadStreamRef stream,
                             CFStreamEventType event,
                             void *context)
{
    // Objective-Cの外側でのコールバック関数なので
    // 念のため、自動解放プールで囲む
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // ビューコントローラを取得する
    TransferViewController *vc;
    vc = (TransferViewController *)context;
    
    // イベントハンドラを呼び出す
    [vc handleEvent:event];
    
    [pool drain];
}

// 書き込みストリームのコールバック関数
static void writeCallbackProc(CFWriteStreamRef stream,
                              CFStreamEventType event,
                              void *context)
{
    // Objective-Cの外側でのコールバック関数なので
    // 念のため、自動解放プールで囲む
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // ビューコントローラを取得する
    TransferViewController *vc;
    vc = (TransferViewController *)context;
    
    // イベントハンドラを呼び出す
    [vc handleEvent:event];
    
    [pool drain];
}

@implementation TransferViewController

// プロパティとメンバー変数の設定
@synthesize progressView = _progressView;
@synthesize label = _label;
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize remoteURL = _remoteURL;
@synthesize localURL = _localURL;
@synthesize fileSize = _fileSize;
@synthesize uploadMode = _uploadMode;

// 初期化処理
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _userName = nil;
        _password = nil;
        _readStream = nil;
        _writeStream = nil;
        _uploadMode = NO;
        _fileSize = 0;
        _transferedSize = 0;
        _remoteURL = nil;
        _localURL = nil;

        // モーダル表示の種類を設定する
        // iPad上では、フルスクリーンではなくシート形式で表示する
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_progressView release];
    [_label release];
    [_userName release];
    [_password release];
    [_remoteURL release];
    [_localURL release];
    [super dealloc];
}

// ビューの初期化処理
- (void)viewDidLoad
{
    // 親クラスの処理を呼び出す
    [super viewDidLoad];
    
    // プログレスビューとラベルを初期化する
    [self.progressView setProgress:0];
    [self.label setText:[NSString string]];
}

// ビューが表示された直後の処理
- (void)viewDidAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewDidAppear:animated];
    
    // 設定されている情報に従って、アップロード処理もしくは
    // ダウンロード処理を開始する
    if (self.uploadMode)
    {
        // ラベルを設定する
        self.label.text = @"Uploading...";
        
        // ファイルをアップロードする
        [self uploadURL:self.localURL
                  toURL:self.remoteURL];
    }
    else
    {
        // ラベルを設定する
        self.label.text = @"Downloading...";
        
        // ファイルをダウンロードする
        [self downloadURL:self.remoteURL
                    toURL:self.localURL
             withFileSize:self.fileSize];
    }   
}

// アップロード開始
- (void)uploadURL:(NSURL *)localURL
            toURL:(NSURL *)remoteURL
{
    // アップロードするファイルとアップロード先が
    // 指定されている必要がある
    BOOL ret = NO;
    
    if (remoteURL && localURL)
    {
        // 読み込みストリームを作成する
        // ローカルファイルからの読み込み処理は同期処理とする
        _readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                                 (CFURLRef)localURL);
        
        // 書き込みストリームを作成する
        // リモートファイルへの書き込み処理は非同期処理とする
        _writeStream = [self createFTPWriteStream:remoteURL];
        
        // 進捗率の計算用の変数を初期化する
        _transferedSize = 0;
        
        // ファイルサイズを取得する
        NSDictionary *attr;
        attr = [[NSFileManager defaultManager]
                attributesOfItemAtPath:localURL.path
                error:NULL];
        _fileSize = [[attr objectForKey:NSFileSize]
                     unsignedLongLongValue];
        
        // 両方とも作成できたら、ストリームを開く
        if (_readStream && _writeStream)
        {
            // 読み込みストリームを開く
            ret = CFReadStreamOpen(_readStream);
            if (ret)
            {
                // 書き込みストリームを開く
                ret = CFWriteStreamOpen(_writeStream);
            }
        }
    }
    
    // エラーが発生していたら、エラー表示する
    if (!ret)
    {
        // 中途半端なストリームを解放する
        [self releaseStream];
        
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
        [self dismissModalViewControllerAnimated:YES];
    }
}

// ダウンロード処理
- (void)downloadURL:(NSURL *)remoteURL
              toURL:(NSURL *)localURL
       withFileSize:(uint64_t)fileSize
{
    // ダウンロードするファイルとダウンロード先が
    // 指定されている必要がある
    BOOL ret = NO;
    
    if (remoteURL && localURL)
    {
        // 読み込みストリームを作成する
        // リモートファイルからの読み込み処理は非同期処理とする
        _readStream = [self createFTPReadStream:remoteURL];
        
        // 書き込みストリームを作成する
        // ローカルファイルへの書き込み処理は同期処理とする
        _writeStream = 
        CFWriteStreamCreateWithFile(kCFAllocatorDefault,
                                    (CFURLRef)localURL);
        
        // 進捗率の計算用の変数を初期化する
        _transferedSize = 0;
        _fileSize = fileSize;
        
        // 両方とも作成できたら、ストリームを開く
        if (_readStream && _writeStream)
        {
            // 読み込みストリームを開く
            ret = CFReadStreamOpen(_readStream);
            if (ret)
            {
                // 書き込みストリームを開く
                ret = CFWriteStreamOpen(_writeStream);
            }
        }
    }
    
    // エラーが発生していたら、エラー表示する
    if (!ret)
    {
        // 中途半端なストリームを解放する
        [self releaseStream];
        
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
        
        // ビューを閉じて、前の画面に戻る
        [self dismissModalViewControllerAnimated:YES];
    }
}

// ストリームを閉じて解放する
- (void)releaseStream
{
    // 読み込みストリームを解放する
    if (_readStream)
    {
        CFReadStreamUnscheduleFromRunLoop(_readStream,
                                          CFRunLoopGetCurrent(),
                                          kCFRunLoopCommonModes);
        CFReadStreamClose(_readStream);
        CFRelease(_readStream);
        _readStream = nil;
    }
    
    // 書き込みストリームを解放する
    if (_writeStream)
    {
        CFWriteStreamUnscheduleFromRunLoop(_writeStream,
                                           CFRunLoopGetCurrent(),
                                           kCFRunLoopCommonModes);
        CFWriteStreamClose(_writeStream);
        CFRelease(_writeStream);
        _writeStream = nil;
    }
}

// FTP上のファイルに対する読み込みストリームを作成する
- (CFReadStreamRef)createFTPReadStream:(NSURL *)url
{
    // 読み込みストリームを作成する
    CFReadStreamRef readStream;
    
    readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault,
                                              (CFURLRef)url);
    
    // ストリームにユーザー名を設定する
    CFReadStreamSetProperty(readStream,
                            kCFStreamPropertyFTPUserName,
                            (CFTypeRef)self.userName);
    // ストリームにパスワードを設定する
    CFReadStreamSetProperty(readStream,
                            kCFStreamPropertyFTPPassword,
                            (CFTypeRef)self.password);
    // ストリームにパッシブモードを設定する
    CFReadStreamSetProperty(readStream,
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
    BOOL ret = NO;
    
    ret = CFReadStreamSetClient(readStream,
                                events,
                                readCallbackProc,
                                &myContext);
    if (ret)
    {
        // ランループにセットする
        CFReadStreamScheduleWithRunLoop(readStream,
                                        CFRunLoopGetCurrent(),
                                        kCFRunLoopCommonModes);
    }
    else
    {
        // もし失敗していたら解放する
        CFRelease(readStream);
        readStream = nil;
    }
    
    // 読み込みストリームを返す
    return readStream;
    
}

// FTP上のファイルに対する書き込みストリームを作成する
- (CFWriteStreamRef)createFTPWriteStream:(NSURL *)url
{
    // 書き込みストリームを作成する
    CFWriteStreamRef writeStream;
    
    writeStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, 
                                                (CFURLRef)url);
    
    // ストリームにユーザー名を設定する
    CFWriteStreamSetProperty(writeStream,
                             kCFStreamPropertyFTPUserName,
                             (CFTypeRef)self.userName);
    // ストリームにパスワードを設定する
    CFWriteStreamSetProperty(writeStream,
                             kCFStreamPropertyFTPPassword,
                             (CFTypeRef)self.password);
    // ストリームにパッシブモードを設定する
    CFWriteStreamSetProperty(writeStream,
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
    events = (kCFStreamEventCanAcceptBytes |
              kCFStreamEventErrorOccurred);
    
    // コールバック関数を設定する
    BOOL ret;
    
    ret = CFWriteStreamSetClient(writeStream, 
                                 events, 
                                 writeCallbackProc, 
                                 &myContext);
    
    if (ret)
    {
        // ランループにセットする
        CFWriteStreamScheduleWithRunLoop(writeStream,
                                         CFRunLoopGetCurrent(),
                                         kCFRunLoopCommonModes);
    }
    else
    {
        // もし失敗していたら解放する
        CFRelease(writeStream);
        writeStream = nil;
    }
    
    // 書き込みストリームを返す
    return writeStream;
}

// ストリームのイベント処理メソッド
// このメソッドは読み込み処理と書き込み処理の両方に使用する
- (void)handleEvent:(CFStreamEventType)event
{
    if (event == kCFStreamEventHasBytesAvailable)
    {
        // データを受信したとき
        [self handleBytesAvailable];
    }
    else if (event == kCFStreamEventEndEncountered)
    {
        // 最後まで受信したとき
        [self handleEndEncountered];
    }
    else if (event == kCFStreamEventCanAcceptBytes)
    {
        // データを書き込めるとき
        [self handleCanAcceptBytes];
    }
    else if (event == kCFStreamEventErrorOccurred)
    {
        // エラーが起きたとき
        [self handleErrorOccurred];
    }
}

// データを受信したときの処理
- (void)handleBytesAvailable
{
    // ストリームから読み込む
    CFIndex numOfBytes;
    unsigned char buf[kBufferSize];
    
    numOfBytes = CFReadStreamRead(_readStream,
                                  buf,
                                  kBufferSize);
    if (numOfBytes > 0)
    {
        // 読み込んだデータを書き込みストリームに書き込む
        CFIndex bytesWritten;
        bytesWritten = CFWriteStreamWrite(_writeStream,
                                          buf,
                                          numOfBytes);
        if (bytesWritten > 0)
        {
            // プログレスビューを更新する
            _transferedSize += bytesWritten;
            
            if (_fileSize > 0)
            {
                self.progressView.progress =
                (double)_transferedSize / (double)_fileSize;
                
                [self.progressView setNeedsDisplay];
            }
        }
        else
        {
            // これ以上書き込めないかエラーが発生したとき
            [self handleErrorOccurred];
        }
    }
    else if (numOfBytes == 0)
    {
        // 最後まで読み込んだとき
        [self handleEndEncountered];
    }
    else
    {
        // エラーが起きたとき
        [self handleErrorOccurred];
    }
}

// データを最後まで受信したときの処理
- (void)handleEndEncountered
{
    // ストリームが終了状態になっていれば完了
    if (CFReadStreamGetStatus(_readStream) == kCFStreamStatusAtEnd)
    {
        // ストリームを閉じる
        [self releaseStream];
        
        // ビューを閉じて前の画面に戻る
        [self dismissModalViewControllerAnimated:YES];
    }
}

// データを書き込めるとき
- (void)handleCanAcceptBytes
{
    // 読み込みストリームからデータを読み込む
    unsigned char buf[kBufferSize];
    CFIndex numOfBytes = 0;
    
    if (CFReadStreamHasBytesAvailable(_readStream))
    {
        numOfBytes = CFReadStreamRead(_readStream,
                                      buf,
                                      kBufferSize);
    }
    
    if (numOfBytes > 0)
    {
        // 読み込んだデータを書き込みストリームに書き込む
        CFIndex bytesWritten;
        bytesWritten = CFWriteStreamWrite(_writeStream,
                                          buf,
                                          numOfBytes);
        if (bytesWritten > 0)
        {
            // プログレスビューを更新する
            _transferedSize += bytesWritten;
            
            if (_fileSize > 0)
            {
                self.progressView.progress = 
                (double)_transferedSize / (double)_fileSize;
            }
        }
        else
        {
            // これ以上書き込めないかエラーが発生したとき
            [self handleErrorOccurred];
        }
    }
    else if (numOfBytes == 0)
    {
        // 最後まで読み込み済み
        [self handleEndEncountered];
    }
    else
    {
        // エラーが起きたとき
        [self handleErrorOccurred];
    }
}

// エラーが起きたとき
- (void)handleErrorOccurred
{
    // ストリームを閉じる
    [self releaseStream];
    
    // エラーメッセージを表示する
    UIAlertView *alert;
    
    alert = [[UIAlertView alloc]
             initWithTitle:@"Error"
             message:@"Failed to transfer."
             delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    // ビューを閉じて前の画面に戻る
    [self dismissModalViewControllerAnimated:YES];
}

@end

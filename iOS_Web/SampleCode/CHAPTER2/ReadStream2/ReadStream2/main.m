#import <Foundation/Foundation.h>

// バッファサイズの定義
static const size_t kBufferSize = 512;

// コールバック関数に渡すアプリケーション独自の構造体の定義
// ここでは、読み込んだデータを格納するデータと終了フラグを定義している
typedef struct MyContextInfo {
    BOOL isEnded;
    NSMutableData *data;
} MyContextInfo;

//
// プロトタイプ宣言
//
void callbackProc(CFReadStreamRef stream,
                  CFStreamEventType event,
                  void *myContextInfo);

void handleHasBytesAvailable(CFReadStreamRef stream,
                             CFStreamEventType event,
                             MyContextInfo *myContextInfo);

void handleEndEncountered(CFReadStreamRef stream,
                          CFStreamEventType event,
                          MyContextInfo *myContextInfo);

void handleErrorOccurred(CFReadStreamRef stream,
                         CFStreamEventType event,
                         MyContextInfo *myContextInfo);

//　メイン関数
int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    // ローカルファイルに対する読み込みストリームを作成する
    // ここでは「/Image1.jpg」ファイルに対するストリームを作成する
    NSURL *fileURL = [NSURL fileURLWithPath:@"/Image.jpg"];
    CFReadStreamRef readStream;
    
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    
    if (readStream)
    {
        // コールバック関数に渡すデータの初期化
        MyContextInfo myContextInfo;
        myContextInfo.data = [NSMutableData dataWithCapacity:0];
        myContextInfo.isEnded = NO;
        
        // コールバック関数に渡すデータの設定
        // メンバー「info」には、アプリケーションの任意の情報を指定できる
        // メンバー「retain」、メンバー「release」、
        // メンバー「copyDescription」には、このデータの保持、解放、
        // 説明文取得で呼び出す関数を指定することができる。
        // 「NSObject」クラスの、「retain」メソッド、「release」メソッド
        // 「description」メソッドに相当する関数といえる。
        CFStreamClientContext myContext;
        
        myContext.version = 0;
        myContext.info = (void *)&myContextInfo;
        myContext.retain = NULL;
        myContext.release = NULL;
        myContext.copyDescription = NULL;
        
        // コールバック関数を呼び出すイベントの設定
        CFOptionFlags events;
        events = (kCFStreamEventHasBytesAvailable |
                  kCFStreamEventErrorOccurred |
                  kCFStreamEventEndEncountered);
        
        // コールバック関数を設定する
        if (CFReadStreamSetClient(readStream,
                                  events,
                                  callbackProc,
                                  &myContext))
        {
            // ランループにセットする
            CFReadStreamScheduleWithRunLoop(readStream,
                                            CFRunLoopGetCurrent(),
                                            kCFRunLoopCommonModes);
            
            // ストリームを開く
            if (CFReadStreamOpen(readStream))
            {
                // ランループを走らせる
                // 通常のiOSアプリの場合は、このようにする必要はなく、
                // 「UIApplication」クラスが内部でランループを走らせる
                while (!myContextInfo.isEnded)
                {
                    NSAutoreleasePool *subPool =
					[[NSAutoreleasePool alloc] init];
                    
                    [[NSRunLoop currentRunLoop] runUntilDate:
                     [NSDate dateWithTimeIntervalSinceNow:1]];
                    
                    [subPool release];
                }
                
                // ストリームを閉じる
                CFReadStreamClose(readStream);
            }
        }
		
        // ストリームを解放する
        CFRelease(readStream);
    }
    
    [pool drain];
    return 0;
}

// コールバック関数
void callbackProc(CFReadStreamRef stream,
                  CFStreamEventType event,
                  void *myContextInfo)
{
    if (event == kCFStreamEventHasBytesAvailable)
    {
        // 読み込むデータがあるとき
        handleHasBytesAvailable(stream,
                                event,
                                (MyContextInfo *)myContextInfo);
    }
    else if (event == kCFStreamEventEndEncountered)
    {
        // 最後まで読み込んだとき
        handleEndEncountered(stream,
                             event,
                             (MyContextInfo *)myContextInfo);
    }
    else if (event == kCFStreamEventErrorOccurred)
    {
        // エラーが起きたとき
        handleErrorOccurred(stream, 
                            event,
                            (MyContextInfo *)myContextInfo);
    }
}

// 読み込むデータがあるときに実行する関数
void handleHasBytesAvailable(CFReadStreamRef stream,
                             CFStreamEventType event,
                             MyContextInfo *myContextInfo)
{
    // ストリームから読み込む
    CFIndex numOfBytes;
    unsigned char buf[kBufferSize];
    
    numOfBytes = CFReadStreamRead(stream, buf, kBufferSize);
    if (numOfBytes > 0)
    {
        [myContextInfo->data appendBytes:buf
                                  length:numOfBytes];
    }
}

// 最後まで読み込んだときに実行する関数
void handleEndEncountered(CFReadStreamRef stream,
                          CFStreamEventType event,
                          MyContextInfo *myContextInfo)
{
    // 終了フラグをセット
    myContextInfo->isEnded = YES;
    
    // ランループから取り除く
    CFReadStreamUnscheduleFromRunLoop(stream,
                                      CFRunLoopGetCurrent(),
                                      kCFRunLoopCommonModes);
	
    // 読み込んだデータをファイルに出力する
    [myContextInfo->data writeToFile:@"/Out.jpg"
                          atomically:YES];
}

// エラーが起きたときに実行する関数
void handleErrorOccurred(CFReadStreamRef stream,
                         CFStreamEventType event,
                         MyContextInfo *myContextInfo)
{
    // ログに出力
    NSLog(@"Error Occurred");
    
    // 終了フラグをセット
    myContextInfo->isEnded = YES;
    
    // ランループから取り除く
    CFReadStreamUnscheduleFromRunLoop(stream,
                                      CFRunLoopGetCurrent(),
                                      kCFRunLoopCommonModes);
}

#import <Foundation/Foundation.h>

// バッファサイズの定義
static const size_t kSplitSize = 512;

// コールバック関数に渡すアプリケーション独自の構造体の定義
// ここでは、書き込みに関する情報を定義している
typedef struct MyContextInfo {
    BOOL isEnded;
    const unsigned char *bytes;
    CFIndex curOffset;
    CFIndex byteLength;
} MyContextInfo;

//
// プロトタイプ宣言
//

void callbackProc(CFWriteStreamRef stream,
                  CFStreamEventType event,
                  void *myContextInfo);

void handleCanAcceptBytes(CFWriteStreamRef stream,
                          CFStreamEventType event,
                          MyContextInfo *myContextInfo);

void handleErrorOccurred(CFWriteStreamRef stream,
                         CFStreamEventType event,
                         MyContextInfo *myContextInfo);

// メイン関数
int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    // 書き込む元データを取得する
    NSData *srcData;
    srcData = [NSData dataWithContentsOfFile:@"/Image.jpg"];
    
    if (!srcData || [srcData length] == 0)
    {
        // ファイルの読み込みに失敗したとき
        NSLog(@"Couldn't open the source file");
        return 0;
    }
    
    // ここではローカルファイルに対する書き込みストリームを作成する
    NSURL *fileURL = [NSURL fileURLWithPath:@"/Out.jpg"];
    CFWriteStreamRef writeStream;
    
    writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault,
                                              (CFURLRef)fileURL);
    
    if (writeStream)
    {
        // コールバック関数に渡すデータの初期化
        MyContextInfo myContextInfo;
        myContextInfo.isEnded = NO;
        myContextInfo.bytes = (const unsigned char *)[srcData bytes];
        myContextInfo.curOffset = 0;
        myContextInfo.byteLength = [srcData length];
        
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
        events = (kCFStreamEventCanAcceptBytes |
                  kCFStreamEventErrorOccurred);
        
        // コールバック関数を設定する
        if (CFWriteStreamSetClient(writeStream,
                                   events,
                                   callbackProc,
                                   &myContext))
        {
            // ランループにセットする
            CFWriteStreamScheduleWithRunLoop(writeStream,
                                             CFRunLoopGetCurrent(),
                                             kCFRunLoopCommonModes);
            
            // ストリームを開く
            if (CFWriteStreamOpen(writeStream))
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
                CFWriteStreamClose(writeStream);
            }
        }
        
        
        // ストリームを解放する
        CFRelease(writeStream);
    }
    
    [pool drain];
    return 0;
}

// コールバック関数
void callbackProc(CFWriteStreamRef stream,
                  CFStreamEventType event,
                  void *myContextInfo)
{
    if (event == kCFStreamEventCanAcceptBytes)
    {
        // 書き込み可能なとき
        handleCanAcceptBytes(stream,
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

// 書き込み可能なときに実行する関数
void handleCanAcceptBytes(CFWriteStreamRef stream,
                          CFStreamEventType event,
                          MyContextInfo *myContextInfo)
{
    // 書き込むバイト数を計算する
    CFIndex numOfBytes = kSplitSize;
    CFIndex remain;
    
    remain = myContextInfo->byteLength - myContextInfo->curOffset;
    
    if (remain < numOfBytes)
        numOfBytes = remain;
    
    if (numOfBytes > 0)
    {
        // 書き込むバイト列を用意
        const unsigned char *p;
        p = myContextInfo->bytes + myContextInfo->curOffset;
        
        // ストリームに書き込む
        CFIndex bytesWritten;
        bytesWritten = CFWriteStreamWrite(stream, p, numOfBytes);
        
        // 書き込んだ分だけオフセットをずらす
        if (bytesWritten > 0)
        {
            myContextInfo->curOffset += bytesWritten;
        }
        else
        {
            // エラーが起きたか、これ以上書き込めない
            if (bytesWritten < 0)
            {
                // エラー発生
                NSLog(@"Error Occurred");
            }
            
            myContextInfo->isEnded = YES;
        }
    }
    else
    {
        // 書き込むデータがない
        myContextInfo->isEnded = YES;
    }
	
    // これ以上書き込まないときは、ランループから取り除く
    if (myContextInfo->isEnded)
    {
        // ランループから取り除く
        CFWriteStreamUnscheduleFromRunLoop(stream,
                                           CFRunLoopGetCurrent(),
                                           kCFRunLoopCommonModes);
    }
}

// エラーが起きたときに実行する関数
void handleErrorOccurred(CFWriteStreamRef stream,
                         CFStreamEventType event,
                         MyContextInfo *myContextInfo)
{
    // ログに出力
    NSLog(@"Error Occurred");
    
    // 終了フラグをセット
    myContextInfo->isEnded = YES;
    
    // ランループから取り除く
    CFWriteStreamUnscheduleFromRunLoop(stream,
									   CFRunLoopGetCurrent(),
									   kCFRunLoopCommonModes);
}

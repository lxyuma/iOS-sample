#import <Foundation/Foundation.h>

// バッファサイズの定義
static const size_t kBufferSize = 512;

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
        // ストリームを開く
        BOOL shouldContinue;
        shouldContinue = CFReadStreamOpen(readStream);
        
        if (!shouldContinue)
        {
            NSLog(@"Couldn't open the stream");
        }
        
        // 読み込んだバイト列を格納するデータを作成する
        NSMutableData *data = [NSMutableData dataWithCapacity:0];
        
        // 読み込んだデータを一時的に入れるバッファ
        unsigned char buf[kBufferSize];
        
        // 読み込み処理を繰り返すループ
        while (shouldContinue)
        {
            NSAutoreleasePool *pool2 =
			[[NSAutoreleasePool alloc] init];
            
            // ストリームに読み込んでいないデータがあるかチェックする
            if (CFReadStreamHasBytesAvailable(readStream))
            {
                // バッファに読み込む
                CFIndex numOfBytes;
                numOfBytes = CFReadStreamRead(readStream,
                                              buf,
                                              kBufferSize);
                
                if (numOfBytes > 0)
                {
                    // バッファに読み込めた
                    [data appendBytes:buf
                               length:numOfBytes];
                }
                else if (numOfBytes == 0)
                {
                    // ストリームの状態を取得する
                    CFStreamStatus status;
                    status = CFReadStreamGetStatus(readStream);
                    
                    if (status == kCFStreamStatusAtEnd)
                    {
                        // 全データ読み込み完了
                        shouldContinue = NO;
                        
                        // 読み込んだデータをファイルに出力する
                        [data writeToFile:@"/Out.jpg"
                               atomically:YES];
                    }
                }
                else
                {
                    // エラー発生
                    NSLog(@"Error occurred\n");
                    shouldContinue = NO;
                }
            }
            else
            {
                // ストリームの読み込みが完了していないが、
                // データを待っているときに行う処理
                // ... 省略 ...
            }
            
            [pool2 drain];
        }
        
        // ストリームを閉じる
        CFReadStreamClose(readStream);
        
        // ストリームを解放する
        CFRelease(readStream);
    }
    
    [pool drain];
    return 0;
}

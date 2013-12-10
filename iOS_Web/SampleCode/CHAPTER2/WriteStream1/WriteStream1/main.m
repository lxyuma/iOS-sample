#import <Foundation/Foundation.h>

// バッファサイズの定義
static const size_t kSplitSize = 512;

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
    // 書き込みストリームに書き込むデータを取得する
    // ここでは、ローカルファイルを読み込む
    NSData *srcData;
    srcData = [NSData dataWithContentsOfFile:@"/Image.jpg"];
    
    if (!srcData || [srcData length] == 0)
    {
        // ファイルの読み込みに失敗したとき
        NSLog(@"Couldn't open the source file");
        return 0;
    }
    
    // 書き込みストリームを作成する
    // ここではローカルファイルに対する書き込みストリームを作成する
    NSURL *url;
    url = [NSURL fileURLWithPath:@"/Out.jpg"];
    
    CFWriteStreamRef writeStream;
    writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault,
                                              (CFURLRef)url);
    
    if (writeStream)
    {
        // ストリームを開く
        if (CFWriteStreamOpen(writeStream))
        {
            // 一気に書き込むことも可能だが、ここでは数回に分けて書き込む
            const unsigned char *p, *end;
            
            p = (const unsigned char *)[srcData bytes];
            end = p + [srcData length];
            
            while (p < end)
            {
                NSAutoreleasePool *subPool;
                subPool = [[NSAutoreleasePool alloc] init];
                
                // 書き込むサイズを計算する
                CFIndex numOfBytes = kSplitSize;
                if ((end - p) < numOfBytes)
                    numOfBytes = end - p;
                
                // 書き込み可能かチェックする
                if (numOfBytes > 0 &&
                    CFWriteStreamCanAcceptBytes(writeStream))
                {
                    // 変数「numOfBytes」だけ書き込む
                    CFIndex bytesWritten;
                    bytesWritten = CFWriteStreamWrite(writeStream,
                                                      p,
                                                      numOfBytes);
                    
                    if (bytesWritten > 0)
                    {
                        // 書き込み成功。書き込んだ分だけバッファをずらす
                        p += bytesWritten;
                    }
                    else
                    {
                        // エラーが起きたか、書き込み先にこれ以上、
                        // 書き込めないとき
                        if (bytesWritten < 0)
                        {
                            // エラー発生
                            NSLog(@"Error Occurred");
                        }
                        
                        [subPool drain];
                        break;
                    }
                }
                else
                {
                    // 書き込み可能になるまで待機している間の処理を行う
                    // ... 省略 ...
                }
                
                [subPool drain];
            }
            
            // ストリームを閉じる
            CFWriteStreamClose(writeStream);
        }
		
        // ストリームを解放する
        CFRelease(writeStream);
    }
	
    [pool drain];
    return 0;
}

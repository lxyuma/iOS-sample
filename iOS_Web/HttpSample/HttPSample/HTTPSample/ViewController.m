//
//  ViewController.m
//  HTTPSample
//
//  Created by zabaglione on 2013/09/14.
//  Copyright (c) 2013年 zabaglione. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _imageData = [[NSMutableData alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark NSURLの使用例
- (IBAction)btnNSURL:(id)sender {
    //「強火で進め」様のサイトより引用
    // http://d.hatena.ne.jp/nakamura001/20110421/1303404341
    
    NSURL *baseUrl = [NSURL URLWithString:@"http://user:password@.com:8080"];
    NSURL *url = [NSURL URLWithString:@"hoge/fuga/index.html?a=1&b=2#test" relativeToURL:baseUrl];
    
    NSLog(@"absoluteString : %@", [url absoluteString]);
    NSLog(@"absoluteURL : %@", [url absoluteURL]);
    NSLog(@"baseURL : %@", [url baseURL]);
    NSLog(@"fragment : %@", [url fragment]);
    NSLog(@"host : %@", [url host]);
    NSLog(@"lastPathComponent : %@", [url lastPathComponent]);
    NSLog(@"parameterString : %@", [url parameterString]);
    NSLog(@"password : %@", [url password]);
    NSLog(@"path : %@", [url path]);
    NSLog(@"pathComponents : %@", [url pathComponents]);
    NSLog(@"pathExtension : %@", [url pathExtension]);
    NSLog(@"port : %@", [url port]);
    NSLog(@"query : %@", [url query]);
    NSLog(@"relativePath : %@", [url relativePath]);
    NSLog(@"relativeString : %@", [url relativeString]);
    NSLog(@"resourceSpecifier : %@", [url resourceSpecifier]);
    NSLog(@"scheme : %@", [url scheme]);
    NSLog(@"standardizedURL : %@", [url standardizedURL]);
    NSLog(@"user : %@", [url user]);
}

#pragma mark -
#pragma mark 同期通信1
- (IBAction)btnSyncSend1:(id)sender {
    NSURL *url1 = [NSURL URLWithString:@"http://192.168.3.89/"];
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    NSLog( @"data=%@", [data1 description]);
    
    
    //    Options for methods used to read NSData objects.
    //        enum {
    //            NSDataReadingMappedIfSafe = 1UL << 0,
    //            NSDataReadingUncached = 1UL << 1,
    //            NSDataReadingMappedAlways = 1UL << 3,
    //        };
    //    typedef NSUInteger NSDataReadingOptions;
    NSURL *url2 = [NSURL URLWithString:@"http://192.168.3.89/index.html"];
    NSError *error = nil;
    NSData *data2 = [NSData dataWithContentsOfURL:url2
                                          options:NSDataReadingUncached
                                            error:&error];
    if (data2) {
        NSLog( @"Recived data=[%@]", [data2 description]);
    } else {
        NSLog( @"Error occurred.");
        NSLog( @"  code=%d", [error code] );
        NSLog( @"  domain=%@", [error domain] );
        NSLog( @"  localizedDescription=%@", [error localizedDescription] );
        NSLog( @"  localizedFailureReason=%@", [error localizedFailureReason] );
    }

    //    The following constants are provided by NSString as possible string encodings.
    //
    //    enum {
    //        NSASCIIStringEncoding = 1,
    //        NSNEXTSTEPStringEncoding = 2,
    //        NSJapaneseEUCStringEncoding = 3,
    //        NSUTF8StringEncoding = 4,
    //        NSISOLatin1StringEncoding = 5,
    //        NSSymbolStringEncoding = 6,
    //        NSNonLossyASCIIStringEncoding = 7,
    //        NSShiftJISStringEncoding = 8,
    //        NSISOLatin2StringEncoding = 9,
    //        NSUnicodeStringEncoding = 10,
    //        NSWindowsCP1251StringEncoding = 11,
    //        NSWindowsCP1252StringEncoding = 12,
    //        NSWindowsCP1253StringEncoding = 13,
    //        NSWindowsCP1254StringEncoding = 14,
    //        NSWindowsCP1250StringEncoding = 15,
    //        NSISO2022JPStringEncoding = 21,
    //        NSMacOSRomanStringEncoding = 30,
    //        NSUTF16StringEncoding = NSUnicodeStringEncoding,
    //        NSUTF16BigEndianStringEncoding = 0x90000100,
    //        NSUTF16LittleEndianStringEncoding = 0x94000100,
    //        NSUTF32StringEncoding = 0x8c000100,
    //        NSUTF32BigEndianStringEncoding = 0x98000100,
    //        NSUTF32LittleEndianStringEncoding = 0x9c000100,
    //        NSProprietaryStringEncoding = 65536
    //    };
    NSURL *url3 = [NSURL URLWithString:@"http://192.168.3.89/"];
    NSString *data3 = [NSString stringWithContentsOfURL:url3
                                               encoding:NSUTF8StringEncoding
                                                  error:&error];
    if (data3) {
        NSLog( @"Recived data=[%@]", [data3 description]);
    } else {
        NSLog( @"Error occurred.");
        NSLog( @"  code=%d", [error code] );
        NSLog( @"  domain=%@", [error domain] );
        NSLog( @"  localizedDescription=%@", [error localizedDescription] );
        NSLog( @"  localizedFailureReason=%@", [error localizedFailureReason] );
    }
}

#pragma mark -
#pragma mark 同期通信2
- (IBAction)btnSyncSend2:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://192.168.3.89/images/image1.jpg"];
    //// NSURL *url = [NSURL URLWithString:@"http://192.168.3.89/images/hoge.jpg"];
    //// NSURL *url = [NSURL URLWithString:@"hogehoge://192.168.3.89/images/"];

    // リクエストの作成(GETメソッド)
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    // レスポンス情報の格納用
    NSHTTPURLResponse *response;
    // エラー情報の格納用
    NSError *error = nil;
    
    // 同期通信。戻り値はレスポンスのデータ。
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    // レスポンスデータが得られて、かつレスポンスのステータスコードが200(正常終了)
    if (data && response.statusCode == 200) {
        NSLog( @"Success!" );
    } else {
        // データの取得に失敗、あるいはステータスコードが200以外のとき
        NSLog( @"Fail! error:%@ status:%d", error, response.statusCode);
    }
}

#pragma mark -
#pragma mark 非同期処理1
- (IBAction)btnAsyncSend1:(id)sender
{
    [self startDownload1:@"http://192.168.3.89/images/image5.jpg"];
}

- (void)startDownload1:(NSString *)urlText
{
    NSURL *url = [NSURL URLWithString:urlText];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
    [_imageData setLength:0];
    [connection start];
}

#pragma mark -
#pragma mark NSURLConnectionDelegateプロトコルの実装
// レスポンス受信直後
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    // NSHTTPURLResponseクラスにキャストしてステータスコードを調べる
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse.statusCode != 200) {
        NSLog( @"NSURLConnection error %d", httpResponse.statusCode);
    }

    // 受信データ長を取得
    _imageDataLength = [httpResponse expectedContentLength];
}

// データの受信直後(複数回の呼び出しあり)
- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [_imageData appendData:data];
    NSLog( @"recived data length=%d : total data length=%ld", [_imageData length], _imageDataLength);
}

// すべてのデータの受信完了
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog( @"Did finish loading.");
}

// 接続または通信の失敗
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog( @"NSURLConnection error %@", error);
}

// データのアップロード直後(複数回呼び出しあり)
- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

// キャッシュを受信するかどうかの動作を決める
// 詳細はAppleのドキュメントを参照
// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html#//apple_ref/doc/uid/20001836-BAJEAIEE
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

// リクエストごとにリダイレクトを許可するかどうかを決める
//
- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

#pragma mark -
#pragma mark 非同期処理2
- (IBAction)btnAsyncSend2:(id)sender
{
    [self startDownload2:@"http://192.168.3.89/images/image5.jpg"];
}

- (void)startDownload2:(NSString *)urlText
{
    NSURL *url = [NSURL URLWithString:urlText];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [_imageData setLength:0];

    // 新たにOperationQueue(=別スレッド)を作成して受信処理を行う
    NSOperationQueue *subQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:subQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    {
        if (error) {
            // エラー処理を行う。
            NSLog(@"unknown error occurred. reason = %@", error);
            return ;
        }
        
        // NSHTTPURLResponseクラスにキャストしてステータスコードを調べる
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            NSLog( @"NSURLConnection error %d", httpResponse.statusCode);
        } else {
            NSLog(@"success request!!");
            NSLog( @"recived data length=%d", [data length]);
            
            // UIの操作はメインスレッドで行う必要がある
            // そのため、メインスレッドで使うデータをインスタンス変数に設定する
            NSLog( @"1: now thread is = %@", [NSOperationQueue currentQueue]);
            _imageData.data = data;
            NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock: ^{
                // メインスレッドの操作
                NSLog( @"2: now thread is = %@", [NSOperationQueue currentQueue]);
                NSLog( @"_imageData length=%d", [_imageData length]);
            }];
        }
    }];
}

@end

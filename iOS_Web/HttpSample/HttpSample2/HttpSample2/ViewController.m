//
//  ViewController.m
//  HttpSample2
//
//  Created by zabaglione on 2013/09/15.
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

- (IBAction)btnAsyncDownload3:(id)sender
{
    [self startDownload3:@"http://192.168.3.89/images/image5.jpg"];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)startDownload3:(NSString *)urlText
{
    NSURL *url = [NSURL URLWithString:urlText];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
    [_imageData setLength:0];
    [connection start];
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    // 実行時にメソッド名を調べる。
    // 「statusCode」メソッドがあるなら、NSHTTPURLResponseクラスなので
    // キャストして処理を続ける
    if([response respondsToSelector:@selector(statusCode)]){
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        
        // 必要に応じてレスポンスコード毎に処理を実装します，
        
        // レスポンスが HTTP 404 の場合に呼ばれます．
        if(statusCode == 404){
            [connection cancel];  // stop connecting; no more delegate messages
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
        
        // レスポンスが HTTP 200 の場合に呼ばれます．
        if(statusCode == 200){
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            // 受信データ長を取得
            _imageDataLength = [response expectedContentLength];
        }
    }
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    NSString *localizedDescription = [error localizedDescription];
    NSString *localizedFailureReason = [error localizedFailureReason];
    NSString *localizedRecoverySuggestion = [error localizedRecoverySuggestion];
    NSLog(@"[localizedDescription] %@, [localizedFailureReason] %@, [*localizedRecoverySuggestion] %@",
          localizedDescription, localizedFailureReason, localizedRecoverySuggestion);
}

@end

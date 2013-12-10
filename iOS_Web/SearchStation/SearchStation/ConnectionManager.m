//
//  ConnectionManager.m
//  MyFindMeMfindYou
//
//  Created by Casareal on 12/11/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ConnectionManager.h"

@implementation ConnectionManager
@synthesize receivedData;

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}


// 通信開始
- (NSURLConnection *)connectionRequest:(NSMutableURLRequest *)urlRequest {
    // 受信データを保持する変数を初期化
    receivedData = [[NSMutableData alloc] initWithLength:0];
    // 通信先と接続
    connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    return connection;
}

// サーバからレスポンスを受信(データ受信よりも前に呼ばれる。呼ばれた場合は受信処理をリセット)
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [receivedData setLength:0]; // 受信データをリセット
}

// その都度データを受信(データは少しずつ届くため何度も呼ばれる)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData appendData:data];
}

// すべてのデータを受信することに成功
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [_delegate performSelector:@selector(receiveSucceed:) withObject:self]; //データ受信を通知
}

// 非同期通信エラー
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_delegate performSelector:@selector(receiveFailed:) withObject:self]; // 通信エラーを通知
}
@end

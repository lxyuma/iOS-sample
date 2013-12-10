//
//  ViewController.h
//  HTTPSample
//
//  Created by zabaglione on 2013/09/14.
//  Copyright (c) 2013年 zabaglione. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate>
{
    NSMutableData *_imageData;
    long _imageDataLength;
}

- (IBAction)btnNSURL:(id)sender;
- (IBAction)btnSyncSend1:(id)sender;
- (IBAction)btnSyncSend2:(id)sender;
- (IBAction)btnAsyncSend1:(id)sender;
- (IBAction)btnAsyncSend2:(id)sender;

- (void)startDownload1:(NSString *)urlText;
- (void)startDownload2:(NSString *)urlText;

@end

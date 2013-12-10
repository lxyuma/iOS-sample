//
//  ViewController.h
//  HttpSample2
//
//  Created by zabaglione on 2013/09/15.
//  Copyright (c) 2013年 zabaglione. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate>
{
    NSMutableData *_imageData;
    long _imageDataLength;
}

- (IBAction)btnAsyncDownload3:(id)sender;

- (void)startDownload3:(NSString *)urlText;

@end

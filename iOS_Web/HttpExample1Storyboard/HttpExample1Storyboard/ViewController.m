//
//  ViewController.m
//  HttpExample1Storyboard
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _textView.editable = NO;
}

- (IBAction)btnDownloadImage:(id)sender
{
    // ソフトウェアキーボードを閉じる
    [_url resignFirstResponder];
    
    // バイナリデータのダウンロード
    NSURL *url = [NSURL URLWithString:_url.text];
    NSData *data = [NSData dataWithContentsOfURL:url];
    // UIImageViewで表示
    _imageView.image = [[UIImage alloc] initWithData:data];
}

- (IBAction)btnDownloadText:(id)sender
{
    // ソフトウェアキーボードを閉じる
    [_url resignFirstResponder];
    
    // テキストデータのダウンロード
    NSURL *url = [NSURL URLWithString:_url.text];
    NSError *error = nil;
    NSString *data = [NSString stringWithContentsOfURL:url
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    if (data) {
        _textView.text = data;
    } else {
        NSLog( @"Error occurred.");
        NSLog( @"  code=%d", [error code] );
        NSLog( @"  domain=%@", [error domain] );
        NSLog( @"  localizedDescription=%@", [error localizedDescription] );
        NSLog( @"  localizedFailureReason=%@", [error localizedFailureReason] );
    }
}

- (IBAction)txtEdtingDidEnd:(id)sender {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_url resignFirstResponder];
    return YES;
}
@end

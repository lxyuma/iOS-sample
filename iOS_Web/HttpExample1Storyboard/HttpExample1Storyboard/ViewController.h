//
//  ViewController.h
//  HttpExample1Storyboard
//
//  Created by zabaglione on 2013/09/14.
//  Copyright (c) 2013年 zabaglione. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *url;
- (IBAction)btnDownloadImage:(id)sender;
- (IBAction)btnDownloadText:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

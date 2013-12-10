#import "ImageFileViewController.h"


@implementation ImageFileViewController

// プロパティとメンバー変数の設定
@synthesize imageView = _imageView;
@synthesize filePath = _filePath;

// インスタンスが解放されるときに呼ばれる
- (void)dealloc
{
    // メンバー変数を解放する
    [_imageView release];
    [_filePath release];
    [super dealloc];
}

// nibファイルを読み込むイニシャライザ
- (id)initWithNibName:(NSString *)nibName
               bundle:(NSBundle *)nibBundle
{
    // 親クラスの処理を呼び出す
    self = [super initWithNibName:nibName
                           bundle:nibBundle];
    if (self)
    {
        // メンバー変数を初期化する
        _filePath = nil;
    }
    return self;
}

// ビューがロードされたときに呼ばれるメソッド
- (void)viewDidLoad
{
    // 親クラスの処理を呼び出す
    [super viewDidLoad];
    
    // ナビゲーションバーのタイトルにファイル名を表示する
    [self setTitle:[self.filePath lastPathComponent]];
    
    // 画像ファイルを読み込む
    UIImage *img =
    [[UIImage alloc] initWithContentsOfFile:self.filePath];
    
    if (img)
    {
        // イメージビューにセットする
        [self.imageView setImage:img];
        
        // 念のため、再描画するように設定する
        [self.imageView setNeedsDisplay];
    }
    else
    {
        // 読み込みに失敗したときはエラーメッセージを表示
        NSString *title = @"Error";
        NSString *buttonTitle = @"OK";
        NSString *msg = @"Couldn't load the image.";
        
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:title
                                   message:msg
                                  delegate:nil
                         cancelButtonTitle:buttonTitle
                         otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    // 画像を解放する
    [img release];
}

// 指定された方向に対応するかどうかを返す
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも対応する
    return YES;
}

@end

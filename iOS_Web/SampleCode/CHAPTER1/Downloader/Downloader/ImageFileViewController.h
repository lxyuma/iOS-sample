#import <UIKit/UIKit.h>

// 「ImageFileViewController」クラスのインターフェイス宣言
@interface ImageFileViewController : UIViewController
{
    // イメージを表示するイメージビュー
    UIImageView     *_imageView;
    
    // 表示するファイルのファイルパス
    NSString        *_filePath;
}

// プロパティの定義
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (copy, nonatomic) NSString *filePath;

@end

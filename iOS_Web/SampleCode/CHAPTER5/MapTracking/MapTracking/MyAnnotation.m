#import "MyAnnotation.h"

// 「MyAnnotation」クラスの実装
@implementation MyAnnotation

// プロパティとメンバー変数の設定
@synthesize isStart = _isStart;

// イニシャライザ
- (id)init
{
    self = [super init];
    if (self)
    {
        // メンバー変数を初期化する
        _isStart = NO;
    }
    return self;
}

@end

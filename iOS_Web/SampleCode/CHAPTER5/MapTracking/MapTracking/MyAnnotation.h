#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// 「MyAnnotation」クラスのインターフェイス宣言
@interface MyAnnotation : MKPointAnnotation 
{
    // スタート地点のアノテーションかどうか
    BOOL _isStart;
}

// プロパティの定義
@property (nonatomic, assign) BOOL isStart;

@end

#import <Foundation/Foundation.h>

// 「XMLParam」クラスが存在することを宣言する
@class XMLParam;

// 「UIAlertView」クラスにメソッドを追加する
@interface UIAlertView (AlertViewAddition)

// XML-RPC通信で取得した「fault」エレメントの内容を使って
// アラートビューを初期化するイニシャライザ
- (id)initWithFault:(XMLParam *)fault;

@end

#import <Foundation/Foundation.h>

// 「XMLWriter」クラスのインターフェイス宣言
@interface XMLWriter : NSObject
{
	
}

// メソッド呼び出し用のXMLを作成するメソッド
+ (NSData *)dataForCallMethod:(NSString *)methodName
                       params:(NSArray *)methodParams;

@end

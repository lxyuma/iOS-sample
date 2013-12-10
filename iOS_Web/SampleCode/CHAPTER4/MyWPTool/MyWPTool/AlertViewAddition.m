#import "AlertViewAddition.h"
#import "XMLParam.h"
#import "SharedParameter.h"

// 「UIAlertView」クラスに追加したメソッドの実装
@implementation UIAlertView (AlertViewAddition)

// XML-RPC通信で取得した「fault」エレメントの内容を使って
// アラートビューを初期化するイニシャライザ
- (id)initWithFault:(XMLParam *)fault
{
    // エラーメッセージを指定して初期化するので
    // イニシャライザを呼び出す前に
    // エラー文字列を作成する
    
    // エラー情報を取得する
    NSDictionary *dict = fault.paramValue;
    if (![dict isKindOfClass:[NSDictionary class]])
    {
        // 正しく取得できていない
        [self release];
        return nil;
    }
    
    // エラーコードを取得する
    NSString *errCode = [[dict objectForKey:WPFaultCode] paramValue];
    
    // エラーメッセージを取得する
    NSString *errStr = [[dict objectForKey:WPFaultString] paramValue];
    
    // 表示用の文字列を作成する
    NSString *str;
    str = [NSString stringWithFormat:@"%@(%@)", errStr, errCode];
    
    // 文字列が用意できたので、イニシャライザを呼び出す
    return [self initWithTitle:@"Error"
                       message:str
                      delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
}

@end


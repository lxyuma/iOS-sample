#import "XMLWriter.h"
#import "XMLParam.h"

// 「XMLWriter」クラスの実装
@implementation XMLWriter

// メソッド呼び出し用のXMLを作成するメソッド
+ (NSData *)dataForCallMethod:(NSString *)methodName 
                       params:(NSArray *)methodParams
{
    NSMutableString *workingStr;
    workingStr = [NSMutableString stringWithCapacity:0];
    
    // XMLの冒頭部分を作成
    // テキストエンコーディングには、UTF-8を使用する
    [workingStr appendString:
     @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"];
    
    // メソッド呼び出しのルートタグを出力する
    [workingStr appendString:@"<methodCall>\n"];
    
    // メソッド名を出力する
    [workingStr appendFormat:
     @"<methodName>%@</methodName>\n", methodName];
    
    // パラメータを出力する
    [workingStr appendFormat:@"<params>\n"];
    
    // 各パラメータの値を出力する
    [methodParams enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         // 「param」タグを出力する
         [workingStr appendString:@"<param>\n"];
         
         // パラメータをXMLに変換して出力する
         NSString *paramStr = [obj xmlString];
         if (paramStr)
         {
             [workingStr appendString:paramStr];
         }
		 
         // 改行
         [workingStr appendString:@"\n"];
         
         // 「param」タグを閉じる
         [workingStr appendString:@"</param>\n"];
     }];
    
    // パラメータ出力を閉じるタグを出力する
    [workingStr appendString:@"</params>\n"];
    
    // ルートタグを閉じる
    [workingStr appendString:@"</methodCall>\n"];
    
    // UTF-8で符号化する
    NSData *data;
    data = [workingStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

@end

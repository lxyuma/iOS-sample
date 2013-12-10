#import <Foundation/Foundation.h>

// 「XMLReader」クラスのインターフェイス宣言
@interface XMLReader : NSObject<NSXMLParserDelegate>
{
    // メソッド呼び出しに対するレスポンスのXMLかどうかを記憶するフラグ
    BOOL _isMethodResponse;
    
    // レスポンスの種類。「params」もしくは「fault」が格納される
    NSString *_responseType;
    
    // 取得したパラメータの配列
    // 配列の要素は「XMLParam」クラスのインスタンス
    NSMutableArray *_paramsArray;
    
    // 解析中のパラメータの配列
    // 「array」は入れ子にできる他、構造体の解析中も
    // 入れ子のように扱う必要が有るため、解析中のパラメータは
    // 配列で持つ
    NSMutableArray *_parsingParam;
    
    // 開いているエレメントを入れるための配列
    NSMutableArray *_openedElements;
}

// プロパティの定義
@property (assign, nonatomic) BOOL isMethodResponse;
@property (retain, nonatomic) NSString *responseType;
@property (retain, nonatomic) NSMutableArray *paramsArray;
@property (retain, nonatomic) NSMutableArray *parsingParam;
@property (retain, nonatomic) NSMutableArray *openedElements;


// XML-PRCのレスポンスを読み込むメソッド
// 返された辞書には、キー「params」もしくは
// キー「fault」のいずれかに内容が格納される
+ (NSDictionary *)parseMethodResponse:(NSData *)xmlData;

@end

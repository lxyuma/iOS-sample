#import <Foundation/Foundation.h>

// パラメータの型
extern NSString *XMLParamType_i4;
extern NSString *XMLParamType_int;
extern NSString *XMLParamType_boolean;
extern NSString *XMLParamType_string;
extern NSString *XMLParamType_double;
extern NSString *XMLParamType_dateTime;
extern NSString *XMLParamType_base64;
extern NSString *XMLParamType_array;
extern NSString *XMLParamType_struct;

// 「XMLParam」クラスのインターフェイス宣言
// 「XMLWriter」クラスと「XMLReader」クラスで
// パラメータの表現に使用する
@interface XMLParam : NSObject
{
    // パラメータの型
    NSString *_paramType;
    
    // パラメータの値
    id _paramValue;
    
    // パラメータの名前
    // 構造体のときだけ使用する
    NSString *_paramName;
}

// プロパティの定義
@property (retain) NSString *paramType;
@property (retain) id paramValue;
@property (retain) NSString *paramName;

// イニシャライザ
- (id)initWithParamType:(NSString *)type
                  value:(id)value;

// XML形式の文字列を取得する
- (NSString *)xmlString;

// 型が「array」のときのXML形式の文字列を取得する
- (NSString *)xmlStringArray;

// 型が「struct」のときのXML形式の文字列を取得する
- (NSString *)xmlStringStruct;

// 型が「array」と「struct」のどちらでもないときのXML形式の文字列を取得する
- (NSString *)xmlStringOther;

@end

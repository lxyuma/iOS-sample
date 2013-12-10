#import "XMLParam.h"

// パラメータの型の定義
// 「XMLParam」クラスでパラメータの型を
// 指定するために使用する
NSString *XMLParamType_i4 = @"i4";
NSString *XMLParamType_int = @"int";
NSString *XMLParamType_boolean = @"boolean";
NSString *XMLParamType_string = @"string";
NSString *XMLParamType_double = @"double";
NSString *XMLParamType_dateTime = @"dateTime.iso8601";
NSString *XMLParamType_base64 = @"base64";
NSString *XMLParamType_array = @"array";
NSString *XMLParamType_struct = @"struct";

// 「XMLParam」クラスの実装
@implementation XMLParam

// プロパティとメンバー変数の設定
@synthesize paramType = _paramType;
@synthesize paramValue = _paramValue;
@synthesize paramName = _paramName;

// イニシャライザ
- (id)initWithParamType:(NSString *)type
                  value:(id)value
{
    self = [super init];
    if (self)
    {
        // メンバー変数の初期化
        _paramType = [type retain];
        _paramValue = [value retain];
        _paramName = nil;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_paramType release];
    [_paramValue release];
    [_paramName release];
    [super dealloc];
}

// XML形式の文字列を取得する
- (NSString *)xmlString
{
    // 型によって処理を変更する
    NSString *type = self.paramType;
    
    NSString *str = nil;
    
    if ([type isEqualToString:XMLParamType_array])
    {
        // 「array」のとき
        str = [self xmlStringArray];
    }
    else if ([type isEqualToString:XMLParamType_struct])
    {
        // 「struct」のとき
        str = [self xmlStringStruct];
    }
    else
    {
        // その他
        str = [self xmlStringOther];
    }
    
    return str;
}

// 型が「array」のときのXML形式の文字列を取得する
- (NSString *)xmlStringArray
{
    NSMutableString *str;
    str = [NSMutableString stringWithCapacity:0];
    
    // 「value」タグ、「array」タグ、「data」タグを出力する
    [str appendString:@"<value>\n<array>\n<data>\n"];
    
    // 配列に格納された値を出力する
    [self.paramValue enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
		 NSString *subStr = [obj xmlString];
		 if (subStr)
		 {
			 [str appendFormat:@"%@\n", subStr];
		 }
	 }];
    
    // タグを閉じる
    [str appendString:@"</data>\n</array>\n</value>"];
    
    return str;
}

// 型が「struct」のときのXML形式の文字列を取得する
- (NSString *)xmlStringStruct
{
    NSMutableString *str;
    str = [NSMutableString stringWithCapacity:0];
    
    // 「value」タグ、「struct」タグを出力する
    [str appendString:@"<value>\n<struct>\n"];
    
    // 辞書に格納された値を出力する
    [self.paramValue enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
		 // 出力する値のXML表現を取得する
		 NSString *subStr = [obj xmlString];
		 
		 if (subStr)
		 {
			 // 「member」タグを出力する
			 [str appendString:@"<member>\n"];
			 
			 // 「name」タグとメンバー名を出力する
			 [str appendFormat:@"<name>%@</name>\n", key];
			 
			 // 値を出力する
			 [str appendFormat:@"%@\n", subStr];
			 
			 // 「member」タグを閉じる
			 [str appendString:@"</member>\n"];
		 }
	 }];
    
    // 「struct」タグ、「value」タグを閉じる
    [str appendString:@"</struct>\n</value>"];
    
    return str;
}

// 型が「array」と「struct」のどちらでもないときのXML形式の文字列を取得する
- (NSString *)xmlStringOther
{
    NSMutableString *str;
    str = [NSMutableString stringWithCapacity:0];
    
    // 「value」タグを出力する
    [str appendString:@"<value>"];
    
    // 型を出力する
    [str appendFormat:@"<%@>", self.paramType];
    
    // 値を出力する
    NSString *valStr = [self.paramValue description];
    if (valStr)
    {
        [str appendString:valStr];
    }
    
    // 型を閉じる
    [str appendFormat:@"</%@>", self.paramType];
    
    // 「value」タグを閉じる
    [str appendString:@"</value>"];
    
    return str;
}

@end

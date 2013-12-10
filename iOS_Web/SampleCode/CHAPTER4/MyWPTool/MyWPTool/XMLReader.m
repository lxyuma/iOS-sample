#import "XMLReader.h"
#import "XMLParam.h"

// 読み込み処理でサポートするタグの名前を定義する
static NSString *kMethodResponse = @"methodResponse";
static NSString *kParams = @"params";
static NSString *kFault = @"fault";
static NSString *kValue = @"value";
static NSString *kMember = @"member";
static NSString *kName = @"name";

// 「XMLReader」クラスの実装
@implementation XMLReader

// プロパティとメンバー変数の設定
@synthesize isMethodResponse = _isMethodResponse;
@synthesize responseType = _responseType;
@synthesize paramsArray = _paramsArray;
@synthesize parsingParam = _parsingParam;
@synthesize openedElements = _openedElements;

// XML-PRCのレスポンスを読み込むメソッド
// 返された辞書には、キー「params」もしくは
// キー「fault」のいずれかに内容が格納される
+ (NSDictionary *)parseMethodResponse:(NSData *)xmlData
{
    // 「NSXMLParser」クラスを使ってXMLを解析する
    NSXMLParser *parser;
    parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    // 解析処理を行うために、「XMLReader」クラスのインスタンスを作成する
    XMLReader *reader;
    reader = [[XMLReader alloc] init];
    
    // 「NSXMLParser」クラスのデリゲートに指定する
    [parser setDelegate:reader];
    
    // 解析開始
    NSDictionary *ret = nil;
    
    if ([parser parse])
    {
        // 解析結果から、メソッドの戻り値となる辞書を作成する
        NSString *responseType = reader.responseType;
        NSArray *paramsArray = reader.paramsArray;
        
        if (responseType && paramsArray)
        {
            ret = [NSDictionary dictionaryWithObject:paramsArray
                                              forKey:responseType];
        }
    }
    
    [reader release];
    [parser release];
    
    return ret;
}

// イニシャライザ
- (id)init
{
    self = [super init];
    if (self)
    {
        // メンバー変数を初期化する
        _isMethodResponse = NO;
        _responseType = nil;
        _paramsArray = [[NSMutableArray alloc] initWithCapacity:0];
        _parsingParam = [[NSMutableArray alloc] initWithCapacity:0];
        _openedElements = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_responseType release];
    [_paramsArray release];
    [_parsingParam release];
    [_openedElements release];
    [super dealloc];
}

// 「NSXMLParser」クラスから呼ばれるデリゲートメソッド
// エレメントの開始時に呼ばれる
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict
{
    // エレメントの配列に追加
    [self.openedElements addObject:elementName];
    
    // 現在解析中のエレメントによって対応が異なる
    if ([elementName isEqualToString:kMethodResponse] &&
        !self.isMethodResponse)
    {
        // メソッド呼び出しに対するレスポンスのXMLとして認識する
        self.isMethodResponse = YES;
    }
    else if (!self.responseType)
    {
        // レスポンスの種類を認識する前
        if ([elementName isEqualToString:kParams] ||
            [elementName isEqualToString:kFault])
        {
            [self setResponseType:elementName];
        }
    }
    else if ([elementName isEqualToString:kValue])
    {
        // 値の読み込み開始
        // 「array」では、入れ子もできるので、
        // 解析中のパラメータはスタックに格納しておく
        // ただし、解析中のパラメータがすでにあり、上位パラメータが
        // 「struct」のときは、「member」の解析中なので
        // 追加しない
        
        // 現在解析中のパラメータを取得する
        XMLParam *curParam = [self.parsingParam lastObject];
        
        // 上位パラメータを取得する
        XMLParam *superParam = nil;
        if ([self.parsingParam count] >= 2)
        {
            superParam = [self.parsingParam objectAtIndex:
                          ([self.parsingParam count] - 2)];
        }
        
        // 次のいずれかが成立する場合は、新規パラメータが必要
        // - 解析中のパラメータが無い
        // - 上位パラメータが無い
        // - 上位パラメータが構造体ではない
        // - 解析中のパラメータが配列
        if (!curParam || !superParam ||
            ![[superParam paramType] isEqualToString:
              XMLParamType_struct] ||
            [[curParam paramType] isEqualToString:
             XMLParamType_array])
        {
            XMLParam *newParam;
            newParam = [[XMLParam alloc] initWithParamType:nil
                                                     value:nil];
            
            [self.parsingParam addObject:newParam];
            [newParam release];
        }
    }
    else if ([elementName isEqualToString:XMLParamType_i4] ||
             [elementName isEqualToString:XMLParamType_int] ||
             [elementName isEqualToString:XMLParamType_boolean] ||
             [elementName isEqualToString:XMLParamType_string] ||
             [elementName isEqualToString:XMLParamType_double] ||
             [elementName isEqualToString:XMLParamType_dateTime] ||
             [elementName isEqualToString:XMLParamType_base64])
    {
        // パラメータの型
        // 解析中のパラメータに型を設定する
        [[self.parsingParam lastObject] setParamType:elementName];
    }
    else if ([elementName isEqualToString:XMLParamType_struct])
    {
        // 構造体の読み込み準備を行う
        // 「XMLReader」クラスでは、構造体は辞書として扱う
        XMLParam *param = [self.parsingParam lastObject];
        
        [param setParamType:XMLParamType_struct];
        [param setParamValue:
         [NSMutableDictionary dictionaryWithCapacity:0]];
    }
    else if ([elementName isEqualToString:kMember])
    {
        // 構造体のメンバーの解析を始める
        XMLParam *newParam;
        newParam = [[XMLParam alloc] initWithParamType:nil
                                                 value:nil];
        [self.parsingParam addObject:newParam];
        [newParam release];
    }
    else if ([elementName isEqualToString:XMLParamType_array])
    {
        // 配列の読み込み準備を行う
        XMLParam *param = [self.parsingParam lastObject];
        
        [param setParamType:XMLParamType_array];
        [param setParamValue:[NSMutableArray arrayWithCapacity:0]];
    }
}

// 「NSXMLParser」クラスから呼ばれるデリゲートメソッド
// エレメントを閉じるときに呼ばれる
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    // 閉じるエレメントによって処理が変わる
    if ([elementName isEqualToString:kValue])
    {
        // 「value」を閉じるときは、解析中のスタックから取り除いて
        // 適切な場所に移す
        // 取り除いたときに解放されないようにするため
        // 参照カウンタを増やす
        XMLParam *param = [[self.parsingParam lastObject] retain];
        
        // スタックから削除する
        [self.parsingParam removeLastObject];
        
        // 解析中のスタックにパラメータがある場合は、
        // 入れ子になっている値の解析が終わった段階なので
        // スタックの最後のパラメータ内に格納する
        XMLParam *superParam = [self.parsingParam lastObject];
        
        if (superParam)
        {
            // 上位パラメータの種類を確認する
            NSString *paramType = superParam.paramType;
            
            if ([paramType isEqualToString:XMLParamType_array])
            {
                // 配列なので、パラメータを配列に追加する
                [superParam.paramValue addObject:param];
            }
            else if ([paramType isEqualToString:XMLParamType_struct])
            {
                // 構造体の場合は、「member」タグを閉じるときに
                // 行うので、スタックに戻す
                [self.parsingParam addObject:param];
            }
        }
        else
        {
            // スタックにパラメータが無いので、
            // 最上位のパラメータ
            [self.paramsArray addObject:param];
        }
        
        // 上で参照カウンタを増やしているので、減らす
        [param release];
    }
    else if ([elementName isEqualToString:kMember])
    {
        // 構造体のメンバーを追加する
        XMLParam *param = [[self.parsingParam lastObject] retain];
        
        // スタックから削除する
        [self.parsingParam removeLastObject];
        
        // 上位パラメータを取得する
        // ここで取得されるパラメータは必ず構造体パラメータとなる
        XMLParam *superParam = [self.parsingParam lastObject];
        
        // 名前と値の両方が取得できている必要がある
        if (param.paramName && param.paramValue)
        {
            // 構造体のメンバーとして追加する
            [superParam.paramValue setObject:param
                                      forKey:param.paramName];
        }
        
        [param release];
    }
    
    // エレメントの配列から削除
    [self.openedElements removeLastObject];
}

// 「NSXMLParser」クラスから呼ばれるデリゲートメソッド
// テキストを読み込まんだときに呼ばれる
- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    // このテキストノードの上位エレメントを取得する
    NSString *elementName;
    elementName = [self.openedElements lastObject];
    
    // 上位エレメントが、パラメータの型を表すエレメントならば
    // このテキストノードはパラメータの値
    if ([elementName isEqualToString:XMLParamType_base64] ||
        [elementName isEqualToString:XMLParamType_boolean] ||
        [elementName isEqualToString:XMLParamType_dateTime] ||
        [elementName isEqualToString:XMLParamType_double] ||
        [elementName isEqualToString:XMLParamType_i4] ||
        [elementName isEqualToString:XMLParamType_int] ||
        [elementName isEqualToString:XMLParamType_string])
    {
        // 複数回に分けて呼ばれることがあるので、文字列を結合する
        NSString *str;
        
        str = [[self.parsingParam lastObject] paramValue];
        if (str)
            str = [str stringByAppendingString:string];
        else
            str = string;
        
        [[self.parsingParam lastObject] setParamValue:str];
    }
    else if ([elementName isEqualToString:kName])
    {
        // 上位エレメントが「name」ならば、構造体のメンバー名
        // 複数回に分けて呼ばれることがあるので、文字列を結合する
        NSString *str;
        
        str = [[self.parsingParam lastObject] paramName];
        if (str)
            str = [str stringByAppendingString:string];
        else
            str = string;
        
        [[self.parsingParam lastObject] setParamName:str];
    }
}

@end

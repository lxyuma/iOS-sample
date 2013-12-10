#import "EditViewController.h"
#import "ConnectionViewController.h"
#import "XMLParam.h"
#import "XMLReader.h"
#import "XMLWriter.h"
#import "SharedParameter.h"
#import "AlertViewAddition.h"

// 「EditViewController」クラスの実装
@implementation EditViewController

// プロパティとメンバー変数の設定
@synthesize titleField = _titleField;
@synthesize textView = _textView;
@synthesize connectionViewController = _connectionViewController;
@synthesize pageOrPostInfo = _pageOrPostInfo;
@synthesize isPageEditing = _isPageEditing;
@synthesize blogID = _blogID;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _pageOrPostInfo = nil;
        _isPageEditing = NO;
        _blogID = nil;
        _keyboardVisible = NO;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    // 通知の受け取り解除
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
    
    [_blogID release];
    [_titleField release];
    [_textView release];
    [_connectionViewController release];
    [_pageOrPostInfo release];
    [super dealloc];
}


// デバイスを回転させるか判定する処理
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向でも回転させる
    return YES;
}

// ビューがロードされたときの処理
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // キーボードが表示されたときの通知を受け取る
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(keyboardDidShow:)
                   name:UIKeyboardDidShowNotification
                 object:nil];
    
    // キーボードが隠されたときの通知を受け取る
    [center addObserver:self
               selector:@selector(keyboardDidHide:)
                   name:UIKeyboardDidHideNotification
                 object:nil];
}

// ビューが表示される直前に呼ばれる処理
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 「Save」ボタンをナビゲーションバーに追加する
    // ボタンが押されたときは、「save:」メソッドを呼び出すようにする
    UIBarButtonItem *button;
    SEL sel = @selector(save:);
    
    button = [[UIBarButtonItem alloc] 
              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
              target:self
              action:sel];
    [self.navigationItem setRightBarButtonItem:button
                                      animated:YES];
    [button release];
}

// ビューが非表示になる直前に呼ばれる処理
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationItem setRightBarButtonItem:nil
                                      animated:YES];
}

// ビューが表示された直後の処理
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 通信画面が閉じた後に表示されたのか、そうでないかの判定を行う
    if (self.connectionViewController)
    {
        // 通信画面が閉じた後に表示されたタイミングなので
        // エラー情報を受信していないか確認し、
        // エラー情報を受信している場合には、アラートビューを表示する
        BOOL ret = [self parseResponse];
        
        // 通信画面は必要なくなったので解放する
        [self setConnectionViewController:nil];
        
        // エラーがなかったときは、このまま編集画面を閉じる
        if (ret)
        {
            // 画面を閉じるとすぐに通信が始まるが、WordPressのバージョンによっては
            // 通信の間隔が短すぎるとエラーになってしまうため、わざと1秒ほど待つ
            [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    else if (self.pageOrPostInfo)
    {
        // 投稿記事の情報、もしくは、ページ情報が設定されていたら
        // 画面に表示する
        [self reloadFromInfo:self.pageOrPostInfo];
    }
}

// 投稿記事の情報、もしくは、ページ情報を表示する
- (void)reloadFromInfo:(XMLParam *)info
{   
    // タイトルを取得する
    XMLParam *titleParam;
    titleParam = [info.paramValue objectForKey:WPTitle];
    
    // 本文を取得する
    // 本文は追記部分とその前とを結合して使用する
    XMLParam *descParam;
    descParam = [info.paramValue objectForKey:WPDescription];
    
    XMLParam *moreParam;
    moreParam = [info.paramValue objectForKey:WPTextMore];
    
    // テキストフィールドにタイトルをセットする
    if (titleParam.paramValue)
    {
        [self.titleField setText:titleParam.paramValue];
    }
    
    // テキストビューに本文をセットする
    if (descParam.paramValue ||
        moreParam.paramValue)
    {
        // 本文と追記部分を結合した文字列を作成する
        NSMutableString *str;
        str = [NSMutableString stringWithCapacity:0];
        
        if (descParam.paramValue)
            [str appendString:descParam.paramValue];
        if (moreParam.paramValue)
            [str appendString:moreParam.paramValue];
        
        [self.textView setText:str];
    }
}

// レスポンスデータを解析する
// エラー情報が含まれていたら、エラーメッセージを表示する
- (BOOL)parseResponse
{
    BOOL ret = NO;
    
    // 通信に成功したのか、失敗したのかチェックする
    NSURLResponse *resp = self.connectionViewController.response;
    
    // HTTPのステータスコードが400未満なら成功と見なす
    if ([resp isKindOfClass:[NSHTTPURLResponse class]] &&
        [(NSHTTPURLResponse *)resp statusCode] < 400)
    {
        // データを取得する
        NSData *data = self.connectionViewController.downloadedData;
        
        // 受信データを解析する
        NSDictionary *respDict;
        respDict = [XMLReader parseMethodResponse:data];
        
        // エラー情報をチェックする
        XMLParam *fault;
        fault = [[respDict objectForKey:WPFault] lastObject];
        
        if (fault)
        {
            // エラー情報を使ってアラートビューを作成する
            UIAlertView *alertView;
            alertView = [[UIAlertView alloc] initWithFault:fault];
            
            // アラートビューを表示する
            [alertView show];
            [alertView release];
        }
        else
        {
            // 通信成功
            ret = YES;
        }
    }
    return ret;
}

// 「Save」ボタンが押されたときの処理
- (void)save:(id)sender
{
    // 「Save」ボタンでは次の4つの処理を行うため
    // 条件によって呼び出すメソッドを切り替える
    // - ページの新規登録
    // - ページの編集
    // - 投稿記事の新規登録
    // - 投稿記事の編集
    
    NSData *postData = nil;
    
    if (self.isPageEditing && self.pageOrPostInfo)
    {
        // ページの編集のとき
        postData = [self dataForSavePageEditing];
    }
    else if (self.isPageEditing && !self.pageOrPostInfo)
    {
        // ページの新規登録のとき
        postData = [self dataForNewPage];
    }
    else if (!self.isPageEditing && self.pageOrPostInfo)
    {
        // 投稿記事の編集のとき
        postData = [self dataForSavePostEditing];
    }
    else
    {
        // 投稿記事の新規登録のとき
        postData = [self dataForNewPost];
    }
    
    // 送信データが作成できなかったときは処理を中止
    if (!postData)
        return;
    
    // 接続先のURLを取得する
    NSURL *url = [SharedParameter communicationURL];
    
    // 接続要求を作成する
    NSMutableURLRequest *req;
    req = [NSMutableURLRequest requestWithURL:url];
    
    // 接続要求に送信データをセットする
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:postData];
    
    // 通信画面を表示して、通信を開始する
    ConnectionViewController *vc;
    vc = [[ConnectionViewController alloc] initWithNibName:nil
                                                    bundle:nil];
    
    [vc setUrlRequest:req];
    [self presentModalViewController:vc
                            animated:NO];
    
    // 通信画面が表示されていることを確認して、プロパティにセットする
    // 既に非表示ならば、通信を開始できなかったということになる
    if (vc.view.window)
    {
        [self setConnectionViewController:vc];
    }
	
    [vc release];
}

// ページの編集結果を保存するための送信データを作成する
- (NSData *)dataForSavePageEditing
{   
    // 送信する編集後のページ情報を作成する
    NSMutableDictionary *contentDict;
    contentDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // 現在のページ情報を取得する
    NSDictionary *curDict = self.pageOrPostInfo.paramValue;
    
    // 現在のページ情報から、タイトルと本文以外の情報を取得する
    // 現在のページ情報から取得する情報の配列を作成する
    NSArray *array;
    array = [NSArray arrayWithObjects:
             WPSlug, WPPassword, WPPageParentID, WPPageOrder,
             WPAuthorID, WPExcerpt, WPAllowComments,
             WPAllowPings, WPCustomFields, nil];
    
    // 現在のページ情報に格納されている値をそのまま使用する
    [array enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
		 XMLParam *param;
		 param = [curDict objectForKey:obj];
		 if (param)
		 {
			 [contentDict setObject:param forKey:obj];
		 }
	 }];
    
    // タイトルをテキストフィールドに入力されているものに変更する
    XMLParam *titleParam;
    titleParam = [[XMLParam alloc]
                  initWithParamType:XMLParamType_string
                  value:self.titleField.text];
    [contentDict setObject:titleParam
                    forKey:WPTitle];
    
    // 追記の内容も含めてすべて「description」に格納する
    XMLParam *descParam;
    descParam = [[XMLParam alloc] 
                 initWithParamType:XMLParamType_string
                 value:self.textView.text];
    [contentDict setObject:descParam
                    forKey:WPDescription];
    
    // 追記は空の文字列を格納する
    XMLParam *moreParam;
    moreParam = [[XMLParam alloc] 
                 initWithParamType:XMLParamType_string
                 value:[NSString string]];
    [contentDict setObject:moreParam
                    forKey:WPTextMore];
    
    // ページ情報を入れる構造体パラメータを作成する
    XMLParam *contentParam;
    contentParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_struct
                    value:contentDict];
    
    // 「wp.editPage」メソッドの送信データには、
    // ブログID、ページID、ユーザー名、パスワード、
    // ページ情報、公開設定が必要
    
    // ページID
    XMLParam *pageID;
    pageID = [curDict objectForKey:WPPageID];
    
    // ユーザー名
    XMLParam *userNameParam;
    userNameParam = [[XMLParam alloc] 
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter userName]];
    // パスワード
    XMLParam *passwordParam;
    passwordParam = [[XMLParam alloc]
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter password]];
    
    // 公開設定
    XMLParam *publishParam;
    publishParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_boolean
                    value:@"1"];
    
    // 送信データを作成する
    NSArray *params;
    params = [NSArray arrayWithObjects:
              self.blogID, pageID, userNameParam, passwordParam,
              contentParam, publishParam, nil];
    
    NSData *xmlData;
    xmlData = [XMLWriter dataForCallMethod:WPEditPage
                                    params:params];
    
    // 解放処理
    [publishParam release];
    [contentParam release];
    [passwordParam release];
    [userNameParam release];
    [moreParam release];
    [descParam release];
    [titleParam release];
    
    return xmlData;
}

// 投稿記事の編集結果を保存するための送信データを作成する
- (NSData *)dataForSavePostEditing
{
    // 送信する編集後の投稿記事の情報を作成する
    NSMutableDictionary *contentDict;
    contentDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // 標準的な項目は「title」、「description」、「dateCreated」
    // この中で、「dateCreated」を省略すると現在の設定を引き継ぐ
	
    // タイトル
    XMLParam *titleParam;
    titleParam = [[XMLParam alloc] 
                  initWithParamType:XMLParamType_string
                  value:self.titleField.text];
    [contentDict setObject:titleParam
                    forKey:WPTitle];
    // 本文
    XMLParam *descParam;
    descParam = [[XMLParam alloc]
                 initWithParamType:XMLParamType_string
                 value:self.textView.text];
    [contentDict setObject:descParam
                    forKey:WPDescription];
    
    // 標準的な項目に加えて、追記パラメータを追加する
    // ここでは追記には空の文字列を指定する
    XMLParam *moreParam;
    moreParam = [[XMLParam alloc] 
                 initWithParamType:XMLParamType_string
                 value:[NSString string]];
    [contentDict setObject:moreParam
                    forKey:WPTextMore];
    
    // 投稿記事情報を入れる構造体パラメータを作成する
    XMLParam *contentParam;
    contentParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_struct
                    value:contentDict];
    
    // 「metaWeblog.editPost」メソッドの送信データには
    // 投稿記事のID、ユーザー名、パスワード、投稿記事情報、公開設定が必要
    
    // 投稿記事のID
    XMLParam *postID;
    postID = [self.pageOrPostInfo.paramValue objectForKey:WPPostID];
    
    // ユーザー名
    XMLParam *userNameParam;
    userNameParam = [[XMLParam alloc] 
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter userName]];
    // パスワード
    XMLParam *passwordParam;
    passwordParam = [[XMLParam alloc] 
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter password]];
    
    // 公開設定
    XMLParam *publishParam;
    publishParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_boolean
                    value:@"1"];
	
    // 送信データを作成する
    NSArray *params;
    params = [NSArray arrayWithObjects:
              postID, userNameParam, passwordParam, contentParam,
              publishParam, nil];
    
    NSData *xmlData;
    xmlData = [XMLWriter dataForCallMethod:MetaWebEditPost
                                    params:params];
    
    // 解放処理
    [contentParam release];
    [moreParam release];
    [descParam release];
    [titleParam release];
    [userNameParam release];
    [passwordParam release];
    [publishParam release];
    
    return xmlData;
}

// テキストフィールドでリターンキーが押されたときの処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // キーボードを隠す
    [textField resignFirstResponder];
    return NO;
}

// キーボードが表示されたときの通知を受け取ったときに行う処理
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    if (_keyboardVisible)
        return; // 既に変更済み
    _keyboardVisible = YES;
    
    // キーボードの領域を取得する
    NSValue *boundsValue;
    boundsValue = [[aNotification userInfo]
                   objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    CGRect rt = [boundsValue CGRectValue];
	
    // 取得した領域はスクリーン座標系なので、ビューの座標系に変換する
    // まず、スクリーン座標系からウインドウ座標系に変換する
    rt = [self.view.window convertRect:rt fromWindow:nil];
    // 次に、ウインドウ座標系からビュー座標系に変換する
    rt = [self.view convertRect:rt fromView:nil];
    
    // テキストビューの下辺がキーボードの上辺になるようにサイズを変更する
    CGRect frame = self.textView.frame;
    frame.size.height = rt.origin.y - frame.origin.y;
    
    [self.textView setFrame:frame];
}

// キーボードが隠されたときの通知を受け取ったときに行う処理
- (void)keyboardDidHide:(NSNotification *)aNotification
{
    if (!_keyboardVisible)
        return; // 既に変更済み
    _keyboardVisible = NO;
    
    // テキストビューの下辺が編集画面の下辺になるようにサイズを変更する
    CGRect frame = self.textView.frame;
    frame.size.height = self.view.bounds.size.height - frame.origin.y;
    
    [self.textView setFrame:frame];
}

// ページの新規登録を行うための送信データを作成する
- (NSData *)dataForNewPage
{
    // 送信するページ情報を作成する
    NSMutableDictionary *contentDict;
    contentDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // タイトルを設定する
    XMLParam *titleParam;
    titleParam = [[XMLParam alloc]
                  initWithParamType:XMLParamType_string
                  value:self.titleField.text];
    [contentDict setObject:titleParam
                    forKey:WPTitle];
    
    // 本文を設定する
    XMLParam *descParam;
    descParam = [[XMLParam alloc]
                 initWithParamType:XMLParamType_string
                 value:self.textView.text];
    [contentDict setObject:descParam
                    forKey:WPDescription];
    
    // ページ情報を入れる構造体パラメータを作成する
    XMLParam *contentParam;
    contentParam = [[XMLParam alloc]
                    initWithParamType:XMLParamType_struct
                    value:contentDict];
    
    // 「wp.newPage」メソッドの送信データには
    // ブログID、ユーザー名、パスワード、ページ情報、公開設定が必要
    
    // ユーザー名
    XMLParam *userNameParam;
    userNameParam = [[XMLParam alloc] 
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter userName]];
    // パスワード
    XMLParam *passwordParam;
    passwordParam = [[XMLParam alloc]
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter password]];
    
    // 公開設定
    XMLParam *publishParam;
    publishParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_boolean
                    value:@"1"];
    
    // 送信データを作成する
    NSArray *params;
    params = [NSArray arrayWithObjects:
              self.blogID, userNameParam, passwordParam,
              contentParam, publishParam, nil];
    
    NSData *xmlData;
    xmlData = [XMLWriter dataForCallMethod:WPNewPage
                                    params:params];
    
    // 解放処理
    [publishParam release];
    [contentParam release];
    [passwordParam release];
    [userNameParam release];
    [descParam release];
    [titleParam release];
    
    return xmlData;
}

// 投稿記事の新規登録を行うための送信データを作成する
- (NSData *)dataForNewPost
{
    // 送信する投稿記事情報を作成する
    NSMutableDictionary *contentDict;
    contentDict = [NSMutableDictionary dictionaryWithCapacity:0];
    
    // 標準的な項目は「title」、「description」、「dateCreated」
    // この中で、「dateCreated」を省略するとすぐに公開になる
    
    // タイトル
    XMLParam *titleParam;
    titleParam = [[XMLParam alloc] 
                  initWithParamType:XMLParamType_string
                  value:self.titleField.text];
    [contentDict setObject:titleParam
                    forKey:WPTitle];
    // 本文
    XMLParam *descParam;
    descParam = [[XMLParam alloc]
                 initWithParamType:XMLParamType_string
                 value:self.textView.text];
    [contentDict setObject:descParam
                    forKey:WPDescription];
    
    // 標準的な項目に加えて、追記パラメータを追加する
    // ここでは追記には空の文字列を指定する
    XMLParam *moreParam;
    moreParam = [[XMLParam alloc] 
                 initWithParamType:XMLParamType_string
                 value:[NSString string]];
    [contentDict setObject:moreParam
                    forKey:WPTextMore];
    
    // 投稿記事情報を入れる構造体パラメータを作成する
    XMLParam *contentParam;
    contentParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_struct
                    value:contentDict];
    
    // 「metaWeblog.editPost」メソッドの送信データには
    // ブログID、ユーザー名、パスワード、投稿記事情報、公開設定が必要
    
    // ユーザー名
    XMLParam *userNameParam;
    userNameParam = [[XMLParam alloc] 
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter userName]];
    // パスワード
    XMLParam *passwordParam;
    passwordParam = [[XMLParam alloc] 
                     initWithParamType:XMLParamType_string
                     value:[SharedParameter password]];
    
    // 公開設定
    XMLParam *publishParam;
    publishParam = [[XMLParam alloc] 
                    initWithParamType:XMLParamType_boolean
                    value:@"1"];
    
    // 送信データを作成する
    NSArray *params;
    params = [NSArray arrayWithObjects:
              self.blogID, userNameParam, passwordParam,
              contentParam, publishParam, nil];
    
    NSData *xmlData;
    xmlData = [XMLWriter dataForCallMethod:MetaWebNewPost
                                    params:params];
    
    // 解放処理
    [userNameParam release];
    [passwordParam release];
    [publishParam release];
    [contentParam release];
    [moreParam release];
    [descParam release];
    [titleParam release];
    
    return xmlData;
}

@end

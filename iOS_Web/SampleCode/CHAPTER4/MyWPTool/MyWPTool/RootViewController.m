#import "RootViewController.h"
#import "ConnectionViewController.h"
#import "XMLWriter.h"
#import "XMLReader.h"
#import "XMLParam.h"
#import "SharedParameter.h"
#import "AlertViewAddition.h"
#import "EditViewController.h"

// 投稿記事の取得件数
static const NSInteger kPostsCount = 5;

// セクションの定義
enum
{
    kSectionPages,
    kSectionPosts
};

// アクションシートに表示したボタンのインデックス番号
enum
{
    kNewPostButton,
    kNewPageButton,
    kCancelButton
};

@implementation RootViewController

// プロパティとメンバー変数の設定
@synthesize connectionViewController = _connectionViewController;
@synthesize userBlog = _userBlog;
@synthesize pagesArray = _pagesArray;
@synthesize postsArray = _postsArray;
@synthesize state = _state;

// イニシャライザ
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // メンバー変数の初期化
        _connectionViewController = nil;
        _userBlog = nil;
        _pagesArray = nil;
        _postsArray = nil;
        _state = RootViewControllerInitialState;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_connectionViewController release];
    [_userBlog release];
    [_pagesArray release];
    [_postsArray release];
    [super dealloc];
}

// デバイスを回転させるか判定する処理
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向でも回転させる
    return YES;
}

// ビューが表示された直後の処理
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 状態に応じて処理を変更する
    if (self.state == RootViewControllerInitialState)
    {
        // 初期状態なので、取得済みの情報があったら破棄する
        [self setUserBlog:nil];
        [self setPagesArray:nil];
        [self setPostsArray:nil];
        
        // 初期状態なので、ブログの情報を取得する
        [self requestWithNextState:RootViewControllerGettingBlogs];
    }
    else if (self.state == RootViewControllerGettingBlogs)
    {
        // ブログ情報を受信した後なので、受信したデータを解析する
        [self parseResponse];
        
        // ページの一覧情報を取得する
        [self requestWithNextState:RootViewControllerGettingPages];
    }
    else if (self.state == RootViewControllerGettingPages)
    {
        // ページ情報の一覧を受信した後なので、受信したデータを解析する
        [self parseResponse];
        
        // 投稿記事の一覧情報を取得する
        [self requestWithNextState:RootViewControllerGettingPosts];
    }
    else if (self.state == RootViewControllerGettingPosts)
    {
        // 投稿記事の一覧情報を取得した後なので、受信したデータを解析する
        [self parseResponse];
    }
}

// 通信を開始するメソッド
- (void)requestWithNextState:(NSInteger)nextState
{
    // 接続先のURLを取得する
    NSURL *url = [SharedParameter communicationURL];
    
    // 接続要求を作成する
    NSMutableURLRequest *req;
    req = [NSMutableURLRequest requestWithURL:url];
    
    // 送信データを作成する
    // 送信データは要求するメソッドにより異なるので
    // 引数で指定された、状態遷移後の状態により切り替える
    NSData *postData = nil;
    
    switch (nextState)
    {
        case RootViewControllerGettingBlogs:
            // ブログ情報の取得
            postData = [self dataForRequestGetUsersBlogs];
            break;
            
        case RootViewControllerGettingPages:
            // ページの一覧情報の取得
            postData = [self dataForRequestGetPages];
            break;
            
        case RootViewControllerGettingPosts:
            // 投稿記事の一覧情報の取得
            postData = [self dataForRequestGetRecentPosts];
            break;
    }
    
    if (!postData)
    {
        // 送信データが作成できなかったので何もしない
        return;
    }
    
    // 接続要求に送信データをセット
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
        
        // 状態を設定する
        [self setState:nextState];
    }
    
    [vc release];
}

// 「wp.getUsersBlogs」メソッドへの送信データを作成する
// このメソッドで必要な送信パラメータは、ユーザー名とパスワード
- (NSData *)dataForRequestGetUsersBlogs
{
    // ユーザー名
    XMLParam *userName;
    userName = [[XMLParam alloc]
                initWithParamType:XMLParamType_string
                value:[SharedParameter userName]];
    
    // パスワード
    XMLParam *password;
    password = [[XMLParam alloc]
                initWithParamType:XMLParamType_string
                value:[SharedParameter password]];
    
    // 配列にする
    NSArray *paramsArray;
    paramsArray = [NSArray arrayWithObjects:
                   userName, password, nil];
    
    // 送信データを作成する
    NSData *postData;
    postData = [XMLWriter dataForCallMethod:WPGetUsersBlogs
                                     params:paramsArray];
    
    [password release];
    [userName release];
    
    return postData;
}

// 「wp.getPages」メソッドへの送信データを作成する
// このメソッドで必要な送信パラメータは、ブログID、ユーザー名、パスワード
- (NSData *)dataForRequestGetPages
{
    // ブログID
    XMLParam *blogID;
    blogID = [self.userBlog.paramValue objectForKey:WPBlogID];
    if (!blogID)
    {
        // ブログIDを取得していないので、データを作成できない
        return nil;
    }
    
    // ユーザー名
    XMLParam *userName;
    userName = [[XMLParam alloc]
                initWithParamType:XMLParamType_string
                value:[SharedParameter userName]];
    
    // パスワード
    XMLParam *password;
    password = [[XMLParam alloc] 
                initWithParamType:XMLParamType_string
                value:[SharedParameter password]];
    
    // 配列にする
    NSArray *paramsArray;
    paramsArray = [NSArray arrayWithObjects:
                   blogID, userName, password, nil];
    
    // 送信データを作成する
    NSData *postData;
    postData = [XMLWriter dataForCallMethod:WPGetPages
                                     params:paramsArray];
    
    [password release];
    [userName release];
    
    return postData;
}

// 「metaWeblog.getRecentPosts」メソッドへの送信データを作成する
// このメソッドで必要な送信パラメータはブログID、ユーザー名、パスワード
// 読み込み件数の4つ
- (NSData *)dataForRequestGetRecentPosts
{
    // ブログID
    XMLParam *blogID;
    blogID = [self.userBlog.paramValue objectForKey:WPBlogID];
    if (!blogID)
    {
        // ブログIDを取得していないので、データを作成できない
        return nil;
    }
	
    // ユーザー名
    XMLParam *userName;
    userName = [[XMLParam alloc]
                initWithParamType:XMLParamType_string
                value:[SharedParameter userName]];
    
    // パスワード
    XMLParam *password;
    password = [[XMLParam alloc]
                initWithParamType:XMLParamType_string
                value:[SharedParameter password]];
    
    // 読み込み件数
    // この処理は「Load More」ボタンが押されたときも呼ばれるので
    // 読み込み件数は、現在の読み込み済み件数+定数「kPostCount」で
    // 定義した個数とする
    // 初期状態では、配列はクリアされているので、定数「kPostCount」で
    // 定義した個数となる
    NSInteger n = [self.postsArray count] + kPostsCount;
    XMLParam *count;
    count = [[XMLParam alloc] 
             initWithParamType:XMLParamType_int
             value:[NSNumber numberWithInteger:n]];
    
    // 配列にする
    NSArray *paramsArray;
    paramsArray = [NSArray arrayWithObjects:
                   blogID, userName, password, count, nil];
    
    // 送信データを作成する
    NSData *postData;
    postData = [XMLWriter dataForCallMethod:MetaWebGetRecentPosts
                                     params:paramsArray];
    
    [count release];
    [password release];
    [userName release];
    
    return postData;
    
}

// 受信したデータを解析する
- (void)parseResponse
{
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
        
        // 「params」エレメントの内容を取得する
        NSArray *params;
        params = [respDict objectForKey:WPParams];
        
        // 「params」エレメントの先頭の「param」エレメントの
        // 内容を取得する
        XMLParam *firstParam = nil;
        if ([params count] > 0)
        {
            firstParam = [params objectAtIndex:0];
        }
        
        // 呼び出したメソッドにより内容が異なり、それに対応する処理も
        // 異なるので、プロパティ「state」に設定された状態で処理を切り替える
        switch (self.state)
        {
            case RootViewControllerGettingBlogs:
                // ブログ情報の取得
                [self parseGetUsersBlogsParam:firstParam];
                break;
                
            case RootViewControllerGettingPages:
                // ページの一覧情報の取得
                [self parseGetPagesParam:firstParam];
                break;
                
            case RootViewControllerGettingPosts:
                // 投稿記事の一覧情報の取得
                [self parseGetRecentPostsParam:firstParam];
                break;
        }
        
        // エラー情報を受信したときは、メッセージ表示を行う
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
    }
    
    // 通信画面は必要なくなったので解放する
    [self setConnectionViewController:nil];
    
    // 状態を初期状態に戻す
    // このあと、通信開始メソッドで状態は設定されるが
    // 何らかのエラーが起きたときに、ブログ情報取得待ちの状態の
    // ままにならないようにするため、ここで一度初期状態に戻す
    [self setState:RootViewControllerInitialState]; 
}

// 「wp.getUsersBlogs」メソッドで受け取った情報を解析する
- (void)parseGetUsersBlogsParam:(XMLParam *)firstParam
{
    // ブログ情報の配列から先頭のブログ情報を取得する
    XMLParam *firstBlog = nil;
    
    if ([firstParam.paramValue count] > 0)
    {
        firstBlog = [firstParam.paramValue objectAtIndex:0];
    }
    
    // 取得したブログ情報をプロパティにセットする
    [self setUserBlog:firstBlog];
    
    // ナビゲーションバーにブログの名前を表示する
    XMLParam *blogName;
    blogName = [firstBlog.paramValue objectForKey:WPBlogName];
    
    [self setTitle:blogName.paramValue];
}

// 「wp.getPages」メソッドで受け取った情報を解析する
- (void)parseGetPagesParam:(XMLParam *)firstParam
{
    // 取得したページ情報の一覧をプロパティにセットする
    [self setPagesArray:firstParam.paramValue];
    
    // テーブルビューを再読み込みする
    [self.tableView reloadData];
}

// 「metaWeblog.getRecentPosts」メソッドで受け取った情報を解析する
- (void)parseGetRecentPostsParam:(XMLParam *)firstParam
{
    // 取得した投稿記事情報の一覧をプロパティにセットする
    [self setPostsArray:firstParam.paramValue];
    
    // テーブルビューを再読み込みする
    [self.tableView reloadData];
}

// テーブルビューのセクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // ページの一覧、投稿記事の一覧を表示するため、
    // セクション数は2つになる
    return 2;
}

// セクションのタイトルを返す
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *ret = nil;
    
    switch (section)
    {
        case kSectionPages:
            // ページの一覧
            ret = @"Pages";
            break;
            
        case kSectionPosts:
            // 投稿記事の一覧
            ret = @"Posts";
            break;
    }
    return ret;
}

// テーブルビューに表示するセルの個数を返す
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = 0;
    
    // セクションによって処理を変更する
    switch (section)
    {
        case kSectionPages:
            // ページ情報の一覧
            ret = [self.pagesArray count];
            break;
            
        case kSectionPosts:
            // 投稿記事の一覧
            ret = [self.postsArray count];
            break;
    }
    return ret;
}

// テーブルビューに表示するセルを返す
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    // セルを作成する
    UITableViewCell *cell;
    
    cell = [[[UITableViewCell alloc]
             initWithStyle:UITableViewCellStyleDefault
             reuseIdentifier:nil] autorelease];
    
    // セクションによって処理を変更する
    if (indexPath.section == kSectionPages)
    {
        // ページの一覧を表示する
        // ページ情報を取得する
        XMLParam *page;
        page = [_pagesArray objectAtIndex:indexPath.row];
        
        // ページのタイトルを取得する
        XMLParam *pageTitle;
        pageTitle = [[page paramValue] objectForKey:WPTitle];
        
        // セルにタイトルをセットする
        cell.textLabel.text = pageTitle.paramValue;
        
    }
    else if (indexPath.section == kSectionPosts)
    {
        // 投稿記事の一覧を表示する
        // 投稿記事情報を取得する
        XMLParam *post;
        post = [_postsArray objectAtIndex:indexPath.row];
        
        // 投稿記事のタイトルを取得する
        XMLParam *postTitle;
        postTitle = [[post paramValue] objectForKey:WPTitle];
        
        // セルにタイトルをセットする
        cell.textLabel.text = postTitle.paramValue;
    }
    
    return cell;
}

// 「Load More」ボタンの処理
- (IBAction)loadMore:(id)sender
{
    // 投稿記事の取得処理を行う
    // サーバーへの送信パラメータを作成するときに
    // 読み込み件数は設定されるので、ここでは単純に呼び出すだけで良い
    [self requestWithNextState:RootViewControllerGettingPosts];
}

// テーブルビューでセルが選択されたときの処理
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMLParam *selectedParam = nil;
    
    // セクションによって処理を変更する
    if (indexPath.section == kSectionPages)
    {
        // ページが選択されたとき
        selectedParam = [self.pagesArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == kSectionPosts)
    {
        // 投稿記事が選択されたとき
        selectedParam = [self.postsArray objectAtIndex:indexPath.row];
    }
    
    // 編集画面を作成する
    EditViewController *vc;
    vc = [[EditViewController alloc] initWithNibName:nil
                                              bundle:nil];
    // 情報をセットする
    [vc setPageOrPostInfo:selectedParam];
    [vc setIsPageEditing:(indexPath.section == kSectionPages)];
    [vc setBlogID:[self.userBlog.paramValue objectForKey:WPBlogID]];
    
    
    // 編集画面を表示する
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
    [vc release];
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // ボタンを作成する
    // ボタンが押されたら「addPostOrPage:」ボタンが呼ばれるようにする
    UIBarButtonItem *button;
    
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
              target:self
              action:@selector(addPostOrPage:)];
    
    // ナビゲーションバーにボタンを追加する
    [self.navigationItem setRightBarButtonItem:button
                                      animated:YES];
    [button release];
}

// ビューが非表示になる直前に呼ばれるメソッド
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 追加したボタンを削除する
    [self.navigationItem setRightBarButtonItem:nil
                                      animated:YES];
}

// 追加ボタンが押されたときの処理
- (void)addPostOrPage:(id)sender
{
    // 投稿記事とページのどちらを追加するのか選択する
    // アクションシートを表示する
    UIActionSheet *sheet;
    
    sheet = [[UIActionSheet alloc] 
             initWithTitle:@"New"
             delegate:self
             cancelButtonTitle:@"Cancel"
             destructiveButtonTitle:nil
             otherButtonTitles:@"Post", @"Page", nil];
	
    UIBarButtonItem *button = self.navigationItem.rightBarButtonItem;
    [sheet showFromBarButtonItem:button
                        animated:YES];
    [sheet release];
}

// アクションシートでボタンが押されたときに呼ばれるメソッド
- (void)actionSheet:(UIActionSheet *)actionSheet 
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // 「Post」ボタン、または、「Page」ボタンが
    // 押されたときにのみ編集画面を表示する
    if (buttonIndex == kNewPostButton ||
        buttonIndex == kNewPageButton)
    {
        // 編集画面を作成する
        EditViewController *vc;
        
        vc = [[EditViewController alloc] initWithNibName:nil
                                                  bundle:nil];
        
        // 「Page」ボタンが押されたときは
        // プロパティ「isPageEditing」を「YES」にする
        if (buttonIndex == kNewPageButton)
            vc.isPageEditing = YES;
        else
            vc.isPageEditing = NO;
        
        // ブログIDを設定する
        [vc setBlogID:
         [self.userBlog.paramValue objectForKey:WPBlogID]];
        
        // 編集画面を表示する
        [self.navigationController pushViewController:vc
                                             animated:YES];
        
        [vc release];
    }
}

@end

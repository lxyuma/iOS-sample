#import "RootViewController.h"
#import "ServiceInfoViewController.h"

// 「RootViewController」クラスの実装
@implementation RootViewController

// プロパティとメンバ変数の設定
@synthesize searchBar = _searchBar;
@synthesize serviceBrowser = _serviceBrowser;
@synthesize services = _services;

// ビューをロードしたときの処理
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // サービスブラウザの初期化
    _serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    // デリゲートを設定する
    [_serviceBrowser setDelegate:self];
    
    // 配列をクリアする
    _services = [[NSMutableArray alloc] initWithCapacity:0];
    
    // タイトルを設定する
    [self setTitle:@"Browser"];
}

// デバイスの回転に対応するか判定するメソッド
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも回転させる
    return YES;
}

// テーブルに表示するセクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // このサンプルアプリケーションでは、常に1つ
    return 1;
}


// テーブルに表示する項目数を返す
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section 
{
    // 取得した「NSNetSerivce」クラスのインスタンス数を返す
    return [self.services count];
}

// テーブルビューのセルを返す
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // セルを再利用するときに使用する識別子
    static NSString *CellIdentifier = @"Cell";
    
    // 再利用出来るセルを取得する
    UITableViewCell *cell = 
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        // 再利用できなかったので、セルを作成する
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // ネットサービスを取得する
    NSNetService *service;
    service = [self.services objectAtIndex:indexPath.row];
    
    // セルにネットサービスのインスタンス名を表示する
    [cell.textLabel setText:service.name];
    
    // セルの右端に「>」記号を表示する
    [cell setAccessoryType:
     UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

// ビューをアンロードしたときに呼ばれるメソッド
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // 「viewDidLoad」メソッドで作成した
    // オブジェクトを解放する
    [self setServiceBrowser:nil];
    [self setServices:nil];
}

// 解放処理
- (void)dealloc
{
    [_searchBar release];
    [_serviceBrowser release];
    [_services release];
    [super dealloc];
}

// 「検索」ボタンが押されたときの処理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 検索が動いていたら止める
    [self.serviceBrowser stop];
    
    // テーブルビューをクリアする
    [self setServices:[NSMutableArray arrayWithCapacity:0]];
    [self.tableView reloadData];
    
    // テキストフィールドに入力されたテキストを取得する
    NSString *serviceType;
    serviceType = searchBar.text;
    
    // 入力されたテキストをサービスタイプとして、ローカルドメインを
    // 対象にサービスを検索する
    [self.serviceBrowser searchForServicesOfType:serviceType
                                        inDomain:@"local."];
}

// サービスが見つかったときに呼ばれるメソッド
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
           didFindService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // 配列に追加する
    [self.services addObject:netService];
    
    // テーブルビューを再読込する
    [self.tableView reloadData];
}

// サービスがなくなったときに呼ばれるメソッド
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService 
               moreComing:(BOOL)moreComing
{
    // 配列から削除する
    [self.services removeObject:aNetService];
    
    // テーブルビューを再読込する
    [self.tableView reloadData];
}

// テーブルビューのセルを選択したときの処理
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択したネットサービスを取得する
    NSInteger row = indexPath.row;
    NSNetService *service;
    service = [self.services objectAtIndex:row];
    
    // 情報表示画面を作成する
    ServiceInfoViewController *vc;
    
    vc = [[ServiceInfoViewController alloc] initWithNibName:nil
                                                     bundle:nil];
    
    // ネットサービスを設定する
    [vc setNetService:service];
    
    // ビューを表示する
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
    [vc release];
}

@end

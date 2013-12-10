#import "UploadFileChooserViewController.h"
#import "TransferViewController.h"

@implementation UploadFileChooserViewController

// プロパティとメンバー変数の設定
@synthesize pathArray = _pathArray;
@synthesize remoteDirURL = _remoteDirURL;
@synthesize userName = _userName;
@synthesize password = _password;

// 初期化処理
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数を初期化する
        _pathArray = nil;
        _remoteDirURL = nil;
        _userName = nil;
        _password = nil;
    }
    
    return self;
}

// ビューが読み込まれた直後の処理
- (void)viewDidLoad
{
    // 親クラスの処理を呼び出す
    [super viewDidLoad];
    
    // 「Documents」ディレクトリを取得する
    NSString *docDir;
    docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                  NSUserDomainMask,
                                                  YES) lastObject];
    
    // 「Documents」ディレクトリの内容を取得する
    NSArray *contentsArray;
    contentsArray = [[NSFileManager defaultManager]
                     contentsOfDirectoryAtPath:docDir
                     error:NULL];
    
    // ファイルパスの配列を作成する
    NSMutableArray *pathArray;
    pathArray = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *name in contentsArray)
    {
		// ファイルパスを作成する
		NSString *path;
		path = [docDir stringByAppendingPathComponent:name];
		
		// ファイルかどうかをチェックする
		BOOL isDir = NO;
		[[NSFileManager defaultManager]
		 fileExistsAtPath:path isDirectory:&isDir];
		
		if (!isDir)
		{
			// ファイルだったので、配列に追加する
			[pathArray addObject:path];
		}
    }
    
    // メンバー変数にセットして、テーブルビューを更新する
    [self setPathArray:pathArray];
    [self.tableView reloadData];
    
    // タイトルを設定する
    [self setTitle:@"Upload"];
}

// ビューが表示される直前に呼ばれる
- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewWillAppear:animated];
    
    // ナビゲーションバーの右端に「Upload」ボタンを表示する
    UIBarButtonItem *newButton;
    newButton = [[UIBarButtonItem alloc] 
                 initWithTitle:@"Upload"
                 style:UIBarButtonItemStylePlain
                 target:self
                 action:@selector(upload:)];
    [self.navigationItem setRightBarButtonItem:newButton];
    [newButton release];
}

// テーブルビューのセクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// テーブルビューの項目数を返す
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.pathArray count];
}

// テーブルビューに表示する項目を返す
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    // 再利用可能なセルがあれば利用する
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        // 再利用可能なセルがないので新規作成する
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:CellIdentifier]
                autorelease];
    }
    
    // 項目のラベルにファイル名を設定する
    // ファイルパスを取得する
    NSString *path;
    path = [self.pathArray objectAtIndex:indexPath.row];
    
    // 表示名を取得する
    NSString *name;
    name = [[NSFileManager defaultManager] displayNameAtPath:path];
    
    // ラベルに設定する
    cell.textLabel.text = name;
    
    return cell;
}

// 解放処理
- (void)dealloc
{
    [_remoteDirURL release];
    [_userName release];
    [_password release];
    [_pathArray release];
    [super dealloc];
}

// アップロード処理
- (void)upload:(id)sender
{
    // 選択されている項目を取得する
    NSIndexPath *indexPath;
    indexPath = [self.tableView indexPathForSelectedRow];
    
    if (!indexPath)
    {
        return; // 選択されていない
    }
    
    // 選択されている項目へのURLを作成する
    NSURL *localURL;
    localURL = [NSURL fileURLWithPath:
                [self.pathArray objectAtIndex:indexPath.row]];
    
    // アップロード先のURLを作成する
    NSString *fileName = [[localURL path] lastPathComponent];
    NSURL *remoteURL;
	
    remoteURL = [NSURL URLWithString:fileName
                       relativeToURL:self.remoteDirURL];
    
    // 絶対URLに変換する
    remoteURL = [remoteURL absoluteURL];
    
    // 転送画面を表示しアップロードを行う
    // まず、転送画面を作成する
    TransferViewController *vc;
    vc = [[TransferViewController alloc] initWithNibName:nil
                                                  bundle:nil];
    
    // 必要な情報を設定する
    [vc setUserName:self.userName];
    [vc setPassword:self.password];
    [vc setRemoteURL:remoteURL];
    [vc setLocalURL:localURL];
    [vc setUploadMode:YES];
    
    // 転送画面を表示する
    [self presentModalViewController:vc
                            animated:YES];
    
    [vc release];
}

@end


#import "RootViewController.h"
#import "DownloadViewController.h"
#import "ImageFileViewController.h"

@implementation RootViewController

// プロパティとメンバー変数の設定
@synthesize filePathArray = _filePathArray;

#pragma mark -
#pragma mark View lifecycle

// nibファイルからインスタンスが作成されるときに呼ばれる
// イニシャライザメソッド
// 「RootViewController」クラスのオブジェクトはnibファイルから作成される
// ので、このメソッドをオーバーライドして、メンバー変数の初期化を行う
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // メンバー変数を初期化する
        _filePathArray = nil;
    }   
    return self;
}

// ビューがロードされたときに呼ばれるメソッド
- (void)viewDidLoad
{
    // 親クラスの処理を呼び出す
    [super viewDidLoad];
    
    // タイトルに「Downloader」と表示する
    [self setTitle:@"Downloader"];
    
    // 「追加」ボタンを作成する
    // ボタンがタップされたときに呼ばれるメソッドには
    // 「showDownloadViewController:」メソッドを指定し、このメソッドは、
    // 「RootViewController」クラスで実装する
    UIBarButtonItem *addButton;
    SEL action = @selector(showDownloadViewController:);
    
    addButton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                 target:self
                 action:action];
    
    // ナビゲーションバーにボタンを追加する
    UINavigationItem *navItem = self.navigationItem;
    [navItem setRightBarButtonItem:addButton animated:NO];
    
    [addButton release];
}
// ビューが表示される直前に呼ばれるメソッド
- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスの処理を呼び出す
    [super viewWillAppear:animated];
    
    // 「Documents」ディレクトリ内のファイルを検索する
    NSMutableArray *array = [self scanDocumentsDirectory];
    
    // メンバー変数に設定する
    [self setFilePathArray:array];
    
    // テーブルを再読み込みする
    [self.tableView reloadData];
}

// 指定された方向に対応するかどうかを返す
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向にも対応する
    return YES;
}

#pragma mark -
#pragma mark Table view data source

// 「Documents」ディレクトリ内を走査して、ファイルを取得する
- (NSMutableArray *)scanDocumentsDirectory
{
    // 「Documents」ディレクトリのパスを取得する
    NSString *docDirPath;
    
    docDirPath =
	[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
										 NSUserDomainMask,
										 YES) lastObject];
    
    // 内容を取得する
    NSArray *contents;
	
    contents = [[NSFileManager defaultManager]
                contentsOfDirectoryAtPath:docDirPath error:NULL];
    
    // ファイルパスの一覧を作成する
    NSMutableArray *filePathArray;
    
    filePathArray = [NSMutableArray arrayWithCapacity:0];
	
    for (NSString *path in contents)
    {
        // 変数「path」に格納されているのは、ファイル名の部分だけなので
        // 変数「docDirPath」に連結して、絶対パスを作成する
        path = [docDirPath stringByAppendingPathComponent:path];
        
        // 配列に追加する
        [filePathArray addObject:path];
    }
    
    return filePathArray;
}

// テーブルビューのセクション数を返す
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // このアプリケーションでは、セクションで区切らないので、常に「1」を返す
    return 1;
}

// テーブルビューの項目数を返す
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section 
{
    // 項目数はフォルダ内のファイル数となる
    return [self.filePathArray count];
}

// テーブルビューの項目を返す
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // セルが再利用されるときに使われる識別子
    static NSString *CellIdentifier = @"Cell";
    
    // 再利用可能なセルがあれば、それを使用する
    UITableViewCell *cell =
	[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        // 再利用可能なセルがないときは、新規作成する
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // 指定された位置に表示するファイルのファイルパスを取得する
    NSString *filePath =
	[self.filePathArray objectAtIndex:indexPath.row];
    
    // 表示名を取得する
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [fileManager displayNameAtPath:filePath];
    
    // セルに設定して返す
    cell.textLabel.text = fileName;
    
    // 対応するファイルのときのみ、ディスクロージャーマークを表示する
    if ([self isSupportedFile:filePath])
    {
        cell.accessoryType =
		UITableViewCellAccessoryDisclosureIndicator;
    }
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

// テーブルビューの項目が選択されたときに呼ばれる
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    // 選択された項目に対応するファイルパスを取得する
    NSString *filePath;
    filePath = [self.filePathArray objectAtIndex:indexPath.row];
    
    // 選択されたファイルが開けるファイルかどうかを判定する
    if ([self isSupportedFile:filePath])
    {
        // 画像ファイル表示画面を作成する
        ImageFileViewController *viewController;
        
        viewController = [[ImageFileViewController alloc]
                          initWithNibName:nil
                          bundle:nil];
        
        // ファイルパスを設定する
        [viewController setFilePath:filePath];
        
        // 表示する
        [self.navigationController pushViewController:viewController
                                             animated:YES];
        
        [viewController release];
    }
}

// 対応するファイルかどうかを判定する
// ここでは「UIImage」クラスが対応するファイルの中で、以下のファイルを
// 対応ファイルとする
// JPEG, PNG
// ファイルフォーマットの判定は拡張子のみで行う
- (BOOL)isSupportedFile:(NSString *)filePath
{
    // 判定処理の簡略化のため、小文字に変換している
    NSString *extension = [[filePath pathExtension] lowercaseString];
    
    if ([extension isEqual:@"jpg"] ||
        [extension isEqual:@"jpeg"] ||
        [extension isEqual:@"png"])
    {
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Memory management

// メモリ不足になったときに呼ばれる
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// ビューがアンロードされたときに呼ばれる
- (void)viewDidUnload
{
	[super viewDidUnload];
}

// インスタンスが解放されたときに呼ばれる
- (void)dealloc
{
    [_filePathArray release];
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

// ダウンロード画面の表示
- (void)showDownloadViewController:(id)sender
{
    // ダウンロード画面のビューコントローラを作成
    DownloadViewController *viewController;
    viewController = [[DownloadViewController alloc]
                      initWithNibName:nil bundle:nil];
    
    // ダウンロード画面のビューコントローラをモーダル表示する
    [self presentModalViewController:viewController
                            animated:YES];
    [viewController release];
}

@end


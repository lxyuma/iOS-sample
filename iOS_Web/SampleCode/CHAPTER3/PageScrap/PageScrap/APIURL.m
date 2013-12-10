#import "APIURL.h"

// サーバのURLのキー
static NSString *kServerURL = @"serverURL";

// APIのパス定義
static NSString *kDoInsert = @"doInsert.php";
static NSString *kDoUpdate = @"doUpdate.php";
static NSString *kDoList = @"doList.php";
static NSString *kDoDelete = @"doDelete.php";
static NSString *kDoGetDetail = @"doGetDetail.php";

@implementation NSURL (APIURL)

// 他のメソッドが使用する共通メソッド
+ (NSURL *)URLWithAPIPath:(NSString *)apiPath
{
    // サーバのURLを作成する
    NSUserDefaults *userDefaults =
	[NSUserDefaults standardUserDefaults];
    NSString *str = [userDefaults stringForKey:kServerURL];
    NSURL *serverURL = [NSURL URLWithString:str];
    
    // APIのパスを使って相対URLを作成する
    NSURL *resultURL;
    resultURL = [NSURL URLWithString:apiPath
                       relativeToURL:serverURL];
    // 絶対URLに変換する
    resultURL = [resultURL absoluteURL];
    
    return resultURL;
}

// 情報を登録するAPIへのURLを作成する
+ (NSURL *)URLToDoInsert
{
    return [self URLWithAPIPath:kDoInsert];
}

// 情報を更新するAPIへのURLを作成する
+ (NSURL *)URLToDoUpdate
{
    return [self URLWithAPIPath:kDoUpdate];
}

// 情報の一覧を取得するAPIへのURLを作成する
+ (NSURL *)URLToDoList
{
    return [self URLWithAPIPath:kDoList];
}

// 情報を削除するAPIへのURLを作成する
+ (NSURL *)URLToDoDelete
{
    return [self URLWithAPIPath:kDoDelete];
}

// 情報の詳細を取得するAPIへのURLを作成する
+ (NSURL *)URLToGetDetail:(NSString *)recordID
{
    // IDが指定されていないときは、URLを作成しない
    if (!recordID || [recordID length] == 0)
        return nil;
	
    // パスにIDを連結する
    NSString *path;
    path = [NSString stringWithFormat:@"%@?ID=%@",
            kDoGetDetail, recordID];
    
    return [self URLWithAPIPath:path];
}

@end

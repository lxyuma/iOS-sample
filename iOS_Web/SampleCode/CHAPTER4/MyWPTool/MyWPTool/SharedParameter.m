#import "SharedParameter.h"

// WordPress APIに関する定義
NSString *WPGetUsersBlogs = @"wp.getUsersBlogs";
NSString *WPGetPages = @"wp.getPages";
NSString *WPParams = @"params";
NSString *WPFault = @"fault";
NSString *WPFaultCode = @"faultCode";
NSString *WPFaultString = @"faultString";
NSString *WPBlogName = @"blogName";
NSString *WPBlogID = @"blogid";
NSString *WPTitle = @"title";
NSString *MetaWebGetRecentPosts = @"metaWeblog.getRecentPosts";
NSString *WPDescription = @"description";
NSString *WPTextMore = @"mt_text_more";
NSString *WPSlug = @"wp_slug";
NSString *WPPassword = @"wp_password";
NSString *WPPageParentID = @"wp_page_parent_id";
NSString *WPPageOrder = @"wp_page_order";
NSString *WPAuthorID = @"wp_author_id";
NSString *WPExcerpt = @"mt_excerpt";
NSString *WPAllowComments = @"mt_allow_comments";
NSString *WPAllowPings = @"mt_allow_pings";
NSString *WPCustomFields = @"custom_fields";
NSString *WPPageID = @"page_id";
NSString *WPEditPage = @"wp.editPage";
NSString *WPPostID = @"postid";
NSString *MetaWebEditPost = @"metaWeblog.editPost";
NSString *WPNewPage = @"wp.newPage";
NSString *MetaWebNewPost = @"metaWeblog.newPost";

// ユーザーデフォルトから設定値を読み込むためのキー
static NSString *kServerURL = @"serverURL";
static NSString *kUserName = @"userName";
static NSString *kPassword = @"password";

@implementation SharedParameter

// XML-RPCで通信するためのURLを取得するメソッド
+ (NSURL *)communicationURL
{
    // サーバのURLを取得する
    NSString *str;
    str = [[NSUserDefaults standardUserDefaults]
           stringForKey:kServerURL];
    
    NSURL *serverURL = [NSURL URLWithString:str];
    
    // WordPressでXML-RPCの通信用のパスは「/xmlrpc.php」となる
    NSURL *resultURL = nil;
    
    if (serverURL)
    {
        resultURL = [NSURL URLWithString:@"xmlrpc.php"
                           relativeToURL:serverURL];
        
        // 相対URLから絶対URLに変換する
        resultURL = [resultURL absoluteURL];
    }
    
    return resultURL;
}

// ユーザー名を返す
+ (NSString *)userName
{
    NSString *ret;
    ret = [[NSUserDefaults standardUserDefaults]
           stringForKey:kUserName];
    return ret;
}

// パスワードを返す
+ (NSString *)password
{
    NSString *ret;
    ret = [[NSUserDefaults standardUserDefaults]
           stringForKey:kPassword];
    return ret;
}

@end

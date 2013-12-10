#import <Foundation/Foundation.h>

// APIに関する定義
extern NSString *WPGetUsersBlogs;
extern NSString *WPGetPages;
extern NSString *WPParams;
extern NSString *WPFault;
extern NSString *WPFaultCode;
extern NSString *WPFaultString;
extern NSString *WPBlogName;
extern NSString *WPBlogID;
extern NSString *WPTitle;
extern NSString *MetaWebGetRecentPosts;
extern NSString *WPDescription;
extern NSString *WPTextMore;
extern NSString *WPSlug;
extern NSString *WPPassword;
extern NSString *WPPageParentID;
extern NSString *WPPageOrder;
extern NSString *WPAuthorID;
extern NSString *WPExcerpt;
extern NSString *WPAllowComments;
extern NSString *WPAllowPings;
extern NSString *WPCustomFields;
extern NSString *WPPageID;
extern NSString *WPEditPage;
extern NSString *WPPostID;
extern NSString *MetaWebEditPost;
extern NSString *WPNewPage;
extern NSString *MetaWebNewPost;

@interface SharedParameter : NSObject {
	
}

// XML-RPCで通信するためのURLを取得するメソッド
+ (NSURL *)communicationURL;

// ユーザー名を返す
+ (NSString *)userName;

// パスワードを返す
+ (NSString *)password;

@end

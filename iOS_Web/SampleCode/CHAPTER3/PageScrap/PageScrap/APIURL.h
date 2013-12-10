#import <Foundation/Foundation.h>

// 「NSURL」クラスに追加するメソッドの宣言
@interface NSURL (APIURL)

+ (NSURL *)URLToDoInsert;
+ (NSURL *)URLToDoUpdate;
+ (NSURL *)URLToDoList;
+ (NSURL *)URLToDoDelete;
+ (NSURL *)URLToGetDetail:(NSString *)recordID;

@end

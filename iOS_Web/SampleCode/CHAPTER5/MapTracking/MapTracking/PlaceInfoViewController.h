#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

// 「PlaceInfoViewController」クラスのインターフェイス宣言
@interface PlaceInfoViewController : UIViewController
<MKReverseGeocoderDelegate>
{
    // 情報を表示するテキストビュー
    UITextView *_textView;
    
    // 逆ジオコーダから取得した情報
    MKPlacemark *_placemark;
    
    // 位置
    CLLocationCoordinate2D _coordinate;
    
    // 逆ジオコーダ
    MKReverseGeocoder *_reverseGeocoder;
}

// プロパティの定義
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) MKPlacemark *placemark;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) MKReverseGeocoder *reverseGeocoder;

// プロパティ「placemark」から情報を取得して表示するメソッド
- (void)reloadFromPlacemark;

// 逆ジオコーダから情報を取得する
- (void)reloadFromReverseGeocoder;

@end

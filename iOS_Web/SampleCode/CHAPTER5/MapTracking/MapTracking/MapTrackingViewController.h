#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

// 「MapTrackingViewController」クラスのインターフェイス宣言
@interface MapTrackingViewController : UIViewController 
<CLLocationManagerDelegate, MKMapViewDelegate>
{
    // 地図を表示するビュー
    MKMapView *_mapView;
    
    // 位置情報を取得するためのオブジェクト
    CLLocationManager *_locationManager;
    
    // 位置情報の配列
    NSMutableArray *_locations;
    
//    // スタート地点の情報
//    MKPlacemark *_placemark;
}

// プロパティの定義
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (retain, nonatomic) CLLocationManager *locationManager;
@property (retain, nonatomic) NSMutableArray *locations;
@property (retain, nonatomic) MKPlacemark *placemark;

// 移動した軌跡を描画するための折れ線を追加する
- (void)addPolyline;

@end


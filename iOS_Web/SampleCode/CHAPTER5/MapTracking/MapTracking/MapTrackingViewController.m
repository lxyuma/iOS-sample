#import "MapTrackingViewController.h"
#import "MyAnnotation.h"
#import "PlaceInfoViewController.h"

// 位置情報の更新通知に必要な最低距離
static const CLLocationDistance kMinimumDistance = 20.0;

// 「MapTrackingViewController」クラスの実装
@implementation MapTrackingViewController

// プロパティとメンバー変数の設定
@synthesize mapView = _mapView;
@synthesize locationManager = _locationManager;
@synthesize locations = _locations;
@synthesize placemark = _placemark;

// イニシャライザ
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // メンバー変数を初期化する
        _locations = nil;
        _placemark = nil;
    }
    return self;
}

// 解放処理
- (void)dealloc
{
    [_placemark release];
    [_locations release];
    [_locationManager release];
    [_mapView release];
    [super dealloc];
}

// デバイスを回転させるか判定する処理
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // どの方向でも回転させる
    return YES;
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // ナビゲーションツールバーにボタンを追加する
    // ボタンを中央寄せにしたいので、左右には伸縮する
    // スペースを入れる
    NSMutableArray *itemsArray;
    itemsArray = [NSMutableArray arrayWithCapacity:0];
    
    // 伸縮可能なスペースを作る
    UIBarButtonItem *button;
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:
			  UIBarButtonSystemItemFlexibleSpace
              target:nil
              action:0];
    [itemsArray addObject:button];
    [button release];
    
    // 通常の地図表示に切り替えるボタンを作成する
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Standard"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(changeToStandardType:)];
    [itemsArray addObject:button];
    [button release];
    
    // 衛星写真表示に切り替えるボタンを作成する
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Satellite"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(changeToSatelliteType:)];
    [itemsArray addObject:button];
    [button release];
    
    // 地図表示と衛星写真表示の合成表示に切り替えるボタンを作成する
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Hybrid"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(changeToHybridType:)];
    [itemsArray addObject:button];
    [button release];
    
    // 伸縮可能なスペースを作る
    button = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:
			  UIBarButtonSystemItemFlexibleSpace
              target:nil
              action:0];
    [itemsArray addObject:button];
    [button release];
    
    // 伸縮可能なスペースよりも更に右側に「Start」ボタンを配置して
    // 「Start」ボタンは右端にして、残りの領域で中央揃えになるようにする
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Start"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(startTracking:)];
    [itemsArray addObject:button];
    [button release];
    
    // ナビゲーションツールバーに設定する
    [self.navigationController.toolbar setItems:itemsArray
                                       animated:animated];
}

// 通常の地図表示に切り替える
- (IBAction)changeToStandardType:(id)sender
{
    [_mapView setMapType:MKMapTypeStandard];
}

// 衛星写真表示に切り替える
- (IBAction)changeToSatelliteType:(id)sender
{
    [_mapView setMapType:MKMapTypeSatellite];
}

// 地図表示と衛星写真表示の合成表示に切り替える
- (IBAction)changeToHybridType:(id)sender
{
    [_mapView setMapType:MKMapTypeHybrid];
}

// ビューがロードされたときの処理
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 位置情報を取得するための準備を行う
    // 位置情報の取得が可能なときのみ、準備を行う
    
    if ([CLLocationManager locationServicesEnabled])
    {
        // このビューコントローラで使用する「CLLocationManager」クラスの
        // インスタンスを作成する
        CLLocationManager *manager;
        manager = [[CLLocationManager alloc] init];
        [self setLocationManager:manager];
		
        // デリゲートを設定する
        [manager setDelegate:self];
        
        // 最低でも20m程度移動しなければ通知しないようにする
        [manager setDistanceFilter:kMinimumDistance];
        
        [manager release];
    }
    
    // 地図を表示するビューのデリゲートに指定する
    [self.mapView setDelegate:self];
}

// 「Start」ボタンが押されたときの処理
- (IBAction)startTracking:(id)sender
{
    // 「Start」ボタンを「Stop」ボタンに変更する
    // 「Stop」ボタンを作成する
    UIBarButtonItem *button;
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Stop"
              style:UIBarButtonItemStyleDone
              target:self
              action:@selector(stopTracking:)];
    
    // ナビゲーションバーのボタンを取得する
    // 配列の内容を変更したいので、配列のコピーを作成する
    NSMutableArray *array;
    array = [self.navigationController.toolbar.items mutableCopy];
    
    // ボタンを差し替える
    [array removeLastObject];
    [array addObject:button];
    
    // ナビゲーションバーに設定する
    [self.navigationController.toolbar setItems:array
                                       animated:YES];
	
    // アノテーションクリアする
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // 位置情報の取得を開始する
    CLLocationManager *manager = self.locationManager;
    [manager startUpdatingLocation];
    
    // 解放
    [array release];
    [button release];
    
    // 折れ線を削除するため、オーバーレイをクリアする
    [self.mapView removeOverlays:self.mapView.overlays];
    [self setLocations:[NSMutableArray arrayWithCapacity:0]];
    
    // スタート地点の情報をクリアする
    [self setPlacemark:nil];
}

// 「Stop」ボタンが押されたときの処理
- (IBAction)stopTracking:(id)sender
{
    // 「Stop」ボタンを「Start」ボタンに変更する
    // 「Start」ボタンを作成する
    UIBarButtonItem *button;
    button = [[UIBarButtonItem alloc]
              initWithTitle:@"Start"
              style:UIBarButtonItemStyleBordered
              target:self
              action:@selector(startTracking:)];
    
    // ナビゲーションバーのボタンを取得する
    // 配列の内容を変更したいので、配列のコピーを作成する
    NSMutableArray *array;
    array = [self.navigationController.toolbar.items mutableCopy];
    
    // ボタンを差し替える
    [array removeLastObject];
    [array addObject:button];
    
    // ナビゲーションバーに設定する
    [self.navigationController.toolbar setItems:array
                                       animated:YES];
    
    // 位置情報の取得を停止する
    CLLocationManager *manager = self.locationManager;
    [manager stopUpdatingLocation];
    
    // 解放
    [array release];
    [button release];
    
    // 移動した軌跡を描画するため、折れ線を追加する
    [self addPolyline];
}

// 位置情報が更新されたきに呼ばれるメソッド
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // タイムスタンプを確認して、5秒以上経過している場合は
    // 無視する
    NSTimeInterval t;
    t = [[NSDate date] timeIntervalSinceDate:newLocation.timestamp];
    if (t >= 5)
        return; // 無視する
    
    // 精度が負の値のときや、100mよりも大きいときは無視する
    if (newLocation.horizontalAccuracy < 0 ||
        newLocation.horizontalAccuracy > 100)
    {
        return; // 無視する
    }
    
    // 位置を取得する
    CLLocationCoordinate2D coord;
    coord = newLocation.coordinate;
    
    // 最初のアノテーションを追加するときは、ズームレベルも設定する
    if ([self.mapView.annotations count] == 0)
    {
        MKCoordinateRegion rgn;
        
        // 構造体をクリアする
        memset(&rgn, 0, sizeof(rgn));
        
        // 中心位置を設定する
        rgn.center.latitude = coord.latitude;
        rgn.center.longitude = coord.longitude;
        
        // ズームレベルを設定する
        rgn.span.latitudeDelta = 0.002;
        rgn.span.longitudeDelta = 0.002;
        
        // 表示領域を設定する
        [self.mapView setRegion:rgn
                       animated:YES];
    }
    else
    {
        // ズームレベルは変更せず、中心位置のみ更新する
        [self.mapView setCenterCoordinate:coord];
    }
	
    
    // アノテーションを作成する
    MyAnnotation *annotation;
    annotation = [[MyAnnotation alloc] init];
    
    // 位置を設定する
    [annotation setCoordinate:newLocation.coordinate];
    
    // スタート地点のときはプロパティ「isStart」を「YES」にする
    if ([self.mapView.annotations count] == 0)
    {
        [annotation setIsStart:YES];
    }
    
    // 名前として取得日時を文字列にしたものを設定する
    NSString *str;
    str = [NSDateFormatter 
           localizedStringFromDate:newLocation.timestamp
           dateStyle:kCFDateFormatterMediumStyle
           timeStyle:kCFDateFormatterMediumStyle];
    [annotation setTitle:str];
    
    // ビューに追加する
    [self.mapView addAnnotation:annotation];
    
    [annotation release];
    
    // 折れ線を作成するときのために、取得した位置情報を記憶する
    [self.locations addObject:newLocation];
}

// アノテーションビューを返すメソッド
// 「MKMapViewDelegate」プロトコルで定義されているメソッド
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *ret = nil;
	
    // スタート地点のアノテーションかどうかをチェックする
    
    if ([annotation isKindOfClass:[MyAnnotation class]] &&
        [(MyAnnotation *)annotation isStart])
    {
        // スタート地点のアノテーション
        // アイコン画像を表示するためのビューを作成する
        ret = [[[MKAnnotationView alloc]
                initWithAnnotation:annotation
                reuseIdentifier:nil] autorelease];
        
        // アイコン画像を読み込む
        UIImage *image;
        image = [UIImage imageNamed:@"start_icon.png"];
        
        // アイコン画像を設定する
        [ret setImage:image];
        
        // 吹き出しの左側に表示されるビューを作成する
        UIImageView *imageView;
        imageView = [[UIImageView alloc] initWithImage:image];
        
        // 左側のアクセサリビューとして設定する
        [ret setLeftCalloutAccessoryView:imageView];
        
        [imageView release];
        
        // 詳細を表示するボタンを追加する
        // ボタンを作成する
        UIButton *button;
        button = [UIButton buttonWithType:
                  UIButtonTypeDetailDisclosure];
        
        // ボタンが押されたときには「showPlacemarkInfo:」メソッドを
        // 呼び出すようにする
        [button addTarget:self
                   action:@selector(showPlacemarkInfo:)
         forControlEvents:UIControlEventTouchUpInside];
        
        // 吹き出しの右側にボタンを追加する
        [ret setRightCalloutAccessoryView:button];
    }
    else
    {
        // ピンを表示する
        ret = [[[MKPinAnnotationView alloc]
                initWithAnnotation:annotation
                reuseIdentifier:nil] autorelease];
        
        // ピンの色を変更する
        // ここでは、紫にする
        [(MKPinAnnotationView *)ret 
         setPinColor:MKPinAnnotationColorPurple];
    }
    
    // タップされたときに吹き出しを表示する
    [ret setCanShowCallout:YES];
    
    return ret;
}

// 移動した軌跡を描画するための折れ線を追加する
- (void)addPolyline
{
    // 位置の配列を作成する
    // 個数を取得する
    unsigned int n = [self.locations count];
    if (n == 0)
        return; // アノテーションが一つもない
    
    // 位置の配列を入れるためのバッファを作成する
    NSMutableData *data;
    data = [NSMutableData dataWithLength:
            (sizeof(CLLocationCoordinate2D) * n)];
    if (!data)
        return; // メモリー不足
    
    // バッファにアノテーションの位置をコピーする
    __block CLLocationCoordinate2D *p;
    p = (CLLocationCoordinate2D *)[data mutableBytes];
    
    [self.locations enumerateObjectsUsingBlock:
     ^(id obj, NSUInteger idx, BOOL *stop) {
         *p = [obj coordinate]; // 位置をコピーする
         p++;
     }];
    
    // バッファから折れ線を作成する
    MKPolyline *polyline;
    p = (CLLocationCoordinate2D *)[data mutableBytes];
    polyline = [MKPolyline polylineWithCoordinates:p                
                                             count:n];
    
    // 地図に追加する
    [self.mapView addOverlay:polyline];
}

// オーバーレイオブジェクトを表示するためのビューを返すメソッド
- (MKOverlayView *)mapView:(MKMapView *)mapView 
            viewForOverlay:(id <MKOverlay>)overlay
{
    MKOverlayView *view = nil;
    
    // 折れ線なら、折れ線を表示するためのビューを返す
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        // 折れ線を表示するためのビューを作成する
        view = [[[MKPolylineView alloc]
                 initWithPolyline:overlay] autorelease];
        
        // 線の色を変更する
        [(MKPolylineView *)view setStrokeColor:[UIColor redColor]];
        
        // 線の太さを変更する
        [(MKPolylineView *)view setLineWidth:3];
    }
    
    return view;
}

// スタート地点の吹き出しの中に追加した詳細を表示するボタンが
// 押されたときに呼ばれるメソッド
- (void)showPlacemarkInfo:(id)sender
{
    // ビューコントローラを作成する
    PlaceInfoViewController *vc;
    vc = [[PlaceInfoViewController alloc] initWithNibName:nil
                                                   bundle:nil];
	
    // 取得済みの情報があれば使用する
    [vc setPlacemark:self.placemark];
    
    // スタート地点のアノテーションの位置を取得する
    if ([self.locations count] > 0)
    {
        CLLocation *loc;
        loc = [self.locations objectAtIndex:0];
        
        // ビューコントローラに設定する
        [vc setCoordinate:loc.coordinate];
    }
    
    // ビューを表示する
    [self.navigationController pushViewController:vc
                                         animated:YES];
    
    [vc release];
}

@end

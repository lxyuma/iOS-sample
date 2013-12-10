//
//  SSViewController.m
//  SearchStation
//
//  Created by Casareal on 12/11/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SSViewController.h"
#import "ConnectionManager.h"

@implementation SSViewController
@synthesize mainMapView;
@synthesize findMeButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

//init(インスタンス作成時に呼び出したイニシャライザ)
//　　↓
//viewDidLoad
//　・View が初めて呼び出される時に1回だけ呼ばれます。
//　・アプリ起動後に初めて当Viewが表示された場合に1度だけ呼ばれます。
//　　↓
//viewWillAppear
//　・View が表示される直前に呼ばれるメソッド
//　・タブ等の切り替え等により、画面に表示されるたびに呼び出されます。
//　・タブが切り替わるたびに何度でも呼ばれます。
//　　↓
//viewDidAppear
//　・View の表示が完了後に呼び出されるメッソド
//　・タブ等の切り替え等により、画面に表示されるたびに呼び出されます。
//　・タブが切り替わるたびに何度でも呼ばれます。
//　　↓
//viewWillDisappear
//　・View が他のView (画面から消える) 直前に呼び出されるメッソド
//　・View が他のView (画面から消える) 直前に呼び出されるメッソド
//　・タブが切り替わるたびに何度でも呼ばれます。
//　　↓
//viewDidDisappear
//　・View が他のView (画面から消えた) 非表示後に呼び出されるメッソド
//　・View が他のView (画面から消える) 直前に呼び出されるメッソド
//　・タブが切り替わるたびに何度でも呼ばれます。

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.mainMapView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Autorotate

// iOS6.0: 回転のサポートを宣言
- (BOOL)shouldAutorotate
{
	return YES;
}

// iOS6.0: サポートしている回転を指定する
- (NSUInteger)supportedInterfaceOrientations
{
    // info.plistによる指定とする
	return UIInterfaceOrientationMaskAll;
}


- (IBAction)standardMapViewAction:(id)sender {
    mainMapView.mapType = MKMapTypeStandard;
}

- (IBAction)statelliteMapViewAction:(id)sender {
    mainMapView.mapType = MKMapTypeSatellite;
}

- (IBAction)hybridMapViewAction:(id)sender {
    mainMapView.mapType = MKMapTypeHybrid;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {
    // 現在地のアノテーションのときは何もしない
    if (mapView.userLocation == annotation) {
        return nil;
    }

    // 最寄り駅のピンの表示用Viewを生成
    MKPinAnnotationView* annotationView;
    annotationView = [[MKPinAnnotationView alloc]
                       initWithAnnotation:annotation
                       reuseIdentifier:nil];
    // 吹き出しを表示するかどうかを指定する
    annotationView.canShowCallout = YES;

    // 上から落ちてくるようなアニメーションをするか?
    annotationView.animatesDrop = YES;
    
    // ピンの色を変更
    annotationView.pinColor = MKPinAnnotationColorGreen;
    
    return annotationView;
}

- (IBAction)searchStation:(id)sender {
    if (findMeButton.tag == 0) {
        // 現在位置の特定を先にすること
        // ロケーションサービスが利用できない場合(ダイアログを表示する)
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"警告"
                              message:@"現在位置を特定してください。"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return ;
    }

    // パラメータ付きのURLを作成
    // 例：http://express.heartrails.com/api/json?method=getStations&x=135.0&y=35.0
    NSString *url = @"http://express.heartrails.com/api/json";
    NSString *parameter = [NSString 
                           stringWithFormat:@"method=getStations&x=%lf&y=%lf", 
                           longitude, latitude];
    NSString *urlWithParameter = [NSString stringWithFormat:@"%@?%@", url, parameter];

    // サーバーと通信(URLリクエストを作成:GET)
    NSURL *serviceURL = [NSURL URLWithString:urlWithParameter];

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:serviceURL];
    [req setHTTPMethod:@"GET"];
//    [req addValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; 
    
    // サーバーと通信 (非同期通信)
    ConnectionManager *connectionManager = [[ConnectionManager alloc] initWithDelegate:self];
    [connectionManager connectionRequest:req];
}

// データ受信成功
- (void)receiveSucceed:(ConnectionManager *)connectionManager
{
    // JSONデータをNSDictionaryに変換
    NSError *jsonError;
    NSDictionary *jsonObject =
    [NSJSONSerialization JSONObjectWithData:connectionManager.receivedData
                                    options:NSJSONReadingAllowFragments
                                      error:&jsonError];

    // 前回検索したときの駅アノテーションを削除する
    // その際、自分の位置は消さない
    NSArray *oldAnnotations = mainMapView.annotations;
    for(MKUserLocation *oldAnnotation in oldAnnotations) {
        if(oldAnnotation != (MKUserLocation*)mainMapView.userLocation) {
            [mainMapView removeAnnotation:oldAnnotation];    
        }
    }
 
    // 駅情報の取り出し
    NSArray* stations = [[jsonObject valueForKey:@"response"]
                         valueForKey:@"station"];
    
    // for debug
    for(id station in stations) {
        NSLog(@"data: %@", station);
    }
    
    for(id station in stations) {
        NSString* line = [station valueForKey:@"line"];
        NSString* name = [station valueForKey:@"name"];
        NSString* distance = [station valueForKey:@"distance"];
        NSString* title = [NSString stringWithFormat:@"%@ %@", line, name];
        
        NSString* y = [station valueForKey:@"y"];
        NSString* x = [station valueForKey:@"x"];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [y doubleValue];
        coordinate.longitude = [x doubleValue];
        
        // Pinをドロップ
        PinAnnotation *pinAnnotation =
        [[PinAnnotation alloc] initWithCoordinate:coordinate
                                             title:title
                                          subtitle:distance];
        pinAnnotation.isMylocation = NO;
        [mainMapView addAnnotation:pinAnnotation];
    }
    
    //[connectionManager release];
}

// 通信エラー
- (void)receiveFaild:(ConnectionManager *)connectionManager {
    NSLog(@"Error!");
   // [connectionManager release];
}

// iOS 6以降
// 位置情報が更新されるたびに呼びされる
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    // 最新情報は最後にある
    CLLocation *newLocation = [locations lastObject];

    // 取得した緯度経度を地図の中心に設定
    [mainMapView setCenterCoordinate:newLocation.coordinate animated:NO];
    
    // 地図の縮尺を設定(1度は約111キロ)
    MKCoordinateRegion zoom = mainMapView.region;
    zoom.span.latitudeDelta = 0.010;
    zoom.span.longitudeDelta = 0.010;
    [mainMapView setRegion:zoom animated:YES];
    
    // 位置情報の記録
    latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
    
    // 現在地の表示
    mainMapView.showsUserLocation = YES;
}

// 位置情報の取得に失敗(CLLocationManagerDelegate)
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (IBAction)findMeAction:(id)sender {
    if ([CLLocationManager locationServicesEnabled]) {
        // ロケーションサービスが利用できる場合
        if (locationManager == nil) {
            locationManager = [[CLLocationManager alloc] init]; // CLLocationManagerを作成
        }
        locationManager.delegate = self;
        // 10m以上移動したらアップデート
        locationManager.distanceFilter = 10;
        if (findMeButton.tag == 0) {
            [locationManager startUpdatingLocation]; // 位置情報取得を開始
            findMeButton.tag = 1;
        } else {
            [locationManager stopUpdatingLocation]; // 位置情報取得を停止
            // 現在地の表示をやめる
            mainMapView.showsUserLocation = NO;
            findMeButton.tag = 0;
        }
    } else {
        // ロケーションサービスが利用できない場合(ダイアログを表示する)
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"警告"
                              message:@"位置情報サービスが利用できません。サービスを有効にしてください"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

@end

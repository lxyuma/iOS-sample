#import "PlaceInfoViewController.h"
#import "MapTrackingViewController.h"

// 「PlaceInfoViewController」クラスの実装
@implementation PlaceInfoViewController

// プロパティとメンバー変数の設定
@synthesize textView = _textView;
@synthesize placemark = _placemark;
@synthesize coordinate = _coordinate;
@synthesize reverseGeocoder = _reverseGeocoder;

// イニシャライザ
- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        // メンバー変数の初期化
        _placemark = nil;
        memset(&_coordinate, 0, sizeof(_coordinate));
    }
    return self;
}

// デバイスの回転に対応するかを返すメソッド
- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // 常に回転させる
    return YES;
}

// 解放処理
- (void)dealloc
{
    [_reverseGeocoder release];
    [_placemark release];
    [_textView release];
    [super dealloc];
}

// ビューが表示される直前に呼ばれるメソッド
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 情報を取得済みかチェックする
    if (self.placemark)
    {
        // 取得済みなので、それを表示する
        [self reloadFromPlacemark];
    }
    else
    {
        // 情報を取得していないので、取得する
        [self reloadFromReverseGeocoder];
    }
    
    // ナビゲーションバーを表示する
    [self.navigationController setNavigationBarHidden:NO
                                             animated:animated];
}

// ビューが閉じられる直前に呼ばれるメソッド
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 「viewWillAppear:」メソッドで表示した
    // ナビゲーションバーを閉じる
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
}

// プロパティ「placemark」から情報を取得して表示するメソッド
- (void)reloadFromPlacemark
{
    // プロパティ「placemark」に設定されている情報から
    // 表示する文字列を作成する
    
    NSMutableString *str;
    str= [NSMutableString stringWithCapacity:0];
    
    // 国コードを表示する
    if (self.placemark.countryCode)
    {
        [str appendFormat:@"countryCode=%@\n",
         self.placemark.countryCode];
    }
    
    // 国名を表示する
    if (self.placemark.country)
    {
        [str appendFormat:@"country=%@\n",
         self.placemark.country];
    }
    
    // 郵便番号を表示する
    if (self.placemark.postalCode)
    {
        [str appendFormat:@"postalCode=%@\n",
         self.placemark.postalCode];
    }
    
    // 都道府県を表示する
    if (self.placemark.administrativeArea)
    {
        [str appendFormat:@"administrativeArea=%@\n",
         self.placemark.administrativeArea];
    }
    
    // 「administrativeArea」の追加的な情報
    if (self.placemark.subAdministrativeArea)
    {
        [str appendFormat:@"subAdministrativeArea=%@\n",
         self.placemark.subAdministrativeArea];
    }
    
    // 市区町村を表示する
    if (self.placemark.locality)
    {
        [str appendFormat:@"locality=%@\n",
         self.placemark.locality];
    }
    
    // 町名を表示する
    if (self.placemark.subLocality)
    {
        [str appendFormat:@"subLocality=%@\n",
         self.placemark.subLocality];
    }
    
    // 通り名などを表示する（日本では丁目）
    if (self.placemark.thoroughfare)
    {
        [str appendFormat:@"thoroughfare=%@\n",
         self.placemark.thoroughfare];
    }
    
    // 通り番号などを表示する（日本では番地以下の情報）
    if (self.placemark.subThoroughfare)
    {
        [str appendFormat:@"subThoroughfare=%@\n",
         self.placemark.subThoroughfare];
    }
    
    // アドレスブックで管理している情報を表示する
    if (self.placemark.addressDictionary)
    {
        [str appendFormat:@"addressDictionary=%@\n",
         [self.placemark.addressDictionary description]];
    }
    
    // テキストビューに設定する
    [self.textView setText:str];
}

// 逆ジオコーダから情報を取得する
- (void)reloadFromReverseGeocoder
{
    // 逆ジオコーダのインスタンス作成
    MKReverseGeocoder *geocoder;
    geocoder = [[MKReverseGeocoder alloc]
                initWithCoordinate:self.coordinate];
    
    // デリゲートを設定する
    [geocoder setDelegate:self];
    
    // 取得開始
    [geocoder start];
    
    // プロパティにセットする
    [self setReverseGeocoder:geocoder];
    
    [geocoder release];
}

// 逆ジオコーダから情報を取得できたときに呼ばれるメソッド
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder
       didFindPlacemark:(MKPlacemark *)placemark
{
    // 取得した情報をプロパティにセット
    [self setPlacemark:placemark];
    
    // 逆ジオコーダを解放する
    [self setReverseGeocoder:nil];
    
    // 取得した情報を表示する
    [self reloadFromPlacemark];
    
    // 再利用できるように、「MapTrackingViewController」クラスの
    // プロパティにもセットする
    NSArray *viewControllers;
    viewControllers = self.navigationController.viewControllers;
    
    MapTrackingViewController *vc;
    vc = [viewControllers objectAtIndex:
          ([viewControllers count] - 2)];
    
    // 念のため、クラスを確認する
    if ([vc isKindOfClass:[MapTrackingViewController class]])
    {
        // プロパティにセットする
        [vc setPlacemark:placemark];
    }
}

// 逆ジオコーダから情報を取得できなかったときに呼ばれるメソッド
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder
       didFailWithError:(NSError *)error
{
    // エラーメッセージを取得する
    NSString *msg;
    msg = [error localizedDescription];
    
    // アラートビューを作成する
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                       message:msg
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    
    // アラートビューを表示する
    [alert show];
    
    // 解放
    [alert release];
    [self setReverseGeocoder:nil];
}

@end

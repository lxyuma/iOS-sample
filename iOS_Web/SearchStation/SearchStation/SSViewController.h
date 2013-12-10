//
//  SSViewController.h
//  SearchStation
//
//  Created by Casareal on 12/11/18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PinAnnotation.h"

@interface SSViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    CLLocationManager* locationManager;
}
@property (strong, nonatomic) IBOutlet MKMapView *mainMapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *findMeButton;
- (IBAction)standardMapViewAction:(id)sender;
- (IBAction)statelliteMapViewAction:(id)sender;
- (IBAction)hybridMapViewAction:(id)sender;
- (IBAction)searchStation:(id)sender;
- (IBAction)findMeAction:(id)sender;

@end

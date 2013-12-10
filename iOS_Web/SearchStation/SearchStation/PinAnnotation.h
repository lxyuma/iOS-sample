//
//  PinAnnotation.h
//  MyFindMeMfindYou
//
//  Created by Casareal on 12/11/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PinAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;  //　構造体
    NSString *title;
    NSString *subtitle;
    BOOL isMylocation;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic) BOOL isMylocation;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle subtitle:(NSString *)sSubtitle;
@end

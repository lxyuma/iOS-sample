//
//  PinAnnotation.m
//  MyFindMeMfindYou
//
//  Created by Casareal on 12/11/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PinAnnotation.h"

@implementation PinAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize isMylocation;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString *)aTitle {
    self = [super init];
    if (self != nil) {
        coordinate = coord;
        title = [aTitle copy];
    }
    return self;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
                   title:(NSString *)aTitle
                subtitle:(NSString *)aSubtitle {
    self = [super init];
    if (self != nil) {
        coordinate = coord;
        title = [aTitle copy];
        subtitle = [aSubtitle copy];
    }
    return self;
}

@end

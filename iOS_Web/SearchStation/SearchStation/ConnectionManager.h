//
//  ConnectionManager.h
//  MyFindMeMfindYou
//
//  Created by Casareal on 12/11/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionManager : NSObject {
    id _delegate;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (readonly) NSMutableData *receivedData;
- (id)initWithDelegate:(id)delegate;
- (NSURLConnection *)connectionRequest:(NSMutableURLRequest *)urlRequest;

@end

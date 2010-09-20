//
//  JXXMPPKeepAlive.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/28/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXJunctionExtra.h"


@interface JXXMPPKeepAlive : JXJunctionExtra {
@private
	NSDate *lastPong;
}

@property (retain) NSDate *lastPong;

+ (JXXMPPKeepAlive *)keepAlive;

@end

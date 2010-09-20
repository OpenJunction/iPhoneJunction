//
//  JXActor.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXMessageTarget.h"

@class JXJunction;

@interface JXActor : NSObject <JXMessageTarget> {
@public
	NSString *actorID;
@private
	JXJunction *jx;
}

- (id)initActor:(NSString *)actor withJunction:(JXJunction *)junction;

- (void)sendMessage:(NSDictionary *)message;

@end

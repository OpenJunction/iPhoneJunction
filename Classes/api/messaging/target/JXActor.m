//
//  JXActor.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXActor.h"
#import "JXJunction.h"

@implementation JXActor

- (id)initActor:(NSString *)actor withJunction:(JXJunction *)junction {
	if (self = [super init]) {
		jx = [junction retain];
		actorID = [actor retain];
	}
	return self;
}

- (void)dealloc {
	[jx release];
	[actorID release];
	[super dealloc];
}

- (void)sendMessage:(NSDictionary *)message {
	[jx sendMessage:message toActor:actorID];
}

@end

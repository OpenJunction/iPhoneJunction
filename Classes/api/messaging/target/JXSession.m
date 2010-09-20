//
//  JXSession.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXSession.h"
#import "JXJunction.h"

@implementation JXSession

- (id)initWithJunction:(JXJunction *)junction {
	if (self = [super init]) {
		jx = [junction retain];
	}
	return self;
}

- (void)dealloc {
	[jx release];
	[super dealloc];
}

- (void)sendMessage:(NSDictionary *)message {
	[jx sendMessageToSession:message];
}

@end

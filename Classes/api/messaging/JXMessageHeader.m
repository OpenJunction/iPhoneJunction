//
//  JXMessageHeader.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXMessageHeader.h"
#import "JXMessageTargetFactory.h"
#import "JXJunction.h"

@implementation JXMessageHeader

- (id)initWithJunction:(JXJunction *)junction
			   message:(NSDictionary *)msg
				  from:(NSString *)fr {
	if (self = [super init]) {
		jx = [junction retain];
		message = [msg retain];
		from = [fr retain];
	}
	return self;
}

- (void)dealloc {
	[jx release];
	[message release];
	[from release];
	[super dealloc];
}

- (id<JXMessageTarget>)getReplyTarget {
	NSDictionary *h = [message objectForKey:NS_JX];
	if (h) {
		NSString *target = [h objectForKey:@"replyTo"];
		if (target) {
			return [[JXMessageTargetFactory instanceWithJunction:jx] getTarget:target];
		}
	}
	
	return [[JXMessageTargetFactory instanceWithJunction:jx] getTarget:[NSString stringWithFormat:@"actor:%@", from]];
}

- (NSString *)getSender {
	return from;
}

- (JXJunction *)getJunction {
	return jx;
}

@end

//
//  JXMessageTargetFactory.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXMessageTargetFactory.h"
#import "JXJunction.h"
#import "JXActor.h"
#import "JXSession.h"

@implementation JXMessageTargetFactory

+ (JXMessageTargetFactory *)instanceWithJunction:(JXJunction *)junction {
	return [[[JXMessageTargetFactory alloc] initWithJunction:junction] autorelease];
}

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

- (id<JXMessageTarget>)getTarget:(NSString *)target {
	if ([target isEqualToString:@"session"]) {
		JXSession *session = [[JXSession alloc] initWithJunction:jx];
		return [session autorelease];
	}
	
	NSString *prefix = [target substringToIndex:5];
	if ([prefix isEqualToString:@"actor"]) {
		JXActor *actor = [[JXActor alloc] initActor:[target substringFromIndex:6]
									   withJunction:jx];
		return [actor autorelease];
	}
	
	return nil;
}

@end

//
//  JXJunctionActor.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXJunctionActor.h"
#import "JXJunction.h"
#import "JXCategoryDummy.h"

@implementation JXJunctionActor

@synthesize junction;
@synthesize actorID;

- (id)initWithRoles:(NSArray *)roles {
	if (self = [super init]) {
		actorID = [[NSString stringWithUUID] retain];
		mRoles = [[NSArray alloc] initWithArray:roles];
	}
	return self;
}

- (id)initWithRole:(NSString *)role {
	return [self initWithRoles:[NSArray arrayWithObject:role]];
}

- (void)dealloc {
	[junction release];
	[actorID release];
	[mRoles release];
	[super dealloc];
}

- (NSArray *)getRoles {
	return mRoles;
}

- (void)onActivityJoin {}
- (void)onActivityStart {}
- (void)onActivityCreate {}
- (void)onActivityRejoin {}

- (BOOL)isConnected {
	return [junction isConnected];
}

- (NSArray *)getInitialExtras {
	return [NSArray array];
}

- (void)registerExtra:(JXJunctionExtra *)extra {
	[junction registerExtra:extra];
}

- (void)leave {
	if (junction) {
		[junction disconnect];
	}
}

- (BOOL)sendMessage:(NSDictionary *)message toRole:(NSString *)role {
	return [junction sendMessage:message toRole:role];
}

- (BOOL)sendMessage:(NSDictionary *)message toActor:(NSString *)actor {
	return [junction sendMessage:message toActor:actor];
}

- (BOOL)sendMessageToSession:(NSDictionary *)message {
	return [junction sendMessageToSession:message];
}

- (void)onMessageReceived:(NSDictionary *)message header:(JXMessageHeader *)header {
	[self doesNotRecognizeSelector:_cmd];
}

- (BOOL)onDisconnect {
	[self doesNotRecognizeSelector:_cmd];
	return YES;
}

@end

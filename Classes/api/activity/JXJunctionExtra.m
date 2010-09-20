//
//  JXJunctionExtra.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXJunctionExtra.h"
#import "JXMessageHeader.h"s

@implementation JXJunctionExtra

- (JXJunctionActor *)getActor {
	return mParent;
}

- (void)setActor:(JXJunctionActor *)actor {
	mParent = actor;
}

- (void)updateInvitationParameters:(NSDictionary *)params {
	
}

- (BOOL)beforeOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h {
	return YES;
}

- (void)afterOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h {
	
}

- (BOOL)beforeSendMessage:(NSDictionary *)msg toActor:(NSString *)actorID {
	return [self beforeSendMessage:msg];
}

- (BOOL)beforeSendMessage:(NSDictionary *)msg toRole:(NSString *)role {
	return [self beforeSendMessage:msg];
}

- (BOOL)beforeSendMessageToSession:(NSDictionary *)msg {
	return [self beforeSendMessage:msg];
}

- (BOOL)beforeSendMessage:(NSDictionary *)msg {
	return YES;
}

- (BOOL)beforeActivityJoin {
	return YES;
}

- (void)afterActivityJoin {
	
}

- (BOOL)beforeActivityRejoin {
	return YES;
}
- (void)afterActivityRejoin {}

- (BOOL)beforeActivityCreate {
	return YES;
}

- (void)afterActivityCreate {
	
}

- (NSInteger)getPriority {
	return 20;
}

@end

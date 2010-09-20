//
//  JXJunction.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXJunction.h"
#import "JXExtrasDirector.h"
#import "JXActivityScript.h"
#import "JXJunctionActor.h"

NSString *NS_JX = @"jx";

@implementation JXJunction

- (id)init {
	if (self = [super init]) {
		mExtrasDirector = [[JXExtrasDirector alloc] init];
	}
	return self;
}

- (void)dealloc{
	[mExtrasDirector release];
	[super dealloc];
}

- (JXActivityScript *)getActivityScript {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSURL *)getAcceptedInvitation {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSString *)getSessionID {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (JXJunctionActor *)getActor {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSURL *)getBaseInvitationURL {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSURL *)getInvitationURL {
	return [self getInvitationURLForRole:nil];
}

- (NSURL *)getInvitationURLForRole:(NSString *)role {
	NSURL *url = [self getBaseInvitationURL];
	
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	if (role) {
		[params setObject:role forKey:@"role"];
	}
	[mExtrasDirector updateInvitationParameters:params];
	
	NSString *query = @"?";
	NSArray *keys = [params allKeys];
	for (NSString *key in keys) {
		NSString *param = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *value = [params objectForKey:key];
		query = [query stringByAppendingFormat:@"%@=%@&", param, value];
	}
	query = [query substringToIndex:([query length]-1)];
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@", [url absoluteString], query];
	return [NSURL URLWithString:urlString];
}

- (void)disconnect {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)reconnect {
	[self doesNotRecognizeSelector:_cmd];
}

- (BOOL)isConnected {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (BOOL)doSendMessage:(NSDictionary *)message toRole:(NSString *)role {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (BOOL)sendMessage:(NSDictionary *)message toRole:(NSString *)role {
	if ([mExtrasDirector beforeSendMessage:message toRole:role]) {
		return [self doSendMessage:message toRole:role];
	}
	return NO;
}

- (BOOL)doSendMessage:(NSDictionary *)message toActor:(NSString *)actorID {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (BOOL)sendMessage:(NSDictionary *)message toActor:(NSString *)actorID {
	if ([mExtrasDirector beforeSendMessage:message toActor:actorID]) {
		return [self doSendMessage:message toActor:actorID];
	}
	return NO;
}

- (BOOL)doSendMessageToSession:(NSDictionary *)message {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

- (BOOL)sendMessageToSession:(NSDictionary *)message {
	if ([mExtrasDirector beforeSendMessageToSession:message]) {
		return [self doSendMessageToSession:message];
	}
	return NO;
}

- (void)triggerMessageReceived:(NSDictionary *)message header:(JXMessageHeader *)header {
	if ([mExtrasDirector beforeOnMessageReceived:message header:header]) {
		[[self getActor] onMessageReceived:message header:header];
		[mExtrasDirector afterOnMessageReceived:message header:header];
	}
}

- (void)triggerActorJoin:(BOOL)isCreator {
	if (isCreator) {
		if (![mExtrasDirector beforeActivityCreate]) {
			[self disconnect];
			return;
		}
		[[self getActor] onActivityCreate];
		[mExtrasDirector afterActivityCreate];
	}
	
	if (![mExtrasDirector beforeActivityJoin]) {
		[self disconnect];
		return;
	}
	[[self getActor] onActivityJoin];
	[mExtrasDirector afterActivityJoin];
}

- (void)triggerActorRejoin {
	if ([mExtrasDirector beforeActivityRejoin]) {
		[[self getActor] onActivityRejoin];
		[mExtrasDirector afterActivityRejoin];
	}
}

- (void)triggerDisconnect {
	if ([[self getActor] onDisconnect]) {
		[self reconnect];
	}
}

- (void)registerExtra:(JXJunctionExtra *)extra {
	[extra setActor:[self getActor]];
	[mExtrasDirector registerExtra:extra];
}

@end

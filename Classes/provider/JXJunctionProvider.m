//
//  JXJunctionProvider.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXJunctionProvider.h"
#import "JXJunctionActor.h"

@interface JXJunctionActor_Transient : JXJunctionActor {
@private
	NSDictionary *msg;
}

- (id)initWithMessage:(NSDictionary *)message;

@end

@implementation JXJunctionActor_Transient

- (id)initWithMessage:(NSDictionary *)message {
	if (self = [super initWithRole:@"transient"]) {
		msg = [message retain];
	}
	return self;
}

- (void)dealloc {
	[msg release];
	[super dealloc];
}

- (void)onMessageReceived:(NSDictionary *)message
				   header:(JXMessageHeader *)header {}

- (void)onActivityJoin {
	if (msg)
		[self sendMessageToSession:msg];
	[self leave];
}

- (BOOL)onDisconnect {
	return NO;
}

@end


@implementation JXJunctionProvider

- (BOOL)sendMessage:(NSDictionary *)msg
		 toActivity:(NSURL *)activitySession {
	JXJunctionActor *sender = [[JXJunctionActor_Transient alloc] initWithMessage:msg];
	JXJunction *jx = [self newJunctionWithURL:activitySession actor:[sender autorelease]];
	if (jx) {
		[jx release];
		return YES;
	} else {
		return NO;
	}

}

- (void)setJunctionMaker:(JXJunctionMaker *)maker {
	mJunctionMaker = maker;
}

- (JXJunction *)newJunctionWithURL:(NSURL *)url
						  actor:(JXJunctionActor *)actor {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
									 actor:(JXJunctionActor *)actor {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (JXActivityScript *)getActivityScriptForURL:(NSURL *)url {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end

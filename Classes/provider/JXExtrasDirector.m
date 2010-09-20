//
//  JXExtrasDirector.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXExtrasDirector.h"
#import "JXJunctionExtra.h"
#import "JXJunctionActor.h"


@implementation JXExtrasDirector

- (id)init {
	if (self = [super init]) {
		mExtras = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[mExtras release];
	[super dealloc];
}

- (void)registerExtra:(JXJunctionExtra *)extra {
	for (int i = 0; i < [mExtras count]; i++) {
		if ([[mExtras objectAtIndex:i] getPriority] > [extra getPriority]) {
			[mExtras insertObject:extra atIndex:i];
			return;
		}
	}
	[mExtras addObject:extra];
}

- (BOOL)beforeOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h {
	BOOL ret = YES;
	for (int i = [mExtras count]-1; i >= 0; i--) {
		JXJunctionExtra *extra = [mExtras objectAtIndex:i];
		if (![extra beforeOnMessageReceived:msg header:h]) {
			ret = NO;
		}
	}
	return ret;
}

- (void)afterOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h {
	for (int i = [mExtras count]-1; i >= 0; i--) {
		JXJunctionExtra *extra = [mExtras objectAtIndex:i];
		[extra afterOnMessageReceived:msg header:h];
	}
}

- (BOOL)beforeSendMessage:(NSDictionary *)msg toActor:(NSString *)actorID {
	BOOL ret = YES;
	for (JXJunctionExtra *extra in mExtras) {
		if (![extra beforeSendMessage:msg toActor:actorID]) {
			ret = NO;
		}
	}
	return ret;
}

- (BOOL)beforeSendMessage:(NSDictionary *)msg toRole:(NSString *)role {
	BOOL ret = YES;
	for (JXJunctionExtra *extra in mExtras) {
		if (![extra beforeSendMessage:msg toRole:role]) {
			ret = NO;
		}
	}
	return ret;
}

- (BOOL)beforeSendMessageToSession:(NSDictionary *)msg {
	BOOL ret = YES;
	for (JXJunctionExtra *extra in mExtras) {
		if (![extra beforeSendMessageToSession:msg]) {
			ret = NO;
		}
	}
	return ret;
}

- (BOOL)beforeActivityJoin {
	BOOL ret = YES;
	for (JXJunctionExtra *extra in mExtras) {
		if (![extra beforeActivityJoin]) {
			ret = NO;
		}
	}
	return ret;
}

- (void)afterActivityJoin {
	for (JXJunctionExtra *extra in mExtras) {
		[extra afterActivityJoin];
	}
}

- (BOOL)beforeActivityRejoin {
	BOOL ret = YES;
	for (JXJunctionExtra *extra in mExtras) {
		if (![extra beforeActivityRejoin]) {
			ret = NO;
		}
	}
	return ret;
}

- (void)afterActivityRejoin {
	for (JXJunctionExtra *extra in mExtras) {
		[extra afterActivityRejoin];
	}
}

- (BOOL)beforeActivityCreate {
	BOOL ret = YES;
	for (JXJunctionExtra *extra in mExtras) {
		if (![extra beforeActivityCreate]) {
			ret = NO;
		}
	}
	return ret;
}

- (void)afterActivityCreate {
	for (JXJunctionExtra *extra in mExtras) {
		[extra afterActivityCreate];
	}
}

- (void)updateInvitationParameters:(NSDictionary *)params {
	for (JXJunctionExtra *extra in mExtras) {
		[extra updateInvitationParameters:params];
	}
}

@end

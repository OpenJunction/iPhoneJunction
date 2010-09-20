//
//  JXXMPPKeepAlive.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/28/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXXMPPKeepAlive.h"
#import "JXJunctionActor.h"
#import "JXJunction.h"

#include "unistd.h"

@implementation JXXMPPKeepAlive

+ (JXXMPPKeepAlive *)keepAlive {
	return [[[JXXMPPKeepAlive alloc] init] autorelease];
}

@synthesize lastPong;

- (void)dealloc {
	[lastPong release];
	[super dealloc];
}

- (void)pingActor:(JXJunctionActor *)actor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while (YES) {
		if ([lastPong timeIntervalSinceNow] < -60) {
			[actor.junction triggerDisconnect];
			break;
		}
		
		NSMutableDictionary *ping = [NSMutableDictionary dictionary];
		[ping setObject:@"ping" forKey:@"JXXMPPKeepAlive"];
		[actor sendMessage:ping toActor:[actor actorID]];
		
		sleep(30);
	}
	[pool drain];
}

- (BOOL)beforeOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h {
	if ([msg objectForKey:@"JXXMPPKeepAlive"]) {
		self.lastPong = [NSDate date];
		return NO;
	}
	return YES;
}

- (BOOL)beforeActivityJoin {
	self.lastPong = [NSDate date];
	[self performSelectorInBackground:@selector(pingActor:)
						   withObject:mParent];
	return YES;
}

- (BOOL)beforeActivityRejoin {
	return [self beforeActivityJoin];
}

@end

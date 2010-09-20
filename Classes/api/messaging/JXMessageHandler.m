//
//  JXMessageHandler.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXMessageHandler.h"
#import "JXMessageHeader.h"

@implementation JXMessageHandler

- (NSArray *)supportedRoles {
	return nil;
}

- (NSArray *)supportedActors {
	return nil;
}

- (NSArray *)supportedChannels {
	return nil;
}

- (BOOL)supportsMessage:(NSDictionary *)message {
	return YES;
}

- (void)onMessageReceived:(NSDictionary *)message header:(JXMessageHeader *)header {
	[self doesNotRecognizeSelector:_cmd];
}

@end

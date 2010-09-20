//
//  JXXMPPSwitchboardConfig.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXXMPPSwitchboardConfig.h"


@implementation JXXMPPSwitchboardConfig

- (id)initWithHost:(NSString *)hostName {
	if (self = [super init]) {
		host = [hostName retain];
		user = password = nil;
		connectionTimeout = -1;
	}
	return self;
}

- (void)dealloc {
	[host release];
	[user release];
	[password release];
	[super dealloc];
}

@synthesize host;
@synthesize user;
@synthesize password;
@synthesize connectionTimeout;

- (NSString *)getChatService {
	return [NSString stringWithFormat:@"conference.%@", host];
}

@end

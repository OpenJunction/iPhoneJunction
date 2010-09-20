//
//  JXJunctionMaker.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXJunctionMaker.h"
#import "JXJunctionProvider.h"
#import "JXJunction.h"
#import "JXActivityScript.h"
#import "JXCast.h"
#import "JXXMPPJunctionProvider.h"
#import "JXXMPPSwitchboardConfig.h"
#import "JXJunctionActor.h"


@interface JXJunctionActor_Inviter : JXJunctionActor
{
@private
	NSURL *invitationURL;
}

- (id)initWithInvitationURL:(NSURL *)url;

@end

@implementation JXJunctionActor_Inviter

- (id)initWithInvitationURL:(NSURL *)url {
	if (self = [super initWithRole:@"inviter"]) {
		invitationURL = [url retain];
	}
	return self;
}

- (void)dealloc {
	[invitationURL release];
	[super dealloc];
}

- (void)onActivityJoin {
	NSMutableDictionary *invitation = [NSMutableDictionary dictionary];
	[invitation setObject:@"cast" forKey:@"action"];
	[invitation setObject:[invitationURL absoluteString] forKey:@"activity"];
	[junction sendMessageToSession:invitation];
	[self leave];
}

- (void)onMessageReceived:(NSDictionary *)message
				   header:(JXMessageHeader *)header {
	
}

@end

@implementation JXJunctionMaker

- (void)dealloc {
	[mProvider release];
	[super dealloc];
}

+ (JXJunctionMaker *)getInstanceWithSwitchboard:(id<JXSwitchboardConfig>)switchboardConfig {
	JXJunctionMaker *maker = [[JXJunctionMaker alloc] init];
	maker->mProvider = [maker newProviderWithSwitchboard:switchboardConfig];
	[maker->mProvider setJunctionMaker:maker];
	return [maker autorelease];
}

+ (NSString *)getSessionIDFromURL:(NSURL *)url {
	return [[url path] substringFromIndex:1];
}

+ (NSString *)getRoleFromInvitation:(NSURL *)url {
	NSString *query = [url query];
	if (query == nil) return nil;
	NSUInteger startPos = [query rangeOfString:@"role="].location;
	if (startPos == NSNotFound) return nil;
	startPos += 5;
	
	query = [query substringFromIndex:startPos];
	NSUInteger endPos = [query rangeOfString:@"&"].location;
	if (endPos != NSNotFound) {
		NSRange range = {0, (endPos-startPos)};
		query = [query substringWithRange:range];
	}
	return query;
}

- (JXJunctionProvider *)newProviderWithSwitchboard:(id<JXSwitchboardConfig>)switchboardConfig {
	if ([switchboardConfig isMemberOfClass:[JXXMPPSwitchboardConfig class]]) {
		return [[JXXMPPJunctionProvider alloc] initWithSwitchboard:(JXXMPPSwitchboardConfig *)switchboardConfig];
	} else {
		return nil;
	}
}

- (JXJunction *)newJunctionWithURL:(NSURL *)url
							 actor:(JXJunctionActor *)actor {
	return [mProvider newJunctionWithURL:url actor:actor];
}

- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
										actor:(JXJunctionActor *)actor {
	return [mProvider newJunctionWithActivityScript:desc actor:actor];
}

- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
										actor:(JXJunctionActor *)actor
										 cast:(JXCast *)support {
	JXJunction *jx = [mProvider newJunctionWithActivityScript:desc actor:actor];
	NSUInteger size = [support size];
	for (int i = 0; i < size; i++) {
		if ([support getDirectorAt:i]) {
			NSURL *invitationURL = [jx getInvitationURLForRole:[support getRoleAt:i]];
			[self castActorWithDirector:[support getDirectorAt:i] invitation:invitationURL];
		}
	}
	return jx;
}

- (void)sendMessage:(NSDictionary *)msg toActivity:(NSURL *)activitySession {
	[mProvider sendMessage:msg toActivity:activitySession];
}

- (JXActivityScript *)getActivityScriptForURL:(NSURL *)url {
	return [mProvider getActivityScriptForURL:url];
}

- (void)castActorWithDirector:(NSURL *)directorURL
				   invitation:(NSURL *)invitationURL {
	JXJunctionActor *actor = [[JXJunctionActor_Inviter alloc] initWithInvitationURL:invitationURL];
	[self newJunctionWithURL:directorURL actor:actor];
}

@end

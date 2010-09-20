//
//  JXXMPPJunction.mm
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXXMPPJunction.h"
#import "JXActivityScript.h"
#import "JXXMPPSwitchboardConfig.h"
#import "JXXMPPJunctionProvider.h"
#import "JXJunctionActor.h"
#import "JXJunctionExtra.h"
#import "JXMessageHeader.h"
#import "JXMessageHandler.h"
#import "JXXMPPKeepAlive.h"
#import "JXXMPPJunctionConnectionListener.h"
#import "JXXMPPJunctionConfigHandler.h"
#import "JXXMPPJunctionRoomHandler.h"

#import "JSON.h"

#include <string>
#include <gloox/dataform.h>
#include <gloox/tag.h>
#include <gloox/message.h>
#include <gloox/messagehandler.h>
#include <gloox/messagesession.h>
#include <gloox/jid.h>

@interface JXMessageHandler_Default : JXMessageHandler
{
@private
	JXJunction *jx;
}

- (id)initWithJunction:(JXJunction *)junction;

@end

@implementation JXMessageHandler_Default

- (id)initWithJunction:(JXJunction *)junction {
	if (self = [super init]) {
		jx = junction;
	}
	return self;
}

- (void)onMessageReceived:(NSDictionary *)message header:(JXMessageHeader *)header {
	[jx triggerMessageReceived:message header:header];
}

@end

@implementation JXXMPPJunction

- (JXActivityScript *)activityDescription {
	return mActivityDescription;
}

- (JXJunctionActor *)owner {
	return mOwner;
}

- (NSArray *)messageHandlers {
	return messageHandlers;
}

- (NSConditionLock *)roomLock {
	return roomLock;
}

- (void)setRoomLockCondition:(LockCondition)c {
	[roomLock lock];
	[roomLock unlockWithCondition:c];
}

- (BOOL)joinSessionChat {
	string room = [mActivityDescription.sessionID UTF8String];
	room += "@conference.";
	room += mClient->server();
	room += "/";
	room += [mOwner.actorID UTF8String];
	
	mSessionChat = new MUCRoom(mClient, JID(room), roomHandler, configHandler);
	mSessionChat->setRequestHistory(0, MUCRoom::HistoryUnknown);
	
	NSLog(@"Joining %s", room.c_str());
	[mActivityDescription setActivityCreator:NO];
	[self setRoomLockCondition:WAITING];
	mSessionChat->join();
	if ([roomLock lockWhenCondition:DONE 
						 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
		[roomLock unlockWithCondition:READY];
		return true;
	} else {
		[self setRoomLockCondition:READY];
		return false;
	}
}

- (BOOL)rejoinSessionChat {
	// kick old actors
	if ([mProvider sendMessage:nil toActivity:[self getInvitationURL]]) {
		if (mSessionChat)
			delete mSessionChat;
		return [self joinSessionChat];
	} else {
		return NO;
	}

}

- (id)initWithActivityScript:(JXActivityScript *)desc client:(Client *)client
					  config:(JXXMPPSwitchboardConfig *)xmppConfig provider:(JXXMPPJunctionProvider *)prov {
	if (self = [super init]) {
		if (mClient = client) {
			mActivityDescription = [desc retain];
			mProvider = [prov retain];
			messageHandlers = [[NSMutableArray alloc] init];
			
			roomLock = [[NSConditionLock alloc] initWithCondition:READY];
			roomHandler = new JXXMPPJunctionRoomHandler(self);
			configHandler = new JXXMPPJunctionConfigHandler(self);
			
			connectionListener = new JXXMPPJunctionConnectionListener(self);
			mClient->registerConnectionListener(connectionListener);
		} else {
			NSLog(@"XMPP client must not be NULL.");
			[self release];
			return nil;
		}
	}
	return self;
}

- (void)dealloc {
	delete mSessionChat;
	delete mClient;
	
	delete roomHandler;
	delete configHandler;
	delete connectionListener;
	
	[mAcceptedInvitation release];
	[mActivityDescription release];
	[mProvider release];
	[messageHandlers release];
	[roomLock release];
	[super dealloc];
}

- (NSString *)getActivityID {
	return mActivityDescription.activityID;
}

- (JXActivityScript *)getActivityScript {
	return mActivityDescription;
}

- (void)registerActor:(JXJunctionActor *)actor {
	mOwner = actor;
	mOwner.junction = self;
	
	//[self registerExtra:[JXXMPPKeepAlive keepAlive]];
	NSArray *extras = [actor getInitialExtras];
	if (extras) {
		for (JXJunctionExtra *extra in extras) {
			[self registerExtra:extra];
		}
	}
	
	if ([self joinSessionChat]) {
		JXMessageHandler_Default *handler = [[JXMessageHandler_Default alloc] initWithJunction:self];
		[self registerMessageHandler:[handler autorelease]];
		
		[self triggerActorJoin:[mActivityDescription isActivityCreator]];
	} else {
		[self disconnect];
	}
}

- (void)disconnect {
	mClient->disconnect();
}

- (void)reconnect {
	if ([mProvider syncConnectClient:mClient beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]]) {
		if ([self rejoinSessionChat])
			[self triggerActorRejoin];
		else {
			[self disconnect];
			[self triggerDisconnect];
		}
	} else {
		[self disconnect];
		[self triggerDisconnect];
	}
}

- (BOOL)isConnected {
	return (mClient->state() == StateConnected);
}

- (NSArray *)getRoles {
	return [mActivityDescription getRoles];
}

- (NSString *)getSessionID {
	return mActivityDescription.sessionID;
}

- (NSString *)getSwitchboard {
	return mActivityDescription.host;
}

- (void)registerMessageHandler:(JXMessageHandler *)handler {
	[messageHandlers addObject:handler];
}

- (void)sendMessage:(NSDictionary *)message toTarget:(id<JXMessageTarget>)target {
	[target sendMessage:message];
}

- (BOOL)doSendMessage:(NSDictionary *)message toActor:(NSString *)actorID {
	if (![self isConnected])
		return NO;
	
	string privChat = mSessionChat->name();
	privChat += "@";
	privChat += mSessionChat->service();
	privChat += "/";
	privChat += [actorID UTF8String];
	
	MessageSession *session = new MessageSession(mClient, JID(privChat));
	session->send([[message JSONRepresentation] UTF8String]);
	mClient->disposeMessageSession(session);
	return YES;
}

- (BOOL)doSendMessage:(NSDictionary *)message toRole:(NSString *)role {
	if (![self isConnected])
		return NO;
	
	NSMutableDictionary *jx = [message objectForKey:NS_JX];
	if (jx == nil) {
		jx = [NSMutableDictionary dictionary];
	}
	[jx setObject:role forKey:@"targetRole"];
	[(NSMutableDictionary *)message setObject:jx forKey:NS_JX];
	mSessionChat->send([[message JSONRepresentation] UTF8String]);
	return YES;
}

- (BOOL)doSendMessageToSession:(NSDictionary *)message {
	if (![self isConnected])
		return NO;
	
	mSessionChat->send([[message JSONRepresentation] UTF8String]);
	return YES;
}

- (NSURL *)getBaseInvitationURL {
	NSString *url = [NSString stringWithFormat:@"junction://%@/%@",
					 [self getSwitchboard], [self getSessionID]];
	return [NSURL URLWithString:url];
}

- (NSURL *)getAcceptedInvitation {
	return mAcceptedInvitation;
}

- (JXJunctionActor *)getActor {
	return mOwner;
}

@end

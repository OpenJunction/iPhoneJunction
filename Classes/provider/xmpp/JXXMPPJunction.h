//
//  JXXMPPJunction.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXJunction.h"
#import "JXMessageTarget.h"

@class JXActivityScript;
@class JXJunctionActor;
@class JXXMPPJunctionProvider;
@class JXMessageHandler;
@class JXXMPPSwitchboardConfig;

#include <gloox/client.h>
#include <gloox/mucroom.h>
#include <gloox/mucroomhandler.h>
#include <gloox/mucroomconfighandler.h>
#include <gloox/connectionlistener.h>

using namespace std;
using namespace gloox;

enum LockCondition {
	READY,
	WAITING,
	DONE
};

@interface JXXMPPJunction : JXJunction {
@public
	NSURL *mAcceptedInvitation;
	Client *mClient;
@private
	BOOL PUBLIC_ROOM;
	
	JXXMPPJunctionProvider *mProvider;
	JXActivityScript *mActivityDescription;
	NSConditionLock *roomLock;
	JXJunctionActor *mOwner;
	NSMutableArray *messageHandlers;
	
	MUCRoom *mSessionChat;
	MUCRoomHandler *roomHandler;
	MUCRoomConfigHandler *configHandler;
	ConnectionListener *connectionListener;
}

@property (nonatomic, readonly) JXActivityScript *activityDescription;
@property (nonatomic, readonly) JXJunctionActor *owner;
@property (nonatomic, readonly) NSArray *messageHandlers;
@property (nonatomic, readonly) NSConditionLock *roomLock;

- (NSString *)getActivityID;

- (void)registerActor:(JXJunctionActor *)actor;

- (NSArray *)getRoles;
- (NSString *)getSwitchboard;

- (void)registerMessageHandler:(JXMessageHandler *)handler;

- (void)sendMessage:(NSDictionary *)message
		   toTarget:(id<JXMessageTarget>)target;

//protected
- (id)initWithActivityScript:(JXActivityScript *)desc
					  client:(Client *)client
					  config:(JXXMPPSwitchboardConfig *)xmppConfig
					provider:(JXXMPPJunctionProvider *)prov;

@end

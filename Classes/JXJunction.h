//
//  JXJunction.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXActivityScript;
@class JXJunctionActor;
@class JXMessageHeader;
@class JXExtrasDirector;
@class JXJunctionExtra;

extern NSString *NS_JX;

@interface JXJunction : NSObject {
@private
	JXExtrasDirector *mExtrasDirector;
}

- (id)init;

- (NSURL *)getInvitationURLForRole:(NSString *)role;

- (void)triggerMessageReceived:(NSDictionary *)message
						header:(JXMessageHeader *)header;
- (void)triggerActorJoin:(BOOL)isCreator;
- (void)triggerActorRejoin;
- (void)triggerDisconnect;

//abstract
- (JXActivityScript *)getActivityScript;
- (NSURL *)getAcceptedInvitation;
- (NSString *)getSessionID;
- (JXJunctionActor *)getActor;
- (NSURL *)getBaseInvitationURL;

- (void)disconnect;
- (void)reconnect;
- (BOOL)isConnected;

- (BOOL)doSendMessage:(NSDictionary *)message
			   toRole:(NSString *)role;
- (BOOL)doSendMessage:(NSDictionary *)message
			  toActor:(NSString *)actorID;
- (BOOL)doSendMessageToSession:(NSDictionary *)message;

//final
- (NSURL *)getInvitationURL;

- (BOOL)sendMessage:(NSDictionary *)message
			 toRole:(NSString *)role;
- (BOOL)sendMessage:(NSDictionary *)message
			toActor:(NSString *)actorID;
- (BOOL)sendMessageToSession:(NSDictionary *)message;

- (void)registerExtra:(JXJunctionExtra *)extra;

@end

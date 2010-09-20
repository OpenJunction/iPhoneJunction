//
//  JXJunctionActor.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXJunction, JXMessageHeader, JXJunctionExtra;


@interface JXJunctionActor : NSObject {
@protected
	JXJunction *junction;
	
@private
	NSString *actorID;
	NSArray *mRoles;
}

@property (retain) JXJunction *junction;
@property (readonly, retain) NSString *actorID;

- (id)initWithRole:(NSString *)role;
- (id)initWithRoles:(NSArray *)roles;

- (NSArray *)getRoles;
- (void)onActivityJoin;
- (void)onActivityStart;
- (void)onActivityCreate;
- (NSArray *)getInitialExtras;
- (void)registerExtra:(JXJunctionExtra *)extra;

- (void)onActivityRejoin;
- (BOOL)isConnected;

//final
- (void)leave;
- (BOOL)sendMessage:(NSDictionary *)message
			toActor:(NSString *)actor;
- (BOOL)sendMessageToSession:(NSDictionary *)message;
- (BOOL)sendMessage:(NSDictionary *)message
			 toRole:(NSString *)role;

//abstract
- (void)onMessageReceived:(NSDictionary *)message
				   header:(JXMessageHeader *)header;
- (BOOL)onDisconnect;

@end

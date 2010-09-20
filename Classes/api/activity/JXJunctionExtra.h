//
//  JXJunctionExtra.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXJunctionActor;
@class JXMessageHeader;

@interface JXJunctionExtra : NSObject {
	JXJunctionActor *mParent;
}

- (void)setActor:(JXJunctionActor *)actor;
- (void)updateInvitationParameters:(NSDictionary *)params;

- (BOOL)beforeOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h;
- (void)afterOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h;

- (BOOL)beforeSendMessage:(NSDictionary *)msg toActor:(NSString *)actorID;
- (BOOL)beforeSendMessage:(NSDictionary *)msg toRole:(NSString *)role;
- (BOOL)beforeSendMessageToSession:(NSDictionary *)msg;
- (BOOL)beforeSendMessage:(NSDictionary *)msg;

- (BOOL)beforeActivityJoin;
- (void)afterActivityJoin;

- (BOOL)beforeActivityRejoin;
- (void)afterActivityRejoin;

- (BOOL)beforeActivityCreate;
- (void)afterActivityCreate;

- (NSInteger)getPriority;

//final
- (JXJunctionActor *)getActor;

@end

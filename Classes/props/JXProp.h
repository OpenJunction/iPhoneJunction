//
//  JXProp.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/30/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXJunctionExtra.h"
#import "JXIPropState.h"
#import "JXIPropChangeListener.h"

extern NSString * const EVT_CHANGE;
extern NSString * const EVT_SYNC;

@interface JXProp : JXJunctionExtra {
@private
	NSString *uuid;
	NSString *propName;
	NSString *propReplicaName;
	
	id<JXIPropState> state;
	id<JXIPropState> cleanState;
	
	long sequenceNum;
	NSString *lastOpUUID;
	
	long staleness;
	
	int mode;
	NSString *syncId;
	BOOL waitingForIHaveState;
	NSMutableArray *opsSYNC;
	NSMutableArray *stateSyncRequests;
	
	NSMutableArray *pendingLocals;
	NSMutableArray *changeListeners;
	
	NSTimer *taskTimer;
	BOOL active;
	
	NSTimeInterval timeOfLastSyncRequest;
	NSTimeInterval timeOfLastHello;
}

@property (nonatomic, readonly) long staleness;
@property (nonatomic, readonly) long sequenceNum;
@property (nonatomic, readonly) NSString *propName;

- (id)initWithName:(NSString *)n state:(id<JXIPropState>)s replicaName:(NSString *)rn;
- (id)initWithName:(NSString *)n state:(id<JXIPropState>)s;

- (void)periodicTask:(NSTimer *)timer;

- (NSString *)stateToString;

- (void)addChangeListener:(id<JXIPropChangeListener>)listener;

- (void)addOperation:(NSDictionary *)operation;

//protected
- (id<JXIPropState>)_state;

- (void)_logInfo:(NSString *)s;
- (void)_logErr:(NSString *)s;
- (void)_assertTrue:(BOOL)cond withString:(NSString *)s;
- (void)_logState:(NSString *)s;

- (void)_dispatchChangeNotifcation:(id)o forEventType:(NSString *)evtType;

- (void)_handleReceivedOp:(NSDictionary *)opMsg;

- (void)_exitSYNCMode;
- (void)_enterSYNCMode;
- (void)_broadcastSyncRequest;

- (BOOL)_isSelfMsg:(NSDictionary *)msg;
- (void)_handleMessage:(NSDictionary *)msg;
- (void)_handleStateSyncMsg:(NSDictionary *)msg;

- (void)_sendHello;
- (void)_sendMessageToProp:(NSDictionary *)m;
- (void)_sendMessage:(NSDictionary *)m toPropReplica:(NSString *)actorId;

- (NSDictionary *)_helloMsg;
- (NSDictionary *)_iHaveStateMsgWithSyncId:(NSString *)sId;
- (NSDictionary *)_whoHasStateMsgWithSyncId:(NSString *)sId;
- (NSDictionary *)_stateOperationMsg:(NSDictionary *)op;
- (NSDictionary *)_stateSyncMsgWithSyncId:(NSString *)sId;
- (NSDictionary *)_sendMeStateMsgWithSyncId:(NSString *)sId;

//protected abstract
- (id<JXIPropState>)_reifyState:(NSDictionary *)dic;

@end

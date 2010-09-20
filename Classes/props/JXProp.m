//
//  JXProp.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/30/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXProp.h"
#import "JXJunctionActor.h"
#import "JXCategoryDummy.h"
#import "JXMessageHeader.h"
#import "JXDictionaryWrapper.h"

enum {
	MODE_NORM = 1,
	MODE_SYNC
};

enum {
	MSG_STATE_OPERATION = 1,
	MSG_WHO_HAS_STATE,
	MSG_I_HAVE_STATE,
	MSG_SEND_ME_STATE,
	MSG_STATE_SYNC,
	MSG_HELLO
};

NSString * const EVT_CHANGE = @"change";
NSString * const EVT_SYNC = @"sync";

@implementation JXProp

- (id)initWithName:(NSString *)n state:(id <JXIPropState>)s replicaName:(NSString *)rn {
	if (self = [super init]) {
		uuid = [[NSString stringWithUUID] retain];
		
		sequenceNum = 0;
		lastOpUUID = [[NSString string] retain];
		
		staleness = 0;
		
		mode = MODE_NORM;
		syncId = [[NSString string] retain];
		waitingForIHaveState = NO;
		
		opsSYNC = [[NSMutableArray alloc] init];
		stateSyncRequests = [[NSMutableArray alloc] init];
		
		pendingLocals = [[NSMutableArray alloc] init];
		changeListeners = [[NSMutableArray alloc] init];
		
		active = NO;
		
		propName = [n retain];
		cleanState = [s retain];
		state = [s copy];
		propReplicaName = [rn retain];
		taskTimer = [NSTimer timerWithTimeInterval:1 target:self
										   selector:@selector(periodicTask:)
										   userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:taskTimer forMode:NSDefaultRunLoopMode];
		
		timeOfLastSyncRequest = 0;
		timeOfLastHello = 0;
	}
	return self;
}

- (id)initWithName:(NSString *)n state:(id <JXIPropState>)s {
	return [self initWithName:n state:s
				  replicaName:[NSString stringWithFormat:@"%@-replica%@", n, [NSString stringWithUUID]]];
}

- (void)dealloc {
	[uuid release];
	[lastOpUUID release];
	[syncId release];
	
	[opsSYNC release];
	[stateSyncRequests release];
	[pendingLocals release];
	[changeListeners release];
	
	[propName release];
	[cleanState release];
	[state release];
	[propReplicaName release];
	[taskTimer invalidate];
	[super dealloc];
}

@synthesize staleness;
@synthesize sequenceNum;
@synthesize propName;

- (void)periodicTask:(NSTimer *)timer {
	NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
	if (active && [self getActor]) {
		if (mode == MODE_NORM) {
			if (t - timeOfLastHello > 3) {
				[self _sendHello];
			}
		} else if (mode == MODE_SYNC) {
			if (t - timeOfLastSyncRequest > 5) {
				[self _broadcastSyncRequest];
			}
		}
	}
}

- (id<JXIPropState>)_state {
	return state;
}

- (NSString *)stateToString {
	return [state description];
}

- (NSString *)propName {
	return propName;
}

- (void)_logInfo:(NSString *)s {
	printf("prop@%s: %s\n", [propReplicaName UTF8String], [s UTF8String]);
}

- (void)_logErr:(NSString *)s {
	NSLog(@"prop@%@: %@", propReplicaName, s);
}

- (void)_assertTrue:(BOOL)cond withString:(NSString *)s {
	if (!cond) {
		[self _logErr:[NSString stringWithFormat:@"ASSERTION FAILED: %@", s]];
	}
}

- (void)_logState:(NSString *)s {
	printf("\n----------\n");
	[self _logInfo:s];
	printf("pendingLocals: %s\n", [[pendingLocals description] UTF8String]);
	printf("opsSync: %s\n", [[opsSYNC description] UTF8String]);
	printf("sequenceNum: %ld\n", sequenceNum);
	printf("----------\n\n");
}

- (id<JXIPropState>)_reifyState:(NSDictionary *)dic {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (void)addChangeListener:(id <JXIPropChangeListener>)listener {
	[changeListeners addObject:listener];
}

- (void)_dispatchChangeNotifcation:(id)o forEventType:(NSString *)evtType {
	for (id<JXIPropChangeListener> l in changeListeners) {
		if ([[l type] isEqualToString:evtType]) {
			[l onChange:o];
		}
	}
}

- (BOOL)beforeOnMessageReceived:(NSDictionary *)msg header:(JXMessageHeader *)h {
	if ([(NSString *)[msg objectForKey:@"propTarget"] isEqualToString:propName]) {
		NSMutableDictionary *m = [NSMutableDictionary dictionaryWithDictionary:msg];
		[m setObject:[h getSender] forKey:@"senderActor"];
		[self _handleMessage:m];
		return NO;
	} else {
		return YES;
	}
}

- (void)_handleReceivedOp:(NSDictionary *)opMsg {
	BOOL changed = NO;
	if ([self _isSelfMsg:opMsg]) {
		staleness = sequenceNum - [(NSNumber *)[opMsg objectForKey:@"localSeqNum"] longValue];
		[cleanState applyOperation:[opMsg objectForKey:@"op"]];
		NSMutableIndexSet *discardedLocals = [NSMutableIndexSet indexSet];
		NSString *opuuid = [opMsg objectForKey:@"uuid"];
		for (int i = 0; i < [pendingLocals count]; i++) {
			NSDictionary *m = [pendingLocals objectAtIndex:i];
			if ([(NSString *)[m objectForKey:@"uuid"] isEqualToString:opuuid]) {
				[discardedLocals addIndex:i];
			}
		}
		[pendingLocals removeObjectsAtIndexes:discardedLocals];
	} else {
		if ([pendingLocals count] > 0) {
			[cleanState applyOperation:[opMsg objectForKey:@"op"]];
			state = [cleanState copy];
			for (NSDictionary *msg in pendingLocals) {
				[state applyOperation:msg];
			}
		} else {
			[self _assertTrue:([state hash] == [cleanState hash])
				   withString:@"If pending locals is empty, state hash and cleanState hash should be equal."];
			NSDictionary *op = [opMsg objectForKey:@"op"];
			[cleanState applyOperation:op];
			[state applyOperation:(JXDictionaryWrapper *)[op copy]];
		}
		changed = YES;
	}
	
	[lastOpUUID release];
	lastOpUUID = [[opMsg objectForKey:@"uuid"] retain];
	sequenceNum += 1;
	
	if (changed) {
		[self _dispatchChangeNotifcation:nil forEventType:EVT_CHANGE];
	}

	[self _logState:[NSString stringWithFormat:@"Got op off wire, finished processing: %@",
					 [opMsg JSONRepresentation]]];
}

- (void)_exitSYNCMode {
	[self _logInfo:@"Exiting SYNC mode"];
	mode = MODE_NORM;
	[syncId release];
	syncId = [[NSString string] retain];
	waitingForIHaveState = NO;
}

- (void)_enterSYNCMode {
	[self _logInfo:@"Entering SYNC mode"];
	mode = MODE_SYNC;
	[syncId release];
	syncId = [[NSString stringWithUUID] retain];
	sequenceNum = -1;
	[opsSYNC removeAllObjects];
	waitingForIHaveState = YES;
	[self _broadcastSyncRequest];
}

- (void)_broadcastSyncRequest {
	@synchronized (self) {
		timeOfLastSyncRequest = [[NSDate date] timeIntervalSince1970];
		[self _sendMessageToProp:[self _whoHasStateMsgWithSyncId:syncId]];
	}
}

- (BOOL) _isSelfMsg:(NSDictionary *)msg {
	return [(NSString *)[msg objectForKey:@"senderReplicaUUID"] isEqualToString:uuid];
}

- (void)_handleMessage:(NSDictionary *)msg {
	@synchronized (self) {
		int msgType = [(NSNumber *)[msg objectForKey:@"type"] longValue];
		NSString *fromActor = [msg objectForKey:@"senderActor"];
		switch (mode) {
			case MODE_NORM:
				switch (msgType) {
					case MSG_STATE_OPERATION: {
						[self _handleReceivedOp:msg];
						break;
					}
					case MSG_SEND_ME_STATE: {
						if (![self _isSelfMsg:msg]) {
							[self _logInfo:@"Got SEND_ME_STATE"];
							NSString *sId = [msg objectForKey:@"syncId"];
							[self _sendMessage:[self _stateSyncMsgWithSyncId:sId] toPropReplica:fromActor];
						}
						break;
					}
					case MSG_HELLO: {
						[self _logInfo:@"Got HELLO"];
						if (![self _isSelfMsg:msg] &&
							[(NSNumber *)[msg objectForKey:@"localSeqNum"] longValue] > sequenceNum) {
							[self _enterSYNCMode];
						}
						break;
					}
					case MSG_WHO_HAS_STATE: {
						if (![self _isSelfMsg:msg]) {
							[self _logInfo:@"Got WHO_HAS_STATE"];
							NSString *sId = [msg objectForKey:@"syncId"];
							[self _sendMessage:[self _iHaveStateMsgWithSyncId:sId] toPropReplica:fromActor];
						}
						break;
					}
					default:
						[self _logInfo:[NSString stringWithFormat:@"NORM mode: Ignoring message, %@", [msg JSONRepresentation]]];
				 }
				break;
			case MODE_SYNC:
				switch (msgType) {
					case MSG_STATE_OPERATION: {
						[opsSYNC addObject:msg];
						[self _logInfo:@"SYNC mode: buffering op..."];
						break;
					}
					case MSG_I_HAVE_STATE: {
						NSString *sId = [msg objectForKey:@"syncId"];
						if (![self _isSelfMsg:msg] && waitingForIHaveState &&
							[sId isEqualToString:syncId]) {
							[self _logInfo:@"Got I_HAVE_STATE"];
							[self _sendMessage:[self _sendMeStateMsgWithSyncId:sId] toPropReplica:fromActor];
							waitingForIHaveState = NO;
						}
						break;
					}
					case MSG_STATE_SYNC: {
						if (![self _isSelfMsg:msg]) {
							NSString *sId = [msg objectForKey:@"syncId"];
							if (![sId isEqualToString:syncId]) {
								[self _logErr:@"Bogus sync id! Ignoring StateSyncMsg"];
							} else {
								[self _handleStateSyncMsg:msg];
							}

						}
						break;
					}
					default:
						[self _logInfo:[NSString stringWithFormat:@"SYNC mode: Ignoring message, %@", [msg JSONRepresentation]]];
				}
		}
	}
}

- (void)_handleStateSyncMsg:(NSDictionary *)msg {
	[self _logInfo:[NSString stringWithFormat:@"Got StateSyncMsg:%@", [msg JSONRepresentation]]];
	
	[self _logInfo:@"Reifying received state..."];
	[cleanState release];
	cleanState = [[self _reifyState:[msg objectForKey:@"state"]] retain];
	[self _logInfo:@"Copying clean to predicted..."];
	[state release];
	state = [cleanState copy];
	sequenceNum = [(NSNumber *)[msg objectForKey:@"seqNum"] longValue];
	[lastOpUUID release];
	lastOpUUID = [[msg objectForKey:@"lastOpUUID"] retain];
	
	[self _logInfo:@"Installed state."];
	[self _logInfo:[NSString stringWithFormat:@"sequenceNum:%l", sequenceNum]];
	[self _logInfo:@"Now applying buffered things..."];
	
	[pendingLocals removeAllObjects];
	
	BOOL apply = NO;
	for (NSDictionary *m in opsSYNC) {
		if (!apply && [lastOpUUID isEqualToString:[m objectForKey:@"uuid"]]) {
			apply = YES;
			continue;
		} else if (apply) {
			[self _handleReceivedOp:m];
		}
	}
	[opsSYNC removeAllObjects];
	[self _exitSYNCMode];
	[self _logState:@"Finished syncing."];
	[self _dispatchChangeNotifcation:nil forEventType:EVT_SYNC];
}

- (void)addOperation:(NSDictionary *)operation {
	@synchronized (self) {
		if (mode == MODE_NORM) {
			[self _logInfo:@"Adding predicted operation."];
			NSDictionary *msg = [self _stateOperationMsg:operation];
			[state applyOperation:operation];
			[self _dispatchChangeNotifcation:operation forEventType:EVT_CHANGE];
			[pendingLocals addObject:msg];
			[self _sendMessageToProp:msg];
		}
	}
}

- (void)_sendHello {
	@synchronized (self) {
		timeOfLastHello = [[NSDate date] timeIntervalSince1970];
		[self _sendMessageToProp:[self _helloMsg]];
	}
}

- (void)_sendMessageToProp:(NSDictionary *)m {
	NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithDictionary:m];
	[msg setObject:propName forKey:@"propTarget"];
	[msg setObject:uuid forKey:@"senderReplicaUUID"];
	[[self getActor] sendMessageToSession:msg];
}

- (void)_sendMessage:(NSDictionary *)m toPropReplica:(NSString *)actorId {
	NSMutableDictionary *msg = [NSMutableDictionary dictionaryWithDictionary:m];
	[msg setObject:propName forKey:@"propTarget"];
	[msg setObject:uuid forKey:@"senderReplicaUUID"];
	[[self getActor] sendMessage:msg toActor:actorId];
}

- (void)afterActivityJoin {
	active = YES;
}

- (NSDictionary *)_helloMsg {
	NSMutableDictionary *m = [NSMutableDictionary dictionary];
	[m setObject:[NSNumber numberWithInt:MSG_HELLO] forKey:@"type"];
	[m setObject:[NSNumber numberWithLong:sequenceNum] forKey:@"localSeqNum"];
	return m;
}

- (NSDictionary *)_iHaveStateMsgWithSyncId:(NSString *)sId {
	NSMutableDictionary *m = [NSMutableDictionary dictionary];
	[m setObject:[NSNumber numberWithInt:MSG_I_HAVE_STATE] forKey:@"type"];
	[m setObject:sId forKey:@"syncId"];
	return m;
}

- (NSDictionary *)_whoHasStateMsgWithSyncId:(NSString *)sId {
	NSMutableDictionary *m = [NSMutableDictionary dictionary];
	[m setObject:[NSNumber numberWithInt:MSG_WHO_HAS_STATE] forKey:@"type"];
	[m setObject:sId forKey:@"syncId"];
	return m;
}

- (NSDictionary *)_stateOperationMsg:(NSDictionary *)op {
	NSMutableDictionary *m = [NSMutableDictionary dictionary];
	[m setObject:[NSNumber numberWithInt:MSG_STATE_OPERATION] forKey:@"type"];
	[m setObject:op forKey:@"op"];
	[m setObject:[NSNumber numberWithLong:sequenceNum] forKey:@"localSeqNum"];
	[m setObject:[NSString stringWithUUID] forKey:@"uuid"];
	return m;
}

- (NSDictionary *)_stateSyncMsgWithSyncId:(NSString *)sId {
	NSMutableDictionary *m = [NSMutableDictionary dictionary];
	[m setObject:[NSNumber numberWithInt:MSG_STATE_SYNC] forKey:@"type"];
	[m setObject:[cleanState toDictionary] forKey:@"state"];
	[m setObject:[NSNumber numberWithLong:sequenceNum] forKey:@"seqNum"];
	[m setObject:lastOpUUID forKey:@"lastOpUUID"];
	[m setObject:sId forKey:@"syncId"];
	return m;
}

- (NSDictionary *)_sendMeStateMsgWithSyncId:(NSString *)sId {
	NSMutableDictionary *m = [NSMutableDictionary dictionary];
	[m setObject:[NSNumber numberWithInt:MSG_SEND_ME_STATE] forKey:@"type"];
	[m setObject:sId forKey:@"syncId"];
	return m;
}

@end

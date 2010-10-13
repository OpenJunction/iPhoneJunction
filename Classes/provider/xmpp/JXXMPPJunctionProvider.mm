//
//  JXXMPPJunctionProvider.mm
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXXMPPJunctionProvider.h"
#import "JXJunction.h"
#import "JXXMPPJunction.h"
#import "JXActivityScript.h"
#import "JXXMPPJunction.h"
#import "JXXMPPSwitchboardConfig.h"
#import "JSON.h"
#import "JXXMPPProviderConnectionListener.h"
#import "JXXMPPProviderRoomHandler.h"


#include <vector>
#include <string>
#include <gloox/gloox.h>
#include <gloox/mucroom.h>
#include <gloox/tag.h>
#include <gloox/dataform.h>


@implementation JXXMPPJunctionProvider


class MyLogHandler : public LogHandler {
public:
	void handleLog(LogLevel level, LogArea area, const string &message) {
		NSLog(@"%s", message.c_str());
	}
};

- (void)notifyFetchedScript:(JXActivityScript *)script {
	[fetchedScript release];
	fetchedScript = [script retain];
	
	if ([infoLock tryLockWhenCondition:WAITING]) {
		[infoLock unlockWithCondition:DONE];
	}
}

- (void)notifyConnect {
	if ([connectionLock tryLockWhenCondition:WAITING]) {
		[connectionLock unlockWithCondition:DONE];
	}
}	

- (void)setCondition:(LockCondition)c forLock:(NSConditionLock *)l {
	[l lock];
	[l unlockWithCondition:c];
}

- (void)connectClient:(id)clientPointer {
	Client *client = (Client *)[(NSValue *)clientPointer pointerValue];
	client->connect();
}

- (BOOL)syncConnectClient:(Client *)client beforeDate:(NSDate *)date {
	@synchronized (self) {
		client->registerConnectionListener(connectionListener);
		
		[self setCondition:WAITING forLock:connectionLock];
		[self performSelectorInBackground:@selector(connectClient:)
							   withObject:[NSValue valueWithPointer:client]];
		if ([connectionLock lockWhenCondition:DONE
								   beforeDate:date]) {
			[connectionLock unlockWithCondition:READY];
			client->removeConnectionListener(connectionListener);
			return (client->state() == StateConnected);
		} else {
			[self setCondition:READY forLock:connectionLock];
			client->removeConnectionListener(connectionListener);
			return NO;
		}
	}
}

- (Client *)getClientWithConfig:(JXXMPPSwitchboardConfig *)config
						   room:(NSString *)roomid {
	@synchronized (self) {
		Client *theClient = new Client([config.host UTF8String]);
		
		if (JXXMPPDEBUG) {
			theClient->logInstance().registerLogHandler(LogLevelDebug, LogAreaAll, new MyLogHandler());
		}
		
		if (config.user != nil) {
			theClient->setUsername([config.user UTF8String]);
			theClient->setPassword([config.password UTF8String]);
		}
		NSDate *timeoutDate = [config connectionTimeout] < 0?
		[NSDate distantFuture] : [NSDate dateWithTimeIntervalSinceNow:[config connectionTimeout]];
		while (![self syncConnectClient:theClient beforeDate:timeoutDate]) {
			[NSThread sleepForTimeInterval:1.0];
			if ([timeoutDate earlierDate:[NSDate date]] == timeoutDate) {
				NSLog(@"Could not connect to XMPP provider");
				delete theClient;
				return NULL;
			}
		}
		return theClient;
	}
}

- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)script
								   invitation:(NSURL *)invitation
										actor:(JXJunctionActor *)actor {
	//this needs to be made more formal
	if (script.host == nil && mConfig.host != nil) {
		script.host = mConfig.host;
	}
	
	Client *client = [self getClientWithConfig:mConfig room:script.sessionID];
	JXXMPPJunction *jx = [[JXXMPPJunction alloc] initWithActivityScript:script
																 client:client
																 config:mConfig
															   provider:self];
	if (jx) {
		jx->mAcceptedInvitation = [invitation retain];
		[jx registerActor:actor];
	}
	
	//requestServices? (see java implementation)
	
	return jx;
}

- (id)initWithSwitchboard:(JXXMPPSwitchboardConfig *)config {
	if (self = [super init]) {
		mConfig = [config retain];
		infoLock = [[NSConditionLock alloc] initWithCondition:READY];
		connectionLock = [[NSConditionLock alloc] initWithCondition:READY];
		connectionListener = new ProviderConnectionListener(self);
		roomHandler = new ProviderRoomHandler(self);
	}
	return self;
}

- (void)dealloc {
	[mConfig release];
	[infoLock release];
	[connectionLock release];
	delete connectionListener;
	delete roomHandler;
	[super dealloc];
}

- (JXJunction *)newJunctionWithURL:(NSURL *)url
							 actor:(JXJunctionActor *)actor {
	JXActivityScript *desc = [[JXActivityScript alloc] init];
	[desc setHost:[url host]];
	if ([url path]) { //TODO: check to make sure this works for URLs w/o path
		[desc setSessionID:[[url path] substringFromIndex:1]];
	}
	
	return [self newJunctionWithActivityScript:[desc autorelease]
									invitation:url
										 actor:actor];
}

- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
										actor:(JXJunctionActor *)actor {
	return [self newJunctionWithActivityScript:desc
									invitation:nil
										 actor:actor];
}

- (JXActivityScript *)getActivityScriptForURL:(NSURL *)url {
	@synchronized (self) {
		NSString *host = [url host];
		NSString *sessionID = [[url path] substringFromIndex:1];
		
		// pretty broken...
		JXXMPPSwitchboardConfig *config = [[JXXMPPSwitchboardConfig alloc] initWithHost:host];
		Client *client = [self getClientWithConfig:config room:sessionID];
		
		NSString *room = [NSString stringWithFormat:@"%@@%@", sessionID, [config getChatService]];
		NSLog(@"looking up info from xmpp room %@", room);
		
		[self setCondition:WAITING forLock:infoLock];
		MUCRoom chat(client, JID([room UTF8String]), roomHandler, NULL);
		chat.getRoomInfo();
		[infoLock lockWhenCondition:DONE];
		[infoLock unlockWithCondition:READY];
		
		return [fetchedScript autorelease];
	}
}

@end
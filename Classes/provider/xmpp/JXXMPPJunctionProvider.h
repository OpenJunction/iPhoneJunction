//
//  JXXMPPJunctionProvider.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXJunctionProvider.h"


#include <gloox/connectionlistener.h>
#include <gloox/mucroomhandler.h>
#include <gloox/client.h>

#define JXXMPPDEBUG 0

using namespace std;
using namespace gloox;

@class JXXMPPSwitchboardConfig;
@class JXActivityScript;
@class JXXMPPJunction;

@interface JXXMPPJunctionProvider : JXJunctionProvider {
@protected
	JXXMPPSwitchboardConfig *mConfig;
@private
	NSConditionLock *connectionLock;
	NSConditionLock *infoLock;
	JXActivityScript *fetchedScript;
	ConnectionListener *connectionListener;
	MUCRoomHandler *roomHandler;
}

- (id)initWithSwitchboard:(JXXMPPSwitchboardConfig *)config;

- (BOOL)syncConnectClient:(Client *)client beforeDate:(NSDate *)date;

- (void)notifyConnect;
- (void)notifyFetchedScript:(JXActivityScript *)script;

@end
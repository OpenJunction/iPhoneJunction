/*
 *  JXXMPPJunctionConnectionListener.cpp
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 10/12/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPJunctionConnectionListener.h"
#import "JXXMPPJunction.h"
#include <gloox/connectionlistener.h>
#include <gloox/gloox.h>

JunctionConnectionListener::JunctionConnectionListener(JXXMPPJunction *junction) : ConnectionListener() {
	this->junction = junction;
}

void JunctionConnectionListener::onConnect() {}

void JunctionConnectionListener::onDisconnect(ConnectionError e) {
	if (e != ConnUserDisconnected) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[(id)junction triggerDisconnect];
		[pool drain];
	}
}

void JunctionConnectionListener::onResourceBindError(const Error *error) {}

void JunctionConnectionListener::onSessionCreateError(const Error *error) {}

bool JunctionConnectionListener::onTLSConnect(const CertInfo &info) { return true; }

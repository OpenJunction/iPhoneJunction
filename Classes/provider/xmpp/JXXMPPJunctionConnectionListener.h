/*
 *  JXXMPPJunctionConnectionListener.h
 *  PartyWare
 *
 *  Created by Alexander Favaro on 8/23/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPJunction.h"

#include <gloox/connectionlistener.h>

class JXXMPPJunctionConnectionListener : public ConnectionListener {
public:
	JXXMPPJunctionConnectionListener(JXXMPPJunction *junction) {
		this->junction = junction;
	}
	void onConnect () {}
	void onDisconnect (ConnectionError e) {
		if (e != ConnUserDisconnected) {
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[junction triggerDisconnect];
			[pool drain];
		}
	}
	bool onTLSConnect (const CertInfo &info) { return true; }
private:
	JXXMPPJunction *junction;
};
/*
 *  JXXMPPJunctionConnectionListener.cpp
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 10/12/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#include "JXXMPPJunctionConnectionListener.h"
#include "JXXMPPJunctionCInterface.h" 
#include <gloox/connectionlistener.h>
#include <gloox/gloox.h>


JXXMPPJunctionConnectionListener::JXXMPPJunctionConnectionListener(void *junction) : ConnectionListener() {
		this->junction = junction;
}

void JXXMPPJunctionConnectionListener::onConnect () {}

void JXXMPPJunctionConnectionListener::onDisconnect (ConnectionError e) {
	junctionOnDisconnect(junction, e);
}
	
bool JXXMPPJunctionConnectionListener::onTLSConnect (const CertInfo &info) { return true; }

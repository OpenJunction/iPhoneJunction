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
#include <gloox/gloox.h>

using namespace gloox;

class JunctionConnectionListener : public ConnectionListener {
	
public:
	JunctionConnectionListener(JXXMPPJunction *provider);
	virtual void onConnect();
	virtual void onDisconnect(ConnectionError e);
	virtual void onResourceBindError(const Error *error);
	virtual void onSessionCreateError(const Error *error);
	virtual bool onTLSConnect(const CertInfo &info);
	
private:
	JXXMPPJunction* junction;
};
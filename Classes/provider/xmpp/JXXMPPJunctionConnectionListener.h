/*
 *  JXXMPPJunctionConnectionListener.h
 *  PartyWare
 *
 *  Created by Alexander Favaro on 8/23/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#include <gloox/connectionlistener.h>
#include <gloox/gloox.h>

using namespace gloox;

class JXXMPPJunctionConnectionListener : public ConnectionListener {
	
public:
	JXXMPPJunctionConnectionListener(void *junction);
	virtual void onConnect ();
	virtual void onDisconnect (ConnectionError e);
	virtual bool onTLSConnect (const CertInfo &info);
	
private:
	void *junction;
};
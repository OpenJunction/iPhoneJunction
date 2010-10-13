/*
 *  JXXMPPProviderConnectionListener.h
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 8/6/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPJunctionProvider.h"
#include <gloox/connectionlistener.h>
#include <gloox/gloox.h>

using namespace gloox;

class ProviderConnectionListener : public ConnectionListener {
	
public:
	ProviderConnectionListener(JXXMPPJunctionProvider *provider);
	virtual void onConnect();
	virtual void onDisconnect(ConnectionError e);
	virtual void onResourceBindError(const Error *error);
	virtual void onSessionCreateError(const Error *error);
	virtual bool onTLSConnect(const CertInfo &info);

private:
	JXXMPPJunctionProvider* provider;
};
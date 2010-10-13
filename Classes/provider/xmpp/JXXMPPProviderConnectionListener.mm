/*
 *  JXXMPPProviderConnectionListener.cpp
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 10/12/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPProviderConnectionListener.h"
#import "JXXMPPJunctionProvider.h"
#include <gloox/connectionlistener.h>
#include <gloox/gloox.h>

ProviderConnectionListener::ProviderConnectionListener(JXXMPPJunctionProvider *provider) : ConnectionListener() {
		this->provider = provider;
}

void ProviderConnectionListener::onConnect() {
	[provider notifyConnect];
}
void ProviderConnectionListener::onDisconnect(ConnectionError e) {}
	
void ProviderConnectionListener::onResourceBindError(const Error *error) {}

void ProviderConnectionListener::onSessionCreateError(const Error *error) {}

bool ProviderConnectionListener::onTLSConnect(const CertInfo &info) { return true; }

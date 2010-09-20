/*
 *  JXXMPPProviderConnectionListener.h
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 8/6/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

class ProviderConnectionListener : public ConnectionListener {
public:
	ProviderConnectionListener(JXXMPPJunctionProvider *provider) {
		this->provider = provider;
	}
	virtual void onConnect() {
		[provider notifyConnect];
	}
	virtual void onDisconnect(ConnectionError e) {
		NSLog(@"XMPP client disconnected");
		[provider notifyConnect];
	}
	virtual void onResourceBindError(const Error *error) {
		NSLog(@"XMPP client resource bind error");
		[provider notifyConnect];
	}
	virtual void onSessionCreateError(const Error *error) {
		NSLog(@"XMPP client session create error");
		[provider notifyConnect];
	}
	bool onTLSConnect(const CertInfo &info) { return true; }
private:
	JXXMPPJunctionProvider *provider;
};
/*
 *  JXXMPPJunctionRoomHandler.h
 *  PartyWare
 *
 *  Created by Alexander Favaro on 8/23/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPJunction.h"
#import "JXActivityScript.h"

#include <gloox/mucroomhandler.h>
#include <gloox/mucroom.h>

class JXXMPPJunctionRoomHandler : public MUCRoomHandler {
public:
	JXXMPPJunctionRoomHandler(JXXMPPJunction *junction) {
		this->junction = junction;
	}
	void handleMUCError(MUCRoom *room, StanzaError error) {
		NSLog(@"MUC error %d\n", error);
	}
	void handleMUCInfo(MUCRoom *room, int features, const string &name, const DataForm *infoForm) {}
	void handleMUCInviteDecline(MUCRoom *room, const JID &invitee, const string &reason) {}
	void handleMUCItems(MUCRoom *room, const Disco::ItemList &items) {}
	void handleMUCMessage(MUCRoom *room, const Message &msg, bool priv);
	void handleMUCParticipantPresence(MUCRoom *room, const MUCRoomParticipant participant, const Presence &presence) {
		// right now we use this to signal that we have joined the room
		// this doesn't work for the room creator though
		if ([junction.activityDescription isActivityCreator]) {
			return;
		}
		notifyJunction();
	}
	bool handleMUCRoomCreation(MUCRoom *room) {
		NSLog(@"Trying to create room");
		[junction.activityDescription setActivityCreator:YES];
		room->requestRoomConfig();
		return false;
	}
	void handleMUCSubject(MUCRoom *room, const string &nick, const string &subject) {}
private:
	JXXMPPJunction *junction;
	void notifyJunction() {
		if ([junction.roomLock tryLockWhenCondition:WAITING]) {
			[junction.roomLock unlockWithCondition:DONE];
		}
	}
};
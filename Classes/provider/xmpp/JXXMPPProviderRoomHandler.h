/*
 *  JXXMPPProviderRoomHandler.h
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 8/6/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

class ProviderRoomHandler : public MUCRoomHandler {
public:
	ProviderRoomHandler(JXXMPPJunctionProvider *provider) {
		this->provider = provider;
	}
	void handleMUCError(MUCRoom *room, StanzaError error) {
		NSLog(@"MUC error");
		[provider notifyFetchedScript:nil];
	}
	void handleMUCInfo(MUCRoom *room, int features, const string &name, const DataForm *infoForm) {
		JXActivityScript *script = nil;
		
		Tag *xml = infoForm->tag();
		Tag *field = xml->findChild("field", "var", "muc#roominfo_description");
		
		if (field == NULL || field->findChild("value") == NULL) {
			NSLog(@"No MUC room description found.");
		} else {
			string desc = field->findChild("value")->cdata();
			NSDictionary *dic = [[NSString stringWithUTF8String:desc.c_str()] JSONValue];
			if (dic == nil) {
				NSLog(@"Could not parse description: %s", desc.c_str());
			} else {
				script = [[JXActivityScript alloc] initWithDictionary:dic];
			}
		}
		
		[provider notifyFetchedScript:[script autorelease]];
	}
	void handleMUCInviteDecline(MUCRoom *room, const JID &invitee, const string &reason) {}
	void handleMUCItems(MUCRoom *room, const Disco::ItemList &items) {}
	void handleMUCMessage(MUCRoom *room, const Message &msg, bool priv) {}
	void handleMUCParticipantPresence(MUCRoom *room, const MUCRoomParticipant participant, const Presence &presence) {}
	bool handleMUCRoomCreation(MUCRoom *room) { return true; }
	void handleMUCSubject(MUCRoom *room, const string &nick, const string &subject) {}
private:
	JXXMPPJunctionProvider *provider;
};
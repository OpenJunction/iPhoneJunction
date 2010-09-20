/*
 *  JXXMPPJunctionConfigHandler.h
 *  PartyWare
 *
 *  Created by Alexander Favaro on 8/23/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPJunction.h"
#import "JSON.h"

#include <gloox/mucroomconfighandler.h>
#include <gloox/dataform.h>
#include <gloox/tag.h>
#include <gloox/mucroom.h>

static BOOL PUBLIC_ROOM = YES;

class JXXMPPJunctionConfigHandler : public MUCRoomConfigHandler {
public:
	JXXMPPJunctionConfigHandler(JXXMPPJunction *junction) {
		this->junction = junction;
	}
	void handleMUCConfigForm(MUCRoom *room, const DataForm &form) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSLog(@"sending config form");
		Tag *xml = form.tag();
		
		Tag *field = xml->findChild("field", "var", "muc#roomconfig_roomdesc");
		NSString *desc = [[junction.activityDescription getDictionary] JSONRepresentation];
		field->findChild("value")->setCData([desc UTF8String]);
		
		field = xml->findChild("field", "var", "muc#roomconfig_whois");
		field->findChild("value")->setCData("moderators");
		
		field = xml->findChild("field", "var", "muc#roomconfig_publicroom");
		field->findChild("value")->setCData(PUBLIC_ROOM? "1" : "0");
		
		DataForm *config = new DataForm(xml);
		config->setType(TypeSubmit);
		room->setRoomConfig(config);
		
		[pool drain];
	}
	void handleMUCConfigList(MUCRoom *room, const MUCListItemList &items, MUCOperation operation) {}
	void handleMUCConfigResult(MUCRoom *room, bool success, MUCOperation operation) {}
	void handleMUCRequest(MUCRoom *room, const DataForm &form) {}
private:
	JXXMPPJunction *junction;
};
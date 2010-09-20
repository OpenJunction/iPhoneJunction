/*
 *  JXXMPPJunctionRoomHandler.cpp
 *  PartyWare
 *
 *  Created by Alexander Favaro on 8/23/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */

#import "JXXMPPJunctionRoomHandler.h"
#import "JXMessageHeader.h"
#import "JXMessageHandler.h"

#import "JSON.h"

#include <gloox/message.h>

void JXXMPPJunctionRoomHandler::handleMUCMessage(MUCRoom *room, const Message &msg, bool priv) {
	if (msg.subtype() != Message::Chat &&
		msg.subtype() != Message::Groupchat) {
		NSLog(@"Ignoring message: %s", msg.body().c_str());
		return;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *body = [NSString stringWithUTF8String:msg.body().c_str()];
	JID from = msg.from();
	
	string jid = room->name();
	jid += "@";
	jid += room->service();
	if (from.full().compare(jid) == 0 && // pretty lame
		[body isEqualToString:@"This room is now unlocked."]) {
		notifyJunction();
	}
	
	NSDictionary *dic = [body JSONValue];
	if (dic == nil) {
		NSLog(@"Could not convert to json: %@", body);
		[pool drain];
		return;
	}
	
	NSDictionary *header = [dic objectForKey:NS_JX];
	if (header) {
		NSString *target = [header objectForKey:@"targetRole"];
		if (target) {
			BOOL forMe = NO;
			for (NSString *role in [junction.owner getRoles]) {
				if ([role isEqualToString:target]) {
					forMe = YES;
					break;
				}
			}
			if (!forMe) {
				[pool drain];
				return;
			}
		}
	}
	
	JXMessageHeader *msgHeader = [[JXMessageHeader alloc] initWithJunction:junction
																   message:dic
																	  from:[NSString stringWithUTF8String:from.resource().c_str()]];
	for (JXMessageHandler *handler in junction.messageHandlers) {
		[handler onMessageReceived:dic header:msgHeader];
	}
	[msgHeader release];
	[pool drain];
}
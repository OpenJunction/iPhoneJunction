/*
 *  JXXMPPJunction-c-interface.h
 *  JXWhiteboard
 *
 *  Created by Alexander Favaro on 10/12/10.
 *  Copyright 2010 Stanford University. All rights reserved.
 *
 */


#ifndef __JXXMPP_JUNCTION_C_INTERFACE_H__
#define __JXXMPP_JUNCTION_C_INTERFACE_H__

#include <gloox/gloox.h>

void junctionOnDisconnect(void* junction, gloox::ConnectionError& e);

#endif
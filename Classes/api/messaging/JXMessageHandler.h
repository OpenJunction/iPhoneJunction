//
//  JXMessageHandler.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXMessageHeader;

@interface JXMessageHandler : NSObject {

}

- (NSArray *)supportedRoles;
- (NSArray *)supportedActors;
- (NSArray *)supportedChannels;

- (BOOL)supportsMessage:(NSDictionary *)message;

//abstract
- (void)onMessageReceived:(NSDictionary *)message
				   header:(JXMessageHeader *)header;

@end

//
//  JXJunctionMaker.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXSwitchboardConfig.h"

@class JXJunctionProvider, JXJunctionMaker;
@class JXJunction, JXJunctionActor, JXActivityScript, JXCast;


@interface JXJunctionMaker : NSObject {
@protected
	JXJunctionProvider *mProvider;
}

+ (JXJunctionMaker *)getInstanceWithSwitchboard:(id<JXSwitchboardConfig>)switchboardConfig;
+ (NSString *)getSessionIDFromURL:(NSURL *)url;
+ (NSString *)getRoleFromInvitation:(NSURL *)url;

- (JXJunction *)newJunctionWithURL:(NSURL *)url
							 actor:(JXJunctionActor *)actor;
- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
										actor:(JXJunctionActor *)actor;
- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
										actor:(JXJunctionActor *)actor
										 cast:(JXCast *)support;
- (void)sendMessage:(NSDictionary *)msg
		 toActivity:(NSURL *)activitySession;
- (JXActivityScript *)getActivityScriptForURL:(NSURL *)url;
- (void)castActorWithDirector:(NSURL *)directorURL
				   invitation:(NSURL *)invitationURL;

//protected
- (JXJunctionProvider *)newProviderWithSwitchboard:(id<JXSwitchboardConfig>)switchboardConfig;

@end

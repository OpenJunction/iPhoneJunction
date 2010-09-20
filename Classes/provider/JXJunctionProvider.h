//
//  JXJunctionProvider.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JXJunctionMaker, JXJunction, JXJunctionActor, JXActivityScript;

@interface JXJunctionProvider : NSObject {
@protected
	JXJunctionMaker *mJunctionMaker;
}

- (BOOL)sendMessage:(NSDictionary *)msg
		 toActivity:(NSURL *)activitySession;
- (void)setJunctionMaker:(JXJunctionMaker *)maker;

//abstract
- (JXJunction *)newJunctionWithURL:(NSURL *)url
						  actor:(JXJunctionActor *)actor;
- (JXJunction *)newJunctionWithActivityScript:(JXActivityScript *)desc
										actor:(JXJunctionActor *)actor;
- (JXActivityScript *)getActivityScriptForURL:(NSURL *)url;

@end

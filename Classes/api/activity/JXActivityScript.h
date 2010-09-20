//
//  JXActivityScript.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXActivityScript : NSObject {
@private
	NSMutableDictionary *mDic;
	
	NSString *sessionID;
	NSString *host;
	
	NSString *activityID;
	NSString *friendlyName;
	
	NSMutableDictionary *roleSpecs;
	BOOL generatedSessionID;
}

@property(getter=isActivityCreator, setter=setActivityCreator) BOOL generatedSessionID;
@property(retain) NSString *sessionID;
@property(retain) NSString *host;
@property(retain) NSString *activityID;
@property(retain) NSString *friendlyName;

- (id)init;
- (id)initWithDictionary:(NSDictionary *)dic;

- (NSString *)toString;
- (NSDictionary *)getDictionary;
- (NSArray *)getRoles;
- (NSDictionary *)getRoleSpec:(NSString *)role;
- (NSDictionary *)getPlatform:(NSString *)platform
					  forRole:(NSString *)role;
- (void)addRole:(NSString *)role
	forPlatform:(NSString *)platform
		   spec:(NSDictionary *)platformSpec;
- (void)addHint:(NSString *)hint toRole:(NSString *)role;
- (void)setRoles:(NSDictionary *)roles;

@end

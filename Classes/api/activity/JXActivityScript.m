//
//  JXActivityScript.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXActivityScript.h"
#import "JSON.H"
#import "JXCategoryDummy.h"


@implementation JXActivityScript

- (id)init {
	return [self initWithDictionary:[NSDictionary dictionary]];
}

- (id)initWithDictionary:(NSDictionary *)dic {
	if (self = [super init]) {
		mDic = [dic retain];
		
		NSString *optString;
		
		if ((optString = [dic objectForKey:@"switchboard"]) || //preferred
			(optString = [dic objectForKey:@"host"])) { //deprecated
			host = [optString retain];
		}
		
		if (optString = [dic objectForKey:@"ad"]) {
			activityID = [optString retain];
		}
		
		if (optString = [dic objectForKey:@"friendlyName"]) {
			friendlyName = [optString retain];
		}
		
		if (optString = [dic objectForKey:@"sessionID"]) {
			sessionID = [optString retain];
			generatedSessionID = NO;
		} else {
			sessionID = [[NSString stringWithUUID] retain];
			generatedSessionID = YES;
		}
		
		roleSpecs = [[dic objectForKey:@"roles"] retain];
	}
	return self;
}

- (void)dealloc {
	[mDic release];
	[sessionID release];
	[host release];
	[activityID release];
	[friendlyName release];
	[roleSpecs release];
	[super dealloc];
}

@synthesize friendlyName;
@synthesize sessionID;
@synthesize host;
@synthesize activityID;

- (void)setFriendlyName:(NSString *)newName {
	[friendlyName release];
	friendlyName = [newName retain];
	[mDic release];
	mDic = nil; //reset
}

- (BOOL)isActivityCreator {
	return generatedSessionID;
}

- (void)setActivityCreator:(BOOL)is {
	generatedSessionID = is;
}

- (void)setActivityID:(NSString *)newID {
	[activityID release];
	activityID = [newID retain];
	[mDic release];
	mDic = nil; //reset
}

- (NSString *)toString {
	return [mDic JSONRepresentation];
}

- (NSDictionary *)getDictionary {
	if (mDic) {
		return mDic;
	}
	
	mDic = [[NSMutableDictionary alloc] init];
	[mDic setObject:sessionID forKey:@"sessionID"];
	[mDic setObject:host forKey:@"switchboard"];
	if (roleSpecs) {
		[mDic setObject:roleSpecs forKey:@"roles"];
	}
	if (friendlyName) {
		[mDic setObject:friendlyName forKey:@"friendlyName"];
	}
	if (activityID) {
		[mDic setObject:activityID forKey:@"ad"];
	}
	
	return mDic;
}

- (NSArray *)getRoles {
	if (roleSpecs) {
		return [roleSpecs allKeys];
	}
	return [NSArray array];
}

- (NSDictionary *)getRoleSpec:(NSString *)role {
	return [roleSpecs objectForKey:role];
}

- (NSDictionary *)getPlatform:(NSString *)platform
					  forRole:(NSString *)role {
	NSDictionary *spec = [self getRoleSpec:role];
	return [[spec objectForKey:@"platforms"] objectForKey:platform];
}

- (void)addRole:(NSString *)role
	forPlatform:(NSString *)platform
		   spec:(NSDictionary *)platformSpec {
	if (roleSpecs == nil) {
		roleSpecs = [[NSMutableDictionary alloc] init];
	}
	if ([roleSpecs objectForKey:role] == nil) {
		[roleSpecs setObject:[NSMutableDictionary dictionary] forKey:role];
	}
	
	NSMutableDictionary *roleDic = [roleSpecs objectForKey:role];
	if ([roleDic objectForKey:@"platforms"] == nil) {
		[roleDic setObject:[NSMutableDictionary dictionary] forKey:@"platforms"];
	}
	
	[[roleDic objectForKey:@"platforms"] setObject:platformSpec forKey:platform];
	
	[mDic release];
	mDic = nil; //reset
}

- (void)addHint:(NSString *)hint toRole:(NSString *)role {
	if (roleSpecs == nil) {
		roleSpecs = [[NSMutableDictionary alloc] init];
	}
	if ([roleSpecs objectForKey:role] == nil) {
		[roleSpecs setObject:[NSMutableDictionary dictionary] forKey:role];
	}
	
	NSMutableDictionary *roleDic = [roleSpecs objectForKey:role];
	if ([roleDic objectForKey:@"hints"] == nil) {
		[roleDic setObject:[NSMutableArray array] forKey:@"hints"];
	}
	
	[[roleDic objectForKey:@"hints"] addObject:hint];
	
	[mDic release];
	mDic = nil; //reset
}

- (void)setRoles:(NSDictionary *)roles {
	[roleSpecs release];
	roleSpecs = [roles retain];
}

@end

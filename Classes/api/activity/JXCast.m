//
//  JXCast.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXCast.h"


@implementation JXCast

- (id)init {
	return [self initWithRoles:[NSArray array] directors:[NSArray array]];
}

- (id)initWithRoles:(NSArray *)roles directors:(NSArray *)directors {
	if (self = [super init]) {
		mRoles = [[NSMutableArray alloc] initWithArray:roles];
		mDirectors = [[NSMutableArray alloc] initWithArray:directors];
	}
	return self;
}

- (void)dealloc {
	[mRoles release];
	[mDirectors release];
	[super dealloc];
}

- (void)addRole:(NSString *)role director:(NSURL *)castingDirector {
	[mRoles addObject:role];
	[mDirectors addObject:castingDirector];
}

- (void)removeAt:(NSUInteger)i {
	[mRoles removeObjectAtIndex:i];
	[mDirectors removeObjectAtIndex:i];
}

- (NSString *)getRoleAt:(NSUInteger)i {
	return [mRoles objectAtIndex:i];
}

- (NSURL *)getDirectorAt:(NSUInteger)i {
	return [mDirectors objectAtIndex:i];
}

- (NSUInteger)size {
	return [mRoles count];
}

@end

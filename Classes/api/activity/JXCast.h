//
//  JXCast.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface JXCast : NSObject {
	NSMutableArray *mRoles;
	NSMutableArray *mDirectors;
}

- (id)init;
- (id)initWithRoles:(NSArray *)roles directors:(NSArray *)directors;

- (void)addRole:(NSString *)role director:(NSURL *)castingDirector;
- (void)removeAt:(NSUInteger)i;

- (NSString *)getRoleAt:(NSUInteger)i;
- (NSURL *)getDirectorAt:(NSUInteger)i;
- (NSUInteger)size;

@end

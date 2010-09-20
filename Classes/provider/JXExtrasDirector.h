//
//  JXExtrasDirector.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/7/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXJunctionExtra.h"

@interface JXExtrasDirector : JXJunctionExtra {
	NSMutableArray *mExtras;
}

- (id)init;

-(void)registerExtra:(JXJunctionExtra *)extra;

@end

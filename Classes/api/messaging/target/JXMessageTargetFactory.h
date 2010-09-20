//
//  JXMessageTargetFactory.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXMessageTarget.h"

@class JXJunction;

@interface JXMessageTargetFactory : NSObject {
@private
	JXJunction *jx;
}

+ (JXMessageTargetFactory *)instanceWithJunction:(JXJunction *)junction;

- (id<JXMessageTarget>)getTarget:(NSString *)target;

@end

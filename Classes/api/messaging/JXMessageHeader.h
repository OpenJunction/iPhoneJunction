//
//  JXMessageHeader.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/6/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXMessageTarget.h"

@class JXJunction;

@interface JXMessageHeader : NSObject {
@public
	NSString *from;
	
@private
	JXJunction *jx;
	NSDictionary *message;
}

- (id)initWithJunction:(JXJunction *)junction
			   message:(NSDictionary *)msg
				  from:(NSString *)fr;

- (id<JXMessageTarget>)getReplyTarget;
- (NSString *)getSender;
- (JXJunction *)getJunction;

@end

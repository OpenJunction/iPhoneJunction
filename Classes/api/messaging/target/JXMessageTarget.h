//
//  JXMessageTarget.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/8/10.
//  Copyright 2010 Stanford University. All rights reserved.
//


@protocol JXMessageTarget <NSObject>

- (void)sendMessage:(NSDictionary *)message;

@end

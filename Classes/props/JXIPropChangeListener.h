//
//  IPropChangeListener.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/30/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JXIPropChangeListener <NSObject>

- (NSString *)type;
- (void)onChange:(id)data;

@end

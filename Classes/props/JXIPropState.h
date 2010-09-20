//
//  IPropState.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/30/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JXIPropState <NSObject, NSCopying>

- (id<JXIPropState>)applyOperation:(NSDictionary *)operation;
- (NSDictionary *)toDictionary;
- (id<JXIPropState>)copy;

@end

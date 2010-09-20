//
//  JXArrayState.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 8/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXIPropState.h"

@interface JXArrayState : NSObject <JXIPropState> {
@protected
	NSMutableArray *items;
	NSUInteger hashcode;
}

@property (nonatomic, readonly) NSMutableArray *items;

- (id)initWithItems:(NSArray *)inItems;
- (id)init;

- (void)addDictionary:(NSDictionary *)dic;
- (void)removeDictionary:(NSDictionary *)dic;
- (void)replaceDictionary:(NSDictionary *)dic1 withDictionary:(NSDictionary *)dic2;
- (void)clear;

//protected
- (void)_updateHash;

@end

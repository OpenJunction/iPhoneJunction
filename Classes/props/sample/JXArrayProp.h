//
//  JXArrayProp.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 8/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXProp.h"

@interface JXArrayProp : JXProp {

}

- (id)initWithName:(NSString *)n replicaName:(NSString *)rn items:(NSArray *)i;
- (id)initWithName:(NSString *)n replicaName:(NSString *)rn;

- (void)addDictionary:(NSDictionary *)dic;
- (void)removeDictionary:(NSDictionary *)dic;
- (void)replaceDictionary:(NSDictionary *)dic1 withDictionary:(NSDictionary *)dic2;
- (void)clear;

- (NSArray *)items;

//protected
- (NSDictionary *)_addOpWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)_removeOpWithDictionary:(NSDictionary *)dic;
- (NSDictionary *)_replaceOp:(NSDictionary *)dic1 withDictionary:(NSDictionary *)dic2;
- (NSDictionary *)_clearOp;

@end

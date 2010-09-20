//
//  JXArrayProp.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 8/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXArrayProp.h"
#import "JXArrayState.h"

@implementation JXArrayProp

- (id)initWithName:(NSString *)n replicaName:(NSString *)rn items:(NSArray *)i {
	return [self initWithName:n state:[[[JXArrayState alloc] initWithItems:i] autorelease]
				  replicaName:rn];
}

- (id)initWithName:(NSString *)n replicaName:(NSString *)rn {
	return [self initWithName:n replicaName:rn items:[NSArray array]];
}

- (void)addDictionary:(NSDictionary *)dic {
	[self addOperation:[self _addOpWithDictionary:dic]];
}

- (void)removeDictionary:(NSDictionary *)dic {
	[self addOperation:[self _removeOpWithDictionary:dic]];
}

- (void)replaceDictionary:(NSDictionary *)dic1 withDictionary:(NSDictionary *)dic2 {
	[self addOperation:[self _replaceOp:dic1 withDictionary:dic2]];
}

- (void)clear {
	[self addOperation:[self _clearOp]];
}

- (NSArray *)items {
	return [(JXArrayState *)[self _state] items];
}

- (id<JXIPropState>)_reifyState:(NSDictionary *)dic {
	NSArray *arr = [dic objectForKey:@"items"];
	return [[[JXArrayState alloc] initWithItems:arr] autorelease];
}

- (NSDictionary *)_addOpWithDictionary:(NSDictionary *)dic {
	NSMutableDictionary *op = [NSMutableDictionary dictionary];
	[op setObject:@"addOp" forKey:@"type"];
	[op setObject:dic forKey:@"item"];
	return op;
}

- (NSDictionary *)_removeOpWithDictionary:(NSDictionary *)dic {
	NSMutableDictionary *op = [NSMutableDictionary dictionary];
	[op setObject:@"deleteOp" forKey:@"type"];
	[op setObject:dic forKey:@"item"];
	return op;
}

- (NSDictionary *)_replaceOp:(NSDictionary *)dic1 withDictionary:(NSDictionary *)dic2 {
	NSMutableDictionary *op = [NSMutableDictionary dictionary];
	[op setObject:@"replaceOp" forKey:@"type"];
	[op setObject:dic1 forKey:@"item1"];
	[op setObject:dic2 forKey:@"item2"];
	return op;
}

- (NSDictionary *)_clearOp {
	NSMutableDictionary *op = [NSMutableDictionary dictionary];
	[op setObject:@"clearOp" forKey:@"type"];
	return op;
}

@end

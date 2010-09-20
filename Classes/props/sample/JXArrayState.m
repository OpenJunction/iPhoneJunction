//
//  JXArrayState.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 8/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXArrayState.h"
#import "JXDictionaryWrapper.h"

@implementation JXArrayState

- (id)initWithItems:(NSArray *)inItems {
	if (self = [super init]) {
		items = [[NSMutableArray allocWithZone:[self zone]] initWithArray:inItems];
		[self _updateHash];
	}
	return self;
}

- (id)init {
	return [self initWithItems:[NSArray array]];
}

- (void)dealloc {
	[items release];
	[super dealloc];
}

@synthesize items;

- (void)addDictionary:(NSDictionary *)dic {
	[items addObject:dic];
}

- (void)removeDictionary:(NSDictionary *)dic {
	[items removeObject:dic];
}

- (void)replaceDictionary:(NSDictionary *)dic1 withDictionary:(NSDictionary *)dic2 {
	[items replaceObjectAtIndex:[items indexOfObject:dic1] withObject:dic2];
}

- (void)clear {
	[items removeAllObjects];
}

- (id<JXIPropState>)applyOperation:(NSDictionary *)operation {
	NSString *type = [operation objectForKey:@"type"];
	if ([type isEqualToString:@"addOp"]) {
		[self addDictionary:(JXDictionaryWrapper *)[operation objectForKey:@"item"]];
	} else if ([type isEqualToString:@"deleteOp"]) {
		[self removeDictionary:(JXDictionaryWrapper *)[operation objectForKey:@"item"]];
	} else if ([type isEqualToString:@"replaceOp"]) {
		[self replaceDictionary:(JXDictionaryWrapper *)[operation objectForKey:@"item1"]
				 withDictionary:(JXDictionaryWrapper *)[operation objectForKey:@"item2"]];
	} else if ([type isEqualToString:@"clearOp"]) {
		[self clear];
	} else {
		NSLog(@"Unrecognized operation: %@", type);
	}
	
	[self _updateHash];
	return self;
}

- (void)_updateHash {
	hashcode = 1;
	for (NSDictionary *dic in items)
		hashcode ^= [dic hash];
}

- (NSUInteger)hash {
	return hashcode;
}

- (NSDictionary *)toDictionary {
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:[NSArray arrayWithArray:items] forKey:@"items"];
	printf("ARRAY: %s", [[items description] UTF8String]);
	return dic;
}

- (id)copyWithZone:(NSZone *)zone {
	NSMutableArray *arr = [NSMutableArray array];
	for (JXDictionaryWrapper *dic in items)
		[arr addObject:[dic copyWithZone:zone]];
	return [[JXArrayState allocWithZone:zone] initWithItems:arr];
}

- (NSString *)description {
	return [items description];
}

@end

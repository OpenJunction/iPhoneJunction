//
//  JXDictionaryWrapper.m
//  iPhoneJunction
//
//  Created by Alexander Favaro on 8/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import "JXDictionaryWrapper.h"


@implementation JXDictionaryWrapper

- (NSUInteger)hash {
	return [(NSNumber *)[self objectForKey:@"id"] unsignedIntegerValue];
}

- (BOOL)isEqual:(id)anObject {
	return [anObject hash] == [self hash];
}

@end

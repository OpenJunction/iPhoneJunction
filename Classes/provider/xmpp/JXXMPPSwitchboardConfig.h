//
//  JXXMPPSwitchboardConfig.h
//  iPhoneJunction
//
//  Created by Alexander Favaro on 7/2/10.
//  Copyright 2010 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JXSwitchboardConfig.h"

@interface JXXMPPSwitchboardConfig : NSObject <JXSwitchboardConfig> {
@protected
	NSString *host;
	NSString *user;
	NSString *password;
@private
	NSTimeInterval connectionTimeout;
}

@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;

@property (nonatomic) NSTimeInterval connectionTimeout;

- (id)initWithHost:(NSString *)host;

//protected
- (NSString *)getChatService;

@end

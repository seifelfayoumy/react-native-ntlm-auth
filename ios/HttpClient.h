//
//  HttpClient.h
//  RNNtlm
//
//  Created by Andrei Radoi on 18/03/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface HttpClient : NSObject

@property (nonatomic) BOOL invalidUsernameOrPassword;

-(AFHTTPSessionManager*) loginWithUrl: (NSString*) url username: (NSString*) username password: (NSString*) password headers : (NSDictionary*) headers;

@end

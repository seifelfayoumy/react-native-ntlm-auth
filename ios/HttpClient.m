//
//  HttpClient.m
//  RNNtlm
//
//  Created by Andrei Radoi on 18/03/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "HttpClient.h"

@implementation HttpClient

-(AFHTTPSessionManager*) loginWithUrl: (NSString*) url username: (NSString*) username password: (NSString*) password headers : (NSDictionary*) headers
{
    AFHTTPSessionManager* client=[[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:url]];

    NSOperationQueue* operationQueue=client.operationQueue;

    [client.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
       switch (status)
       {
           case AFNetworkReachabilityStatusReachableViaWWAN:
           case AFNetworkReachabilityStatusReachableViaWiFi:
               [operationQueue setSuspended:NO];
               break;
               
           case AFNetworkReachabilityStatusNotReachable:
               [operationQueue setSuspended:YES];
               break;
               
           default:
               [operationQueue setSuspended:NO];
               break;
       }
    }];

    client.requestSerializer=[AFHTTPRequestSerializer serializer];
    client.responseSerializer=[AFHTTPResponseSerializer serializer];

    client.requestSerializer.stringEncoding=NSUTF8StringEncoding;
    client.responseSerializer.acceptableContentTypes=nil;
    
    client.requestSerializer.timeoutInterval=30;
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop) {
        [client.requestSerializer setValue:value forHTTPHeaderField:key];
    }];

    __weak HttpClient* wself=self;
    [client setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential **credential)
    {
        if([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodServerTrust) {
            return NSURLSessionAuthChallengePerformDefaultHandling;
        }
        else {
            
            if([[challenge protectionSpace] authenticationMethod] == NSURLAuthenticationMethodNTLM)
            {
               if([challenge previousFailureCount] > 0)
               {
                   // Avoid too many failed authentication attempts which could lock out the user
                   [[challenge sender] cancelAuthenticationChallenge:challenge];
                   wself.invalidUsernameOrPassword=YES;
                   return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
               }
               else
               {
                   NSURLCredential* urlCredential=[NSURLCredential credentialWithUser:username password:password persistence:NSURLCredentialPersistenceForSession];
                   [[challenge sender] useCredential:urlCredential forAuthenticationChallenge:challenge];
                   
                   *credential=urlCredential;
                   return NSURLSessionAuthChallengeUseCredential;
               }
           }
           else
           {
               // Authenticate in other ways than NTLM if desired or cancel the auth like this:
               [[challenge sender] cancelAuthenticationChallenge:challenge];
               wself.invalidUsernameOrPassword=YES;
               return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
           }
        }
    }];
    
    return client;
}

@end


#import "RNNtlm.h"
#import "HttpClient.h"

#define NO_INTERNET_CONNECTION_ERROR_MESSAGE @"NO_INTERNET_CONNECTION_ERROR_MESSAGE"
#define INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE @"INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE"

@implementation RNNtlm

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(NTLMAuthentication)

RCT_EXPORT_METHOD(login : (NSString*)url
                  username : (NSString *)username
                  password : (NSString*) password
                  headers : [(NSDictionary*) headers
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter)
{
    HttpClient* httpClient=[[HttpClient alloc] init];
    [[httpClient loginWithUrl:url username:username password: password headers: headers] GET:@""
            parameters:nil
            success:^(NSURLSessionTask * _Nonnull operation, id  _Nonnull responseData)
     {
         NSMutableDictionary* loginResult=[[NSMutableDictionary alloc] init];
         if ([operation.response respondsToSelector:@selector(allHeaderFields)]) {
             loginResult[@"headers"]=[(id)operation.response allHeaderFields];
         }
         
         NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
         loginResult[@"body"]=jsonDictionary;
         
         resolver(loginResult);
     }
            failure:^(NSURLSessionTask * _Nullable operation, NSError * _Nonnull error)
     {
#define callRejecter(X) rejecter(X, X, error)
         if (error.code==NSURLErrorNotConnectedToInternet)
             callRejecter(NO_INTERNET_CONNECTION_ERROR_MESSAGE);
         else if (httpClient.invalidUsernameOrPassword)
             callRejecter(INVALID_USERNAME_OR_PASSWORD_ERROR_MESSAGE);
         else   
         {
             NSString* message=[NSString stringWithFormat: error.code];
             callRejecter(message);
         }
     }];
}

@end
  

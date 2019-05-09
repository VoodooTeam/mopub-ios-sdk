//
//  VSOperation.m
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import "VSOperation.h"
#import "MPReachability.h"

@implementation VSOperation


#pragma mark - Internal
+ (void)request:(nonnull NSURL *)url
     httpMethod:(VSHTTPMethod)method
     parameters:(nullable NSDictionary *)params
        headers:(nullable NSDictionary<NSString *, NSString *> *)headers
        success:(nullable void (^)(id _Nullable responseObject))success
        failure:(nullable void (^)(NSError *error))failure {
    
 
    MPReachability *reachability = MPReachability.reachabilityForInternetConnection;
    if (reachability.currentReachabilityStatus == MPNotReachable || !url) {
        [VSOperation session:nil failure:failure withError:[NSError errorWithDomain:@"vs.error"
                                                                               code:404
                                                                           userInfo:nil]];
        return;
    }
 
    
    if (method == VSHTTPMethodPost) {
        url = [VSOperation VAURLByAddingGetParameters:params
                                                  url:url];
    }
    
    // Create the URLSession on the default configuration
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // Setup the request with URL
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
 
    
    // Assign http method & content type
    NSString *httpMethod = [VSOperation methodToString:method];
    [urlRequest setHTTPMethod:httpMethod];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // set the headers
    for (NSString *key in headers.allKeys) {
        NSString *value = headers[key];
        if (value) {
            [urlRequest setValue:value forHTTPHeaderField:key];
        }
    }
    
    // Assign request body if needed
    NSData *data = [VSOperation dataWithMethod:method
                                    parameters:params];
    if (data) {
        [urlRequest setHTTPBody:data];
    }
    
    // Create task
    NSURLSessionDataTask *task =
    [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data,
                                                                NSURLResponse *response,
                                                                NSError *error) {
        
        //TODO: move this check to the upper level
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSInteger statusCode = httpResponse.statusCode;
            
            if (statusCode < 200 || statusCode >= 300) {
                [VSOperation session:session
                       failure:failure
                     withError:[NSError errorWithDomain:@"vs.error"
                                                   code:statusCode
                                               userInfo:nil]];
                return;
            }
        }
        
        if (error) {
            [VSOperation session:session
                         failure:failure
                       withError:error];
            
            return;
        }
        
        // for empty data
        if ([VSOperation isEmptyOrPixelTracking:data]) {
            [VSOperation session:nil
                         failure:failure
                       withError:[NSError errorWithDomain:@"vs.error"
                                                                                   code:404
                                                                               userInfo:nil]];
            
            return;
        }
        
        // Serialize json response to object if possible
        NSError *jsonError = nil;
        id responseObj = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:&jsonError];
        if (!jsonError) {
           [VSOperation session:session success:success withObject:responseObj];
            return;
        }else {
            [VSOperation session:session
                         failure:failure
                       withError:jsonError];
        }
        
         [VSOperation session:session success:success withObject:data];
    }];
    
    // Fire the request
    [task resume];
}


+ (nonnull NSURL *)VAURLByAddingGetParameters:(nullable NSDictionary *)parameters
                                          url:(NSURL *)url{
    
    if (parameters.count == 0) {
        return url;
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithString:url.absoluteString];
    NSMutableArray *queryItems = [NSMutableArray array];
    
    for (NSString *key in parameters) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:parameters[key]]];
    }
    
    components.queryItems = queryItems;
    return components.URL;
}


+ (NSString *)methodToString:(VSHTTPMethod)method {
    switch (method) {
        case VSHTTPMethodPost:
            return @"POST";
        default:
            return @"GET";
    }
}


#pragma Data Serialization
+ (nullable NSData *)dataWithMethod:(VSHTTPMethod)method
                         parameters:(nullable NSDictionary *)params {
    
    if (!params || [params count] == 0) {
        return nil;
    }
    
    if (method == VSHTTPMethodGet) {
        // get method params are url encoded
        // nil should be sent as body
        return nil;
    }
    
    // Convert post params to JSON data
    NSData *data = [NSJSONSerialization dataWithJSONObject:params
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    return data;
}

+ (BOOL)isEmptyOrPixelTracking:(nullable NSData *)data {
    
    if (!data) {
        return YES;
    }
    
    return NO;
}


#pragma session blocks
+ (void)session:(NSURLSession *)session failure:(nullable void (^)(NSError *error ))failure
      withError:(NSError *)error {
    
    if (session) {
        [session invalidateAndCancel];
    }
    
    if (!failure) {
        return;
    }
    
    
    // safe call
    if (NSThread.currentThread.isMainThread) {
         failure(error);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
         failure(error);
        });
    }
    
}


+ (void)session:(nullable NSURLSession *)session
        success:(nullable void (^)(id _Nullable responseObject))success
     withObject:(nullable id)responseObject {
    
    if (session) {
        [session invalidateAndCancel];
    }
    
    if (!success) {
        return;
    }
    
    if (NSThread.currentThread.isMainThread) {
        success(responseObject);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
        success(responseObject);
        });
    }
}

@end

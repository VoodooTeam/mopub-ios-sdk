//
//  VSOperation.h
//  MoPubSDK
//
//  Created by sarra_srairi on 03/05/2019.
//  Copyright © 2019 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A representation of the supported HTTP methods
 */
typedef enum VSHTTPMethod {
    VSHTTPMethodGet,
    VSHTTPMethodPost
} VSHTTPMethod;

@interface VSOperation : NSObject

+ (void)request:(nonnull NSURL *)url
     httpMethod:(VSHTTPMethod)method
     parameters:(nullable NSDictionary *)params
        headers:(nullable NSDictionary<NSString *, NSString *> *)headers
        success:(nullable void (^)(id _Nullable responseObject))success
        failure:(nullable void (^)(NSError * _Nullable error))failure;
@end



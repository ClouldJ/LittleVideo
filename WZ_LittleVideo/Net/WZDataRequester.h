//
//  WZDataRequester.h
//  v2_jdrn
//
//  Created by 赵鹏飞 on 2018/12/12.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommunicationKeyDefinition.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^WZNotReachableCallBack)(NSDictionary *response);

@interface WZDataRequester : NSObject <NSURLSessionDelegate,NSURLSessionDownloadDelegate,NSURLSessionDataDelegate> {
  NSInteger retryRequestCout;
  Class _originalClass;
  NSInteger totalDataLength;
}

@property (nonatomic, assign) DataRequestType        requestType;
@property (nonatomic, strong, null_resettable) NSMutableData          *reciveData;
@property (nonatomic, strong) WZNotReachableCallBack notReachableCallBack;

@property (nonatomic, strong, nullable) NSDictionary        *currentParams;
@property (nonatomic, strong, nullable) NSData            *currentPostData;
@property (nonatomic, strong, nullable) NSString               *currentUrl;
@property (nonatomic, strong, nullable) NSURLRequest       *currentRequest;

-(void)sendRequestSuccess:(void(^)(NSDictionary *response))responseCallBack;

@end

NS_ASSUME_NONNULL_END

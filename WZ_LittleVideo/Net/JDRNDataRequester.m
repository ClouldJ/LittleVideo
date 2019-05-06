//
//  JDRNDataRequester.m
//  v2_jdrn
//
//  Created by 赵鹏飞 on 2018/12/12.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "JDRNDataRequester.h"

@implementation JDRNDataRequester
#pragma mark 包版本检查
-(void)homeList:(NSDictionary *)param withResponse:(void (^)(NSDictionary * _Nonnull))responseCallBack {

  self.requestType = JDRN_HOTUPDATE_TYPE;
  
  self.currentParams = param;

  self.currentUrl = @"https://serv.jaadee.net/v/smallVideo/list";
  
  [self sendRequestSuccess:^(NSDictionary * _Nonnull response) {
    responseCallBack(response);
  }];
  
}


#pragma mark 云信登录
-(void)JDRN_NTELogIn:(NSDictionary *)param withResponse:(void(^)(NSDictionary *response))responseCallBack {
  
  self.requestType = JDRN_NTELOGIN_TYPE;
  
  self.currentParams = param;
  
  self.currentUrl = [NSString stringWithFormat:@"%@%@",BASE_URL,JDRN_REGISTERNTESCHAT_URL];
  
  [self sendRequestSuccess:^(NSDictionary * _Nonnull response) {
    responseCallBack(response);
  }];
  
}

@end

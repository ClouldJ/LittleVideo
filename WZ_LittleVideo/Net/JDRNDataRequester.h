//
//  JDRNDataRequester.h
//  v2_jdrn
//
//  Created by 赵鹏飞 on 2018/12/12.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "WZDataRequester.h"

NS_ASSUME_NONNULL_BEGIN

@interface JDRNDataRequester : WZDataRequester

-(void)homeList:(NSDictionary *)param withResponse:(void(^)(NSDictionary *response))responseCallBack;


@end

NS_ASSUME_NONNULL_END

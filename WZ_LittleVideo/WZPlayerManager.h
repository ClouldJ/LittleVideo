//
//  WZPlayerManager.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/8.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WZ_Player;
NS_ASSUME_NONNULL_BEGIN

@interface WZPlayerManager : NSObject

-(WZ_Player *)wz_playerWithUrl:(NSString *)url;

-(void)play;

@end

NS_ASSUME_NONNULL_END

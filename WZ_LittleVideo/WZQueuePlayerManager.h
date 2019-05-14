//
//  WZQueuePlayer.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/13.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface WZQueuePlayerManager : NSObject

+(WZQueuePlayerManager *)defaultManager;

/**
 * param: items *
 * 播放队列数据源 *
 */
-(AVQueuePlayer *)playerWithSource:(NSMutableArray *)source;


@end

NS_ASSUME_NONNULL_END

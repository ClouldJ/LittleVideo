//
//  WZQueuePlayer.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/14.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WZQueuePlayerItemDirectionNone,
    WZQueuePlayerItemDirectionNext,                                 //向下播
    WZQueuePlayerItemDirectionPrevious,                             //向上播
} WZQueuePlayerPlayDirection;

@interface WZQueuePlayer : AVQueuePlayer

/**
 保存此播放队列中所有播放过，以及未播放过的媒体资源(AVPlayerItem) 必须在初始化前做好设置，以及数据源更替
 */
@property (nonatomic, strong) NSMutableArray *wz_items;

/**
 当前播放器资源索引
 */
@property (nonatomic, assign) NSInteger currentIndex;

/**
 标记当前播放器的播放方向
 */
@property (nonatomic, assign) WZQueuePlayerPlayDirection currentDirection;          

/**
 自定义队列长度
 default queueLength = 5;
 */
@property (nonatomic, assign) NSInteger queueLength;


/**
 设置播放器播放方向

 @param direction 播放器播放方向
 @param completion 完成设置以后的回调操作
 */
-(void)setPlayerPlayDirection:(WZQueuePlayerPlayDirection)direction completionHandler:(void(^)(void))completion;


@end

NS_ASSUME_NONNULL_END

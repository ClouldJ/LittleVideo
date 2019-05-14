//
//  WZQueuePlayer.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/13.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "WZQueuePlayerManager.h"
#import "CTMediaModel.h"

@interface WZQueuePlayerManager () <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) AVQueuePlayer *queuePlayer;               //队列播放器

@property (nonatomic, strong) NSMutableArray *items;                    //播放源数组
@property (nonatomic ,strong) id             timeObserver;               //视频播放器周期性调用的观察者


@end

@implementation WZQueuePlayerManager

+(WZQueuePlayerManager *)defaultManager {
    static dispatch_once_t once;
    static WZQueuePlayerManager *manager;
    dispatch_once(&once, ^{
        manager = [WZQueuePlayerManager new];
    });
    return manager;
}

-(AVQueuePlayer *)playerWithSource:(NSMutableArray *)source {
    for (CTMediaModel *mm in source) {
        AVURLAsset *av = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:mm.url] options:nil];
        [av.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:av];
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
        
        [self.items addObject:item];
        
    }
    
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:self.items];
    self.queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self addProgressObserver];
    
    return self.queuePlayer;
}
// 给AVQueuePlayer添加周期性调用的观察者，用于更新视频播放进度
-(void)addProgressObserver{
    __weak __typeof(self) weakSelf = self;
    //AVPlayer添加周期性回调观察者，一秒调用一次block，用于更新视频播放进度
    self.timeObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //获取播放队列中当前播放源的状态    TODO:下个播放器的状态
        if(weakSelf.queuePlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            //获取当前播放时间
            float current = CMTimeGetSeconds(time);
            //获取视频播放总时间
            float total = CMTimeGetSeconds([weakSelf.queuePlayer.currentItem duration]);
            //重新播放视频
            if(total == current) {
                [weakSelf replay];
            }
            //更新视频播放进度方法回调
            
        }
    }];
}

-(void)replay{
    
}

#pragma mark 懒加载
-(NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}
#pragma mark AVAssetResourceLoaderDelegate

@end

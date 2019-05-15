//
//  WZQueuePlayer.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/14.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "WZQueuePlayer.h"

@interface WZQueuePlayer ()



@end

@implementation WZQueuePlayer

-(void)setPlayerPlayDirection:(WZQueuePlayerPlayDirection)direction completionHandler:(void (^)(void))completion {
    if (self.currentDirection == WZQueuePlayerItemDirectionNone) {
        //初始化后无播放状态，不做操作
        [super advanceToNextItem];
    }else{
        if (direction == self.currentDirection && direction == WZQueuePlayerItemDirectionNext) {
            //待处理播放器方向与当前播放器方向一致，不做操作
            [super advanceToNextItem];
        }else{
            //当前播放器方向与待处理播放器方向不一致
            switch (direction) {
                case WZQueuePlayerItemDirectionNext:
                    //以wz_items为准向下加载播放器资源
                {
                    [self changeItemsWithDirectionNext:YES];
                }
                    break;
                case WZQueuePlayerItemDirectionPrevious:
                    //以wz_items为准向上加载播放器资源
                {
                    [self changeItemsWithDirectionNext:NO];
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    self.currentDirection = direction;
    
}

-(void)changeItemsWithDirectionNext:(BOOL)isNext {
    
    NSMutableArray *stagingItems = [NSMutableArray arrayWithArray:self.wz_items];
    
    //移除当前播放队列中所有源
    [self pause];
    [self seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self removeAllItems];
    
    NSInteger total;
    if (isNext) {
        //向下处理数据,根据当前索引在wz_items中向下获取
        // 防止数组越界
        total = self.currentIndex + self.queueLength;
        if (total>self.wz_items.count - 1) {
            total = self.wz_items.count - 1;
        }
        
        for (NSInteger i = self.currentIndex; i<total; i++) {
            NSLog(@"加入的shuj:%ld",i);
            [self insertItem:stagingItems[i] afterItem:nil];
        }
        
    }else {
        //向上处理数据,根据当前索引在wz_items中向上获取
        //重新添加源
        //如果self.current = 0,则默认为刷新当前页，暂又外部处理
        for (NSInteger i = self.currentIndex > 0 ? self.currentIndex - 1:0; i<self.currentIndex + self.queueLength - 1; i++) {
            [self insertItem:stagingItems[i] afterItem:nil];
        }
    }
    
    [self seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self play];
}


/**
 重写insert方法，防止数组越界

 @param item 待添加的item
 @param afterItem 在哪一个item之后
 */
-(void)insertItem:(AVPlayerItem *)item afterItem:(AVPlayerItem *)afterItem {
    [super insertItem:item afterItem:afterItem];
    
    
}

#pragma mark 懒加载
-(NSInteger)queueLength {
    _queueLength = 5;
    return _queueLength;
}

-(NSMutableArray *)wz_items {
    if (!_wz_items) {
        _wz_items = [NSMutableArray array];
    }
    return _wz_items;
}

@end

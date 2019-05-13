//
//  Presenter_PlayViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "Presenter_PlayViewController.h"
#import "VideoCell.h"
#import "CTMediaModel.h"

#import "JDRNDataRequester.h"

#import "CTMediaModel.h"
#import "AVPlayerManager.h"
#import "WZPlayer.h"

@interface Presenter_PlayViewController () <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) CTMediaModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) JDRNDataRequester *netWork;
@property (nonatomic, strong) NSMutableArray *dataSource;


@property (nonatomic, strong) AVQueuePlayer *queuePlayer;
@property (nonatomic ,strong) id                   timeObserver;            //视频播放器周期性调用的观察者
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) NSInteger shouldAdvanceToNextItemIndex;
@property (nonatomic, assign) BOOL isGestureUp;           //YES 向上；NO 向下
@end

@implementation Presenter_PlayViewController

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_H;
}

-(void)reloadTableView:(UITableView *)tableView withModel:(NSMutableArray *)modelArray atIndex:(NSInteger)index{
    self.modelArray = [NSMutableArray arrayWithArray:modelArray];
    self.currentIndex = index;
    self.pageIndex = 1;         //待传入对应page信息
    self.tableView = tableView;
    
    self.items = [NSMutableArray array];
    
    for (CTMediaModel *mm in modelArray) {
        AVURLAsset *av = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:mm.url] options:nil];
        [av.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:av];
        [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
        
        [self.items addObject:item];
        
    }
    
    self.queuePlayer = [AVQueuePlayer queuePlayerWithItems:self.items];
    self.queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    [self addProgressObserver];
    [tableView reloadData];

}

-(void)addProgressObserver{
    __weak __typeof(self) weakSelf = self;
    //AVPlayer添加周期性回调观察者，一秒调用一次block，用于更新视频播放进度
    _timeObserver = [self.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if(self.queuePlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            //获取当前播放时间
            float current = CMTimeGetSeconds(time);
            
            if (current>0) {
                //隐藏
                VideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
                [cell startLoadingPlayItemAnim:NO];
                [cell setCoverHidden:YES];
            }
            
            //获取视频播放总时间
            float total = CMTimeGetSeconds([weakSelf.queuePlayer.currentItem duration]);
            //重新播放视频
            if(total == current) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.queuePlayer.currentItem seekToTime:kCMTimeZero];
                    [weakSelf.queuePlayer play];
                });
            }
            
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    VideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if([keyPath isEqualToString:@"status"]) {
        
        switch (self.queuePlayer.currentItem.status) {
            case AVPlayerItemStatusUnknown:
            {
                [cell startLoadingPlayItemAnim:YES];
                NSLog(@"播放器状态变化:Unknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                
            }
                NSLog(@"播放器状态变化:ReadyToPlay");
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"播放器状态变化:Failed");
                break;
            default:
                break;
        }
        
    }else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ddCell"];
    if (!cell) {
        cell = [[VideoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ddCell" withQueuePlayer:self.queuePlayer];
    }
    if (self.modelArray.count>0) {
        CTMediaModel *model = self.modelArray[indexPath.row];
        [cell cellWithModel:model withPlayerItem:nil];
        [cell setCoverHidden:NO];
        [cell startLoadingPlayItemAnim:YES];
        if (indexPath.row == self.currentIndex) {
            [self.queuePlayer play];
        }
        
    }
    return cell;
}

#pragma ScrollView delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        //UITableView禁止响应其他滑动手势
        scrollView.panGestureRecognizer.enabled = NO;
        
        if(translatedPoint.y < -50 && self.currentIndex < (self.modelArray.count - 1)) {
            self.currentIndex ++;   //向下滑动索引递增
            
            //标记滑动
            if (self.isGestureUp) {
                self.isGestureUp = NO;
            }
            
            if ([self.queuePlayer.items indexOfObject:self.items[self.currentIndex]] == 1) {
                //判断下一个播放源是否在播放器队列,如果在播放器队列则调用系统的播放下一曲方法
                [UIView animateWithDuration:0.15
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut animations:^{
                                        //UITableView滑动到指定cell
                                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                    } completion:^(BOOL finished) {
                                        //UITableView可以响应其他滑动手势
                                        [self.queuePlayer advanceToNextItem];
                                        scrollView.panGestureRecognizer.enabled = YES;
                                    }];
                
            }else{
                //不在播放源，则replaceItem，并重启currentItem播放源
                [UIView animateWithDuration:0.15
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseOut animations:^{
                                        //UITableView滑动到指定cell
                                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                    } completion:^(BOOL finished) {
                                        //UITableView可以响应其他滑动手势
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.queuePlayer pause];
                                            [self.queuePlayer replaceCurrentItemWithPlayerItem:self.items[self.currentIndex]];
                                            [self.queuePlayer.currentItem seekToTime:kCMTimeZero];
                                            [self.queuePlayer play];
                                            scrollView.panGestureRecognizer.enabled = YES;
                                        });
                                    }];
            }
            
        }
        if(translatedPoint.y > 50 && self.currentIndex >= 0) {
            if (self.currentIndex == 0) {
                return ;
            }
            
            //判断滑动方向，并在第一次向上滑动的时候做当前item标记
            if (!self.isGestureUp) {
                self.isGestureUp = YES;
                self.shouldAdvanceToNextItemIndex = self.currentIndex;
            }
            
            self.currentIndex --;   //向上滑动索引递减
            [UIView animateWithDuration:0.15
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut animations:^{
                                    //UITableView滑动到指定cell
                                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                } completion:^(BOOL finished) {
                                    //UITableView可以响应其他滑动手势
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.queuePlayer pause];
                                        [self.queuePlayer replaceCurrentItemWithPlayerItem:self.items[self.currentIndex]];
                                        [self.queuePlayer.currentItem seekToTime:kCMTimeZero];
                                        [self.queuePlayer play];
                                        scrollView.panGestureRecognizer.enabled = YES;
                                        NSLog(@"上一个播放器位置:%ld",[self.queuePlayer.items indexOfObject:self.items[self.currentIndex+2]]);
                                    });
                                }];
        }
        

        if (self.currentIndex >= self.modelArray.count - 2) {
            //准备加入新数据
            [self loadMoreVideoWithPage:self.pageIndex + 1];
        }
        NSLog(@"当前页面:%ld",self.currentIndex);
        
    });
}

-(void)reloadDatas:(NSMutableArray *)array {
    __weak __typeof(self) wself = self;
    dispatch_main_async_safe(^{
        [wself.tableView beginUpdates];
        for (NSInteger i = 0; i<array.count; i++) {
            if (![wself.modelArray containsObject:array[i]]) {
                [wself.modelArray addObject:array[i]];
            }
        }
        
        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
        for(NSInteger row = 1; row<wself.modelArray.count; row++) {
            NSLog(@"加入的数据:%ld",(long)row);
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [indexPaths addObject:indexPath];
        }
        [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
        [wself.tableView endUpdates];
    });
    
}

-(void)loadMoreVideoWithPage:(NSInteger)page {
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    [dic setObject:@"81871" forKey:@"uid"];
    [dic setObject:@"5" forKey:@"pageSize"];
    [dic setObject:[NSString stringWithFormat:@"%ld",page] forKey:@"currPage"];
    [dic setObject:@"recommend" forKey:@"listName"];
    
    __weak __typeof(self) wself = self;
    [self.netWork homeList:dic withResponse:^(NSDictionary * _Nonnull response) {
        if ([response[@"code"] integerValue] == 0) {
            NSArray *info = [NSArray arrayWithArray:response[@"info"]];
            NSArray *datas = [CTMediaModel mj_objectArrayWithKeyValuesArray:info];
            for (NSInteger i = 0; i < datas.count; i++) {
                
                NSDictionary *dic = [info objectAtIndex:i];
                CTMediaModel *model = [datas objectAtIndex:i];
                
                NSDictionary *storeInfo = [dic objectForKey:@"storeInfo"];
                model.storeInfo = [CTMediaStoreModel mj_objectWithKeyValues:storeInfo];
                
                NSDictionary *goodsInfo = [dic objectForKey:@"goodsInfo"];
                model.goodsId = [goodsInfo objectForKey:@"goodsId"];
                model.price = [NSString stringWithFormat:@"%@",[goodsInfo objectForKey:@"price"]];
                
                NSDictionary *specificationInfo = [dic objectForKey:@"specificationInfo"];
                CGFloat w = [[specificationInfo objectForKey:@"width"] floatValue];
                CGFloat h = [[specificationInfo objectForKey:@"height"] floatValue];
                CGFloat defaultW = ((SCREEN_W - 34.0)/2.0);
                model.logoSize = CGSizeMake(defaultW, defaultW * h / w);
                model.duration = [[specificationInfo objectForKey:@"duration"] integerValue];
                //            model.nameLayout = [self layoutGoodsTitle:model.title inWidth:defaultW - 12];
                //            model.height = model.logoSize.height + 34 + model.nameLayout.textBoundingSize.height;
                
                NSDictionary *statisticsInfo = [dic objectForKey:@"statisticsInfo"];
                model.attentionNum = [NSString stringWithFormat:@"%@",[statisticsInfo objectForKey:@"attentionNum"]];
                model.likeNum = [NSString stringWithFormat:@"%@",[statisticsInfo objectForKey:@"likeNum"]];
                model.shareNum = [NSString stringWithFormat:@"%@",[statisticsInfo objectForKey:@"shareNum"]];
            }
            
            self.pageIndex++;
 
            dispatch_main_async_safe(^{
                [wself.tableView beginUpdates];
                [wself.modelArray addObjectsFromArray:datas];
                NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
                for(NSInteger row = wself.modelArray.count - datas.count; row<wself.modelArray.count; row++) {
                    NSLog(@"加入的数据:%ld",(long)row);
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [indexPaths addObject:indexPath];
                }
                [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
                
                //加入新的items
                for (CTMediaModel *mm in datas) {
                    AVURLAsset *av = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:mm.url] options:nil];
                    [av.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
                    
                    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:av];
                    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
                    
                    BOOL isCanAdd = [self.queuePlayer canInsertItem:item afterItem:self.items[self.items.count - 1]];
                    if (isCanAdd) {
                        [self.queuePlayer insertItem:item afterItem:self.items[self.items.count - 1]];
                        [self.items addObject:item];
                        NSLog(@"添加了新的播放源:%@",mm.url);
                    }
                    
                }
                
                [wself.tableView endUpdates];
            });
            
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",response[@"msg"]]];
            [SVProgressHUD dismissWithDelay:1.0f];
        }
        
    }];
    
}

#pragma mark 懒加载
-(JDRNDataRequester *)netWork {
    if (!_netWork) {
        _netWork = [[JDRNDataRequester alloc] init];
    }
    return _netWork;
}

-(NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end

//
//  VideoCell.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayerView;
@class CTMediaModel;

typedef void (^OnPlayerReady)(void);
NS_ASSUME_NONNULL_BEGIN

@interface VideoCell : UITableViewCell

@property (nonatomic, strong) AVPlayerView     *playerView;
@property (nonatomic, assign) BOOL isPlayerReady;
@property (nonatomic, strong) OnPlayerReady    onPlayerReady;

-(void)cellWithModel:(CTMediaModel *)model;

- (void)startDownloadBackgroundTask;
- (void)startDownloadHighPriorityTask;
- (void)play;
- (void)pause;
- (void)replay;

@property (nonatomic, strong) AVPlayerLayer *player;

-(void)startLoadingPlayItemAnim:(BOOL)isStart;

-(void)setCoverHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END

//
//  WZPlayer.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/7.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WZPlayerDelegate <NSObject>

@required
//播放进度更新回调方法
-(void)onProgressUpdate:(CGFloat)current total:(CGFloat)total;

//播放状态更新回调方法
-(void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status;

@end

@interface WZPlayer : NSObject

+ (WZPlayer *)defaultPlayer;

@property(nonatomic, weak) id<WZPlayerDelegate> delegate;

/**
 * 播放器相关 *
 */
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/**
 * 播放器相关方法 *
 */
-(void)setPlayerWithUrl:(NSString *)url;

-(void)play;
-(void)pause;
-(void)rePlayWithUrl:(NSString *)url;

-(void)cancelLoading;
- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground;

@end

NS_ASSUME_NONNULL_END

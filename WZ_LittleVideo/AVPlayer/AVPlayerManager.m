//
//  AVPlayerManager.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AVPlayerManager.h"

@interface AVPlayerManager()

@end

@implementation AVPlayerManager

+ (AVPlayerManager *)shareManager {
    static dispatch_once_t once;
    static AVPlayerManager *manager;
    dispatch_once(&once, ^{
        manager = [AVPlayerManager new];
    });
    return manager;
}

+ (void)setAudioMode {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _playerArray = [NSMutableArray array];
        _playLayerArray = [NSMutableArray array];
    }
    
    return self;
}
- (void)play:(AVPlayer *)player {
    [_playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
    if(![_playerArray containsObject:player]) {
        [_playerArray addObject:player];
    }
    [player play];
}

-(void)play_layer:(AVPlayerLayer *)playerLayer {
    [_playLayerArray enumerateObjectsUsingBlock:^(AVPlayerLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.player pause];
    }];
    
    if (![_playLayerArray containsObject:playerLayer]) {
        [_playLayerArray addObject:playerLayer];
    }
    
    [playerLayer.player play];
}

- (void)pause:(AVPlayer *)player {
    if([_playerArray containsObject:player]) {
        [player pause];
    }
}

-(void)pause_layer:(AVPlayerLayer *)playerLayer {
    if ([_playLayerArray containsObject:playerLayer]) {
        [playerLayer.player pause];
    }
}

- (void)pauseAll {
    [_playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
}

- (void)replay:(AVPlayer *)player {
    [_playerArray enumerateObjectsUsingBlock:^(AVPlayer * obj, NSUInteger idx, BOOL *stop) {
        [obj pause];
    }];
    if([_playerArray containsObject:player]) {
        [player seekToTime:kCMTimeZero];
        [self play:player];
    }else {
        [_playerArray addObject:player];
        [self play:player];
    }
}

-(void)replay_layer:(AVPlayerLayer *)playerLayer {
    [_playLayerArray enumerateObjectsUsingBlock:^(AVPlayerLayer * obj, NSUInteger idx, BOOL *stop) {
        [obj.player pause];
    }];
    if([_playLayerArray containsObject:playerLayer]) {
        [playerLayer.player seekToTime:kCMTimeZero];
        [self play_layer:playerLayer];
    }else {
        [_playLayerArray addObject:playerLayer];
        [self play_layer:playerLayer];
    }
}

- (void)removeAllPlayers {
    [_playerArray removeAllObjects];
}

-(void)stopAll {
    [_playLayerArray enumerateObjectsUsingBlock:^(AVPlayerLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.player pause];
        [obj removeFromSuperlayer];
        obj.player = nil;
    }];
//    [_playLayerArray removeAllObjects];
}


@end

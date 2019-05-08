//
//  WZPlayerManager.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/8.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "WZPlayerManager.h"
#import "WZ_Player.h"

@interface WZPlayerManager () <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) WZ_Player *player;
@property (nonatomic, strong) AVPlayerItem *player_item;

@end

@implementation WZPlayerManager

-(WZ_Player *)wz_playerWithUrl:(NSString *)url {
    AVURLAsset *avasset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:url] options:nil];
    
    [avasset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    
    self.player_item = [AVPlayerItem playerItemWithAsset:avasset];
    
    [self.player_item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];

    
    self.player = [[WZ_Player alloc] initWithPlayerItem:self.player_item];
    
    return self.player;
}

-(void)play {
    [self.player play];
}

-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"ddd     %@",loadingRequest.request.URL);
    return NO;
}

// 响应KVO值变化的方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"status"]) {
        switch (self.player_item.status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"播放失败");
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准备播放");
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"播放状态未知");
                break;
            default:
                break;
        }
    }else{
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)dealloc {
    [self.player_item removeObserver:self forKeyPath:@"status"];
}

@end

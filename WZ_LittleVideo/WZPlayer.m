//
//  WZPlayer.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/7.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "WZPlayer.h"

@interface WZPlayer ()

@property (nonatomic, strong) VIResourceLoaderManager *resourceLoaderManager;

@end

@implementation WZPlayer

-(void)postDC{
    NSURL *url = [NSURL URLWithString:@"https://mvvideo5.meitudata.com/571090934cea5517.mp4"];
    VIResourceLoaderManager *resourceLoaderManager = [VIResourceLoaderManager new];
    self.resourceLoaderManager = resourceLoaderManager;
    AVPlayerItem *playerItem = [resourceLoaderManager playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
}

@end

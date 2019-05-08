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
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:@"https://res.jaadee.net/appdir/ios/live/video/2019-05-08/20190508092710704-205814.mp4"]];
    NSArray *keys = @[@"tracks",
                      @"playable",
                      @"duration"];
    
    __weak typeof(asset) weakAsset = asset;
    __weak typeof(self) weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // check the keys
            for (NSString *key in keys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [weakAsset statusOfValueForKey:key error:&error];
                
                switch (keyStatus) {
                    case AVKeyValueStatusFailed:{
                        // failed
                        NSLog(@"fail");
                        break;
                    }
                    case AVKeyValueStatusLoaded:{
                        // success
                        NSLog(@"success");
                        break;
                    }case AVKeyValueStatusCancelled:{
                        // cancelled
                        NSLog(@"cancled");
                        break;
                    }
                    default:
                        NSLog(@"unknown");
                        break;
                }
            }
            
            // check playable
            if (!weakAsset.playable) { // 不能播放
                NSLog(@"not to play");
                return;
            }
            
        });
    }];
}

#pragma mark 根据url获取视频第一帧图片
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {  AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    NSParameterAssert(asset);
    
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    
    CFTimeInterval thumbnailImageTime = time;
    
    NSError *thumbnailImageGenerationError = nil;
    
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        
         NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
    
}

@end

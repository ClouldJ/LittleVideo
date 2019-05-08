//
//  VideoDownloadManager.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/6.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoDownloadManager : NSObject

+(VideoDownloadManager *)shareManager;

@property (nonatomic, strong) NSMutableArray *indexs;

-(void)startDownloadTaskWithModel:(NSMutableArray *)modelArray;

@end

NS_ASSUME_NONNULL_END

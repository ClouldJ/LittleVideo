//
//  WZDataDownloadManager.h
//  v2_jdrn
//
//  Created by 赵鹏飞 on 2018/12/12.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "WZDataRequester.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^WZDownloadProgressCallBack)(CGFloat downloadProgress);
typedef NSURL *(^WZDownloadDestinationCallBack)(NSURL *targetPath, NSURLResponse * _Nullable response);
typedef void(^WZDownloadFinishedCallBack)(NSURL * _Nullable filePath,NSError * _Nullable error);

@interface WZDataDownloadManager : WZDataRequester

@property (nonatomic, copy) NSString *md5;        //zip包md5码

@property (nonatomic, copy) NSString *name;       //更新包名称(标识)

@property (nonatomic, copy) NSString *url;        //更新包下载地址

@property (nonatomic, strong) WZDownloadProgressCallBack progressBlock;
@property (nonatomic, strong) WZDownloadFinishedCallBack finishBlock;

@property (nonatomic, strong) WZDownloadDestinationCallBack destinationBlock;

-(NSURLSessionDownloadTask *)downloadTaskProgress:(WZDownloadProgressCallBack)downloadProgressBlock destination:(WZDownloadDestinationCallBack)destination completionHandler:(WZDownloadFinishedCallBack)completionHandler;

@end

NS_ASSUME_NONNULL_END

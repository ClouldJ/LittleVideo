//
//  VideoDownloadManager.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/6.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "VideoDownloadManager.h"
#import "CTMediaModel.h"
#import "WebCacheHelpler.h"
#import "WZDataDownloadManager.h"
#import "objc/runtime.h"
#import <CommonCrypto/CommonDigest.h>

@interface VideoDownloadManager ()

@property (nonatomic, strong) WebCombineOperation  *combineOperation;
@property (nonatomic, strong) NSMutableData        *data;                   //视频缓冲数据
@property (nonatomic, copy) NSString               *mimeType;               //资源格式
@property (nonatomic, assign) long long            expectedContentLength;   //资源大小
@property (nonatomic, strong) NSMutableArray       *pendingRequests;        //存储AVAssetResourceLoadingRequest的数组

@property (nonatomic, copy) NSString               *cacheFileKey;           //缓存文件key值

@property (nonatomic, strong) NSMutableArray *modelArray;

@end

@implementation VideoDownloadManager

+(VideoDownloadManager *)shareManager {
    static dispatch_once_t once;
    static VideoDownloadManager *manager;
    dispatch_once(&once, ^{
        manager = [VideoDownloadManager new];
    });
    return manager;
}

-(void)startDownloadTaskWithModel:(NSMutableArray *)modelArray {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *path = [paths lastObject];
    NSString *diskCachePath = [NSString stringWithFormat:@"%@%@",path,@"/webCache"];
    //判断是否创建本地磁盘缓存文件夹
    BOOL isDirectory = NO;
    BOOL isExisted = [manager fileExistsAtPath:diskCachePath isDirectory:&isDirectory];
    if (!isDirectory || !isExisted){
        NSError *error;
        [manager createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    self.indexs = [NSMutableArray arrayWithArray:modelArray];
    dispatch_queue_t downloadVideoQueue = dispatch_queue_create("downloadVideoQueue", DISPATCH_QUEUE_CONCURRENT);
//    __weak __typeof(self) wself = self;
    for (NSInteger i = 0; i<modelArray.count; i++) {
        dispatch_async(downloadVideoQueue, ^{
            CTMediaModel *model = modelArray[i];
            
            WZDataDownloadManager *downloader = [[WZDataDownloadManager alloc] init];
            downloader.currentUrl = model.url;
            [downloader downloadTaskProgress:^(CGFloat downloadProgress) {
                
            } destination:^NSURL *(NSURL * _Nonnull targetPath, NSURLResponse * _Nullable response) {
                NSString *fileName = [[model.url md5] stringByAppendingString:@".mp4"];
                NSURL *finlPath = [[NSURL fileURLWithPath:diskCachePath] URLByAppendingPathComponent:fileName];
                NSLog(@"开始下载的任务：%@     下载任务的线程:%@",finlPath,[NSThread currentThread]);
                return finlPath;
            } completionHandler:^(NSURL * _Nullable filePath, NSError * _Nullable error) {
                
            }];
            
//            NSLog(@"即将下载:%@",model.url);
            //下载任务
//            [[WebCacheHelpler sharedWebCache] queryURLFromDiskMemory:model.url cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if(hasCache) {
//                        NSLog(@"已有缓存内容:%@",model.url);
//                        return;
//                    }
//
//                    if(wself.combineOperation != nil) {
//                        [wself.combineOperation cancel];
//                    }
//
//                    wself.combineOperation = [[WebDownloader sharedDownloader] downloadWithURL:[NSURL URLWithString:model.url] responseBlock:^(NSHTTPURLResponse *response) {
//                        wself.data = [NSMutableData data];
//                        wself.mimeType = response.MIMEType;
//                        wself.expectedContentLength = response.expectedContentLength;
//                        [wself processPendingRequests];
//                    } progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
//                        [wself.data appendData:data];
//                        //处理视频数据加载请求
////                        NSLog(@"下载数据进行中:%@",wself.cacheFileKey);
//                        [wself processPendingRequests];
//                    } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
//                        if(!error && finished) {
//                            //下载完毕，将缓存数据保存到本地
//                            [[WebCacheHelpler sharedWebCache] storeDataToDiskCache:wself.data key:model.url extension:@"mp4"];
//                            [self.indexs insertObject:model.url atIndex:i];
//                            NSLog(@"此视频下载完成:%@",model.url);
//                        }
//                    } cancelBlock:^{
//                    } isBackground:YES];
//                });
//            }];
        });
    }

}

//key值进行md5签名
- (NSString *)md5:(NSString *)key {
    if(!key) {
        return @"temp";
    }
    const char *str = [key UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

- (void)processPendingRequests {
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    //获取所有已完成AVAssetResourceLoadingRequest
    [_pendingRequests enumerateObjectsUsingBlock:^(AVAssetResourceLoadingRequest *loadingRequest, NSUInteger idx, BOOL * stop) {
        //判断AVAssetResourceLoadingRequest是否完成
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest];
        //结束AVAssetResourceLoadingRequest
        if (didRespondCompletely){
            [requestsCompleted addObject:loadingRequest];
            [loadingRequest finishLoading];
        }
    }];
    //移除所有已完成AVAssetResourceLoadingRequest
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //设置AVAssetResourceLoadingRequest的类型、支持断点下载、内容大小
    
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(_mimeType), NULL);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.contentLength = _expectedContentLength;
    
    //AVAssetResourceLoadingRequest请求偏移量
    long long startOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        startOffset = loadingRequest.dataRequest.currentOffset;
    }
    //判断当前缓存数据量是否大于请求偏移量
    if (_data.length < startOffset) {
        return NO;
    }
    //计算还未装载到缓存数据
    NSUInteger unreadBytes = _data.length - (NSUInteger)startOffset;
    //判断当前请求到的数据大小
    NSUInteger numberOfBytesToRespondWidth = MIN((NSUInteger)loadingRequest.dataRequest.requestedLength, unreadBytes);
    //将缓存数据的指定片段装载到视频加载请求中
    [loadingRequest.dataRequest respondWithData:[_data subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWidth)]];
    //计算装载完毕后的数据偏移量
    long long endOffset = startOffset + loadingRequest.dataRequest.requestedLength;
    //判断请求是否完成
    BOOL didRespondFully = _data.length >= endOffset;
    
    return didRespondFully;
}


#pragma mark 懒加载
//-(NSMutableArray *)indexs {
//    if (!_indexs) {
//        _indexs = [NSMutableArray arrayWithArray:self.modelArray];
//    }
//    return _indexs;
//}
@end

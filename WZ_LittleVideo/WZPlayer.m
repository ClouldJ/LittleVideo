//
//  WZPlayer.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/7.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "WZPlayer.h"
#import "WebCacheHelpler.h"
#import "NSString+Extension.h"

@interface WZPlayer () <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) NSURL                  *currentPlayerUrl;
@property (nonatomic, strong) NSString               *currentPlayerScheme;           //路径Scheme
@property (nonatomic, strong) AVPlayerItem           *currentPlayerItem;

@property (nonatomic, copy) NSString               *cacheFileKey;

@property (nonatomic, strong) NSOperation          *queryCacheOperation;    //查找本地视频缓存数据的NSOperation
@property (nonatomic, strong) dispatch_queue_t     cancelLoadingQueue;
@property (nonatomic ,strong) id                   timeObserver;            //视频播放器周期性调用的观察者

@property (nonatomic, strong) NSMutableData        *data;                   //视频缓冲数据
@property (nonatomic, copy) NSString               *mimeType;               //资源格式
@property (nonatomic, assign) long long            expectedContentLength;   //资源大小
@property (nonatomic, strong) NSMutableArray       *pendingRequests;        //存储AVAssetResourceLoadingRequest的数组

@property (nonatomic, strong) AVURLAsset *urlAsset;
@property (nonatomic, strong) WebCombineOperation  *combineOperation;

@property (nonatomic, assign) BOOL                 retried;
@end

@implementation WZPlayer

+ (WZPlayer *)defaultPlayer {
    static dispatch_once_t once;
    static WZPlayer *manager;
    dispatch_once(&once, ^{
        manager = [WZPlayer new];
    });
    return manager;
}

#pragma mark 初始化播放器资源
-(void)setPlayerWithUrl:(NSString *)url {

    _pendingRequests = [NSMutableArray array];

    [self setUpPlayerWithUrl:url isReplay:NO];
    
}

#pragma mark 播放
-(void)play {
    [self.player play];
}

-(void)pause {
    [self.player pause];
}

#pragma mark 刷新播放器资源
-(void)rePlayWithUrl:(NSString *)url {
    
    [self setUpPlayerWithUrl:url isReplay:YES];
    
}

-(void)setUpPlayerWithUrl:(NSString *)url isReplay:(BOOL)replay {
    self.currentPlayerUrl = [NSURL URLWithString:url];
 
//    if (replay) {
//        [self cancelLoading];
//    }
    
    //获取路径schema
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self.currentPlayerUrl resolvingAgainstBaseURL:NO];
    self.currentPlayerScheme = components.scheme;
    
    self.cacheFileKey = self.currentPlayerUrl.absoluteString;
    
    __weak typeof(self) weakSelf = self;
    //查看是否有缓存数据
    self.queryCacheOperation = [[WebCacheHelpler sharedWebCache] queryURLFromDiskMemory:self.cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!hasCache) {
                //当前路径无缓存，则将视频的网络路径的scheme改为其他自定义的scheme类型，http、https这类预留的scheme类型不能使AVAssetResourceLoaderDelegate中的方法回调
                weakSelf.currentPlayerUrl = [weakSelf.currentPlayerUrl.absoluteString urlScheme:@"streaming"];
            }else{
                weakSelf.currentPlayerUrl = [NSURL fileURLWithPath:data];
            }
            
            if (weakSelf.combineOperation) {
                [weakSelf.combineOperation cancel];
                weakSelf.combineOperation = nil;
            }
            
            [weakSelf.queryCacheOperation cancel];
            
            [weakSelf.urlAsset cancelLoading];
            weakSelf.data = nil;
            //结束所有视频数据加载请求
            for (AVAssetResourceLoadingRequest *re in weakSelf.pendingRequests) {
                if(![re isFinished]) {
                    [re finishLoading];
                }
            }
            
            [weakSelf.pendingRequests removeAllObjects];
            
            weakSelf.urlAsset = [AVURLAsset URLAssetWithURL:self.currentPlayerUrl options:nil];
            [weakSelf.urlAsset.resourceLoader setDelegate:weakSelf queue:dispatch_get_main_queue()];
            
            if (weakSelf.playerItem) {
                [weakSelf.playerItem removeObserver:self forKeyPath:@"status"];
            }
            
            weakSelf.playerItem = [AVPlayerItem playerItemWithAsset:weakSelf.urlAsset];
            [weakSelf.playerItem addObserver:weakSelf forKeyPath:@"status" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
            //添加播放器观察者
            
            [weakSelf.player replaceCurrentItemWithPlayerItem:weakSelf.playerItem];
            
            
            if (replay) {
                [weakSelf.player removeTimeObserver:weakSelf.timeObserver];
            }
            
            [weakSelf addProgressObserver];
            
        });
        
    } extension:@"mp4"];
}

// 给AVPlayerLayer添加周期性调用的观察者，用于更新视频播放进度
-(void)addProgressObserver{
    __weak __typeof(self) weakSelf = self;
    //AVPlayer添加周期性回调观察者，一秒调用一次block，用于更新视频播放进度
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if(weakSelf.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            //获取当前播放时间
            float current = CMTimeGetSeconds(time);
            //获取视频播放总时间
            float total = CMTimeGetSeconds([weakSelf.playerItem duration]);
            //重新播放视频
            if(total == current) {
                [weakSelf replay];
            }
            //更新视频播放进度方法回调
            if(weakSelf.delegate) {
                [weakSelf.delegate onProgressUpdate:current total:total];
            }
        }
    }];
}

// 响应KVO值变化的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //AVPlayerItem.status
    if([keyPath isEqualToString:@"status"]) {
        if(_playerItem.status == AVPlayerItemStatusFailed) {
            if(!_retried) {
                [self retry];
            }
        }
        //视频源装备完毕，则显示playerLayer
        if(_playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.playerLayer setHidden:NO];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WZPlayerStatusChange" object:_playerItem];
        
        //视频播放状体更新方法回调
//        if(_delegate) {
//            [_delegate onPlayItemStatusUpdate:_playerItem.status];
//        }
        
    }else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)retry {
    NSLog(@"重新请求播放");
    [self cancelLoading];
    self.currentPlayerUrl = [self.currentPlayerUrl.absoluteString urlScheme:self.currentPlayerScheme];
    [self setUpPlayerWithUrl:self.currentPlayerUrl.absoluteString isReplay:YES];
    self.retried = YES;
}

-(void)replay {
    NSLog(@"实现重复播放");
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

-(void)cancelLoading {
    [self pause];
    
    if (_combineOperation) {
        [_combineOperation cancel];
        _combineOperation = nil;
    }
    
    [_queryCacheOperation cancel];
    
    __weak __typeof(self) wself = self;
    dispatch_async(self.cancelLoadingQueue, ^{
        //取消AVURLAsset加载，这一步很重要，及时取消到AVAssetResourceLoaderDelegate视频源的加载，避免AVPlayer视频源切换时发生的错位现象
        [wself.urlAsset cancelLoading];
        wself.data = nil;
        //结束所有视频数据加载请求
        [wself.pendingRequests enumerateObjectsUsingBlock:^(id loadingRequest, NSUInteger idx, BOOL * stop) {
            if(![loadingRequest isFinished]) {
                [loadingRequest finishLoading];
            }
        }];
        [wself.pendingRequests removeAllObjects];
    });
    
    _retried = NO;
}

-(dispatch_queue_t)cancelLoadingQueue {
    if (!_cancelLoadingQueue) {
        //初始化取消视频加载的队列
        _cancelLoadingQueue = dispatch_queue_create("com.start.cancelloadingqueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _cancelLoadingQueue;
}

//开始视频资源下载任务
- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground {
    __weak __typeof(self) wself = self;
    _queryCacheOperation = [[WebCacheHelpler sharedWebCache] queryURLFromDiskMemory:_cacheFileKey cacheQueryCompletedBlock:^(id data, BOOL hasCache) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(hasCache) {
                return;
            }
            
            if(wself.combineOperation != nil) {
                [wself.combineOperation cancel];
            }
            
            wself.combineOperation = [[WebDownloader sharedDownloader] downloadWithURL:URL responseBlock:^(NSHTTPURLResponse *response) {
                wself.data = [NSMutableData data];
                wself.mimeType = response.MIMEType;
                wself.expectedContentLength = response.expectedContentLength;
                [wself processPendingRequests];
            } progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
                [wself.data appendData:data];
                //处理视频数据加载请求
                [wself processPendingRequests];
            } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                if(!error && finished) {
                    //下载完毕，将缓存数据保存到本地
                    [[WebCacheHelpler sharedWebCache] storeDataToDiskCache:wself.data key:wself.cacheFileKey extension:@"mp4"];
                }
            } cancelBlock:^{
            } isBackground:isBackground];
        });
    }];
}

#pragma AVAssetResourceLoaderDelegate

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    //创建用于下载视频源的NSURLSessionDataTask，当前方法会多次调用，所以需判断self.task == nil
    if(_combineOperation == nil) {
        //将当前的请求路径的scheme换成https，进行普通的网络请求
        NSURL *URL = [[loadingRequest.request URL].absoluteString urlScheme:_currentPlayerScheme];
        [self startDownloadTask:URL isBackground:YES];
    }
    //将视频加载请求依此存储到pendingRequests中，因为当前方法会多次调用，所以需用数组缓存
    [_pendingRequests addObject:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //AVAssetResourceLoadingRequest请求被取消，移除视频加载请求
    [_pendingRequests removeObject:loadingRequest];
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
-(AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _playerLayer;
}

-(AVPlayer *)player {
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}

- (void)dealloc {
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_player removeTimeObserver:_timeObserver];
}

@end

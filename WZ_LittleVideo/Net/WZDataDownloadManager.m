//
//  WZDataDownloadManager.m
//  v2_jdrn
//
//  Created by 赵鹏飞 on 2018/12/12.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "WZDataDownloadManager.h"

@interface WZDataDownloadManager ()

@property (nonatomic, strong) NSURLSession *downloadSession;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation WZDataDownloadManager

#pragma mark 懒加载
-(NSURLSession *)downloadSession {
  if (!_downloadSession) {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _downloadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:0];
  }
  return _downloadSession;
}

-(NSURLSessionDownloadTask *)downloadTaskProgress:(WZDownloadProgressCallBack)downloadProgressBlock destination:(WZDownloadDestinationCallBack)destination completionHandler:(WZDownloadFinishedCallBack)completionHandler {
  self.progressBlock = downloadProgressBlock;
  self.finishBlock = completionHandler;
  self.destinationBlock = destination;
  
  __block NSURLSessionDownloadTask *downloadTask = nil;
  
  url_session_manager_create_task_safely(^{
    self.downloadSession.configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    downloadTask = [self.downloadSession downloadTaskWithURL:[NSURL URLWithString:self.currentUrl]];
  });
  
  [downloadTask resume];
  self.downloadTask = downloadTask;
  return downloadTask;
  
}

#pragma mark NSURLSessionDownloadDelegate

// 写数据
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
  float process = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
  self.progressBlock(process);
}

// 断点下载数据
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
  NSLog(@"续传");
}

// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  NSURL *file = self.destinationBlock(location,self.downloadTask.response);

  NSError *err;
  [[NSFileManager defaultManager] moveItemAtURL:location toURL:file error:&err];
  
  if (err) {
    self.finishBlock(nil, err);
  }else{
    self.finishBlock(file,nil);
  }
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
  self.finishBlock(nil, error);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
  NSLog(@"下载任务开始接受服务器返回:%@",response);
}

@end

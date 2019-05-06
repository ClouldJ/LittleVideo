//
//  WZDataRequester.m
//  v2_jdrn
//
//  Created by 赵鹏飞 on 2018/12/12.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "WZDataRequester.h"
#import "Reachability.h"
#import "AFNetworkReachabilityManager.h"

@interface WZDataRequester ()

@property (nonatomic, strong) NSURLSessionDataTask *currentDataTask;

@property (nonatomic, strong) NSURLSession *URLSession;

@property (nonatomic) Reachability *reachability;

@property (nonatomic, strong) NSLock *networkLock;

@property (nonatomic,strong)NSOperationQueue *queue;

@property (nonatomic, strong) NSCondition *condition;

@end

Class object_getClass(id object);

@implementation WZDataRequester

#pragma mark - init & dealloc
- (id)init
{
  self = [super init];
  if (self)
  {
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    
    self.condition = [[NSCondition alloc] init];
    
    retryRequestCout = 0;
  }
  return self;
}

-(void)startObserverNetWork:(void(^)(NSDictionary *response))responseCallBack{
  AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
  
  //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(afNetworkStatusChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];//这个可以放在需要侦听的页面
  [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
    
    if (status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown) {
      NSLog(@"无网络访问");
      
      if (self.notReachableCallBack) {
        self.notReachableCallBack(@{});
      }
      
    }else{
      __weak typeof(WZDataRequester) *weak_self = self;
      [self.condition lock];
      [self startPrivateRequest:^(NSDictionary *response) {
        responseCallBack(response);
        [weak_self.condition unlock];
      }];
      
    }
    
  }];

  [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
}

-(void)dealloc{
  self.currentPostData = nil;
  self.currentParams = nil;
  self.currentUrl = nil;
  self.currentRequest = nil;
  self.reciveData = nil;
  [self.reachability stopNotifier];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 写方法
-(NSMutableData *)reciveData {
  if (!_reciveData) {
    _reciveData = [[NSMutableData alloc] init];
  }
  return _reciveData;
}

#pragma mark 发送请求
-(void)sendRequestSuccess:(void (^)(NSDictionary * _Nonnull))responseCallBack {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  });
  
  [self.queue addOperationWithBlock:^{
    
    [self startObserverNetWork:^(NSDictionary *response) {
      responseCallBack(response);
    }];
    
  }];
}

-(void)startPrivateRequest:(void(^)(NSDictionary *response))responseCallBack {
  
  retryRequestCout = 0;
  
  //区分请求类型
  if ([self requestTypeIsPost:self.requestType]) {
    //POST
    if (self.currentParams == nil) {
      [self sendRequestUsePost:self.currentUrl withPostData:self.currentPostData callBack:^(NSDictionary *response) {
        responseCallBack(response);
      }];
    }else{
      [self sendRequestUsePost:self.currentUrl withParams:self.currentParams callBack:^(NSDictionary *response) {
        responseCallBack(response);
      }];
    }
  }else{
    //GET
    
  }
}

#pragma mark 区分请求类型
+(BOOL)requestTypeIsResource:(DataRequestType)type
{
  return type > DRT_RESOURCE_BEGIN && type < DRT_RESOURCE_END;
}

-(BOOL)requestTypeIsGet:(DataRequestType)aType;
{
  return aType > DRT_TYPE_GET_BEGIN && aType < DRT_TYPE_GET_END;
}

-(BOOL)requestTypeIsPost:(DataRequestType)aType;
{
  return aType > DRT_TYPE_POST_BEGIN && aType < DRT_TYPE_POST_END;
}

#pragma  mark - POST
- (void)sendRequestUsePost:(NSString*)urlString withParams:(NSDictionary*)param callBack:(void(^)(NSDictionary *response))responseCallBack {
  
  NSMutableString *paramString = [[NSMutableString alloc] init];
  for (NSString *key in param) {
    [paramString appendFormat:@"%@=%@&",key,[param objectForKey:key]];
  }
  
  
  NSString *newParm = nil;
  if([paramString hasSuffix:@"&"]){
    NSRange rang = NSMakeRange(0, paramString.length-1);
    newParm = [paramString substringWithRange:rang];
  }
    
    NSString *ss = [self convertToJsonData:param];
  
  NSData *jsonData = [ss dataUsingEncoding:NSUTF8StringEncoding];
  
  self.currentPostData = jsonData;
  
  [self sendRequestUsePost:urlString withPostData:jsonData callBack:^(NSDictionary *response) {
    responseCallBack(response);
  }];
  
}


-(NSString *)convertToJsonData:(NSDictionary *)dict

{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

- (void)sendRequestUsePost:(NSString*)urlString withPostData:(NSData *)postData callBack:(void(^)(NSDictionary *response))responseCallBack{
  
  NSURL *url = [NSURL URLWithString:urlString];
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"POST";
  request.HTTPBody = postData;
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  
  [request setTimeoutInterval:3.0];
  
  /*
   第一个参数：请求对象
   第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
   data：响应体信息（期望的数据）
   response：响应头信息，主要是对服务器端的描述
   error：错误信息，如果请求失败，则error有值
   */
  
  NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    if (!error) {
      //解析数据
      NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
      
      if (responseCallBack) {
        responseCallBack(dict);
      }else{
        NSLog(@"无block返回，打印网络请求结果:%@",dict);
      }
    }else{
      
      responseCallBack(error.userInfo);
      
    }
    
  }];
  
  self.currentDataTask = dataTask;
  
  //执行任务
  [self.currentDataTask resume];
  
}

#pragma mark 懒加载
-(NSURLSession *)URLSession {
  if (!_URLSession) {
    _URLSession = [NSURLSession sharedSession];
  }
  return _URLSession;
}

@end

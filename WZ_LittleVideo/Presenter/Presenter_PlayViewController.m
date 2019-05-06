//
//  Presenter_PlayViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "Presenter_PlayViewController.h"
#import "VideoCell.h"
#import "CTMediaModel.h"

#import "JDRNDataRequester.h"

#import "CTMediaModel.h"

@interface Presenter_PlayViewController ()

@property (nonatomic, strong) CTMediaModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger pageIndex;

@property (nonatomic, strong) JDRNDataRequester *netWork;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation Presenter_PlayViewController

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_H;
}

-(void)reloadTableView:(UITableView *)tableView withModel:(NSMutableArray *)modelArray atIndex:(NSInteger)index{
    self.modelArray = [NSMutableArray arrayWithArray:modelArray];
    self.currentIndex = index;
    self.pageIndex = 1;         //待传入对应page信息
    self.tableView = tableView;
    [tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ddCell" forIndexPath:indexPath];
    
    if (self.modelArray.count>0) {
        CTMediaModel *model = self.modelArray[indexPath.row];
        [cell cellWithModel:model];
        [cell startDownloadBackgroundTask];
    }
    
    return cell;
}

#pragma ScrollView delegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGPoint translatedPoint = [scrollView.panGestureRecognizer translationInView:scrollView];
        //UITableView禁止响应其他滑动手势
        scrollView.panGestureRecognizer.enabled = NO;
        
        if(translatedPoint.y < -50 && self.currentIndex < (self.modelArray.count - 1)) {
            self.currentIndex ++;   //向下滑动索引递增
        }
        if(translatedPoint.y > 50 && self.currentIndex > 0) {
            self.currentIndex --;   //向上滑动索引递减
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(shouldScrollView:moveToIndex:)]) {
            [self.delegate shouldScrollView:scrollView moveToIndex:self.currentIndex];
        }

        if (self.currentIndex == self.modelArray.count - 1) {
            //准备加入新数据
            NSLog(@"准备加入新数据");
            [self loadMoreVideoWithPage:self.pageIndex + 1];
        }
        
    });
}

-(void)loadMoreVideoWithPage:(NSInteger)page {
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    [dic setObject:@"81871" forKey:@"uid"];
    [dic setObject:@"20" forKey:@"pageSize"];
    [dic setObject:[NSString stringWithFormat:@"%ld",page] forKey:@"currPage"];
    [dic setObject:@"recommend" forKey:@"listName"];
    
    __weak __typeof(self) wself = self;
    [self.netWork homeList:dic withResponse:^(NSDictionary * _Nonnull response) {
        if ([response[@"code"] integerValue] == 0) {
            NSArray *info = [NSArray arrayWithArray:response[@"info"]];
            NSArray *datas = [CTMediaModel mj_objectArrayWithKeyValuesArray:info];
            for (NSInteger i = 0; i < datas.count; i++) {
                
                NSDictionary *dic = [info objectAtIndex:i];
                CTMediaModel *model = [datas objectAtIndex:i];
                
                NSDictionary *storeInfo = [dic objectForKey:@"storeInfo"];
                model.storeInfo = [CTMediaStoreModel mj_objectWithKeyValues:storeInfo];
                
                NSDictionary *goodsInfo = [dic objectForKey:@"goodsInfo"];
                model.goodsId = [goodsInfo objectForKey:@"goodsId"];
                model.price = [NSString stringWithFormat:@"%@",[goodsInfo objectForKey:@"price"]];
                
                NSDictionary *specificationInfo = [dic objectForKey:@"specificationInfo"];
                CGFloat w = [[specificationInfo objectForKey:@"width"] floatValue];
                CGFloat h = [[specificationInfo objectForKey:@"height"] floatValue];
                CGFloat defaultW = ((SCREEN_W - 34.0)/2.0);
                model.logoSize = CGSizeMake(defaultW, defaultW * h / w);
                model.duration = [[specificationInfo objectForKey:@"duration"] integerValue];
                //            model.nameLayout = [self layoutGoodsTitle:model.title inWidth:defaultW - 12];
                //            model.height = model.logoSize.height + 34 + model.nameLayout.textBoundingSize.height;
                
                NSDictionary *statisticsInfo = [dic objectForKey:@"statisticsInfo"];
                model.attentionNum = [NSString stringWithFormat:@"%@",[statisticsInfo objectForKey:@"attentionNum"]];
                model.likeNum = [NSString stringWithFormat:@"%@",[statisticsInfo objectForKey:@"likeNum"]];
                model.shareNum = [NSString stringWithFormat:@"%@",[statisticsInfo objectForKey:@"shareNum"]];
            }
            
            self.pageIndex++;
 
            dispatch_main_async_safe(^{
                [wself.tableView beginUpdates];
                [wself.modelArray addObjectsFromArray:datas];
                NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
                for(NSInteger row = wself.modelArray.count - datas.count; row<wself.modelArray.count; row++) {
                    NSLog(@"加入的数据:%ld",(long)row);
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                    [indexPaths addObject:indexPath];
                }
                [wself.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
                [wself.tableView endUpdates];
            });
            
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",response[@"msg"]]];
            [SVProgressHUD dismissWithDelay:1.0f];
        }
        
    }];
    
}

#pragma mark 懒加载
-(JDRNDataRequester *)netWork {
    if (!_netWork) {
        _netWork = [[JDRNDataRequester alloc] init];
    }
    return _netWork;
}

-(NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end

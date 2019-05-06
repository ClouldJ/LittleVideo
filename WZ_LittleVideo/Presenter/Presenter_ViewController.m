//
//  Presenter_ViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "Presenter_ViewController.h"

#import "JDRNDataRequester.h"

#import "CTMediaModel.h"

@interface Presenter_ViewController ()

@property (nonatomic, strong) JDRNDataRequester *netWork;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation Presenter_ViewController

-(void)requestWithResult:(void (^)(void))callBack {
    
    NSMutableDictionary *dic =[NSMutableDictionary dictionary];
    [dic setObject:@"81871" forKey:@"uid"];
    [dic setObject:@"20" forKey:@"pageSize"];
    [dic setObject:@"1" forKey:@"currPage"];
    [dic setObject:@"recommend" forKey:@"listName"];
    
    [SVProgressHUD showWithStatus:@"数据获取中..."];
    
    [self.netWork homeList:dic withResponse:^(NSDictionary * _Nonnull response) {
//        NSLog(@"小视频数据源:%@",response);
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
            [self.dataSource addObjectsFromArray:datas];
            
            
            callBack();
            
            [SVProgressHUD showSuccessWithStatus:@"获取成功!!!"];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",response[@"msg"]]];
        }

        [SVProgressHUD dismissWithDelay:1.0f];
    }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (self.dataSource.count>0) {
        CTMediaModel *mm = self.dataSource[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",mm.title];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didClickIndexPath) {
        self.didClickIndexPath(indexPath, self.dataSource);
    }
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

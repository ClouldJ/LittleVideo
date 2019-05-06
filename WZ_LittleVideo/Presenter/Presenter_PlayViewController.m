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

@interface Presenter_PlayViewController ()

@property (nonatomic, strong) CTMediaModel *model;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *modelArray;


@end

@implementation Presenter_PlayViewController

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SCREEN_H;
}

-(void)reloadTableView:(UITableView *)tableView withModel:(NSMutableArray *)modelArray atIndex:(NSInteger)index{
    self.modelArray = [NSMutableArray arrayWithArray:modelArray];
    self.currentIndex = index;
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
        
//        [UIView animateWithDuration:0.15
//                              delay:0.0
//                            options:UIViewAnimationOptionCurveEaseOut animations:^{
//                                //UITableView滑动到指定cell
//                                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//                            } completion:^(BOOL finished) {
//                                //UITableView可以响应其他滑动手势
//                                scrollView.panGestureRecognizer.enabled = YES;
//                            }];
        
    });
}

@end

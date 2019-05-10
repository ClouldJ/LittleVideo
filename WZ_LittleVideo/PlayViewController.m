//
//  PlayViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "PlayViewController.h"
#import "VideoCell.h"
#import "Presenter_PlayViewController.h"
#import "UIViewController+Hidden.h"
#import "AVPlayerManager.h"
#import "VideoDownloadManager.h"

@interface PlayViewController () <Presenter_PlayViewControllerDelegate>

@property (nonatomic, strong) UITableView                       *tableView;

@property (nonatomic, assign) NSInteger                         currentIndex;

@property (nonatomic, strong) Presenter_PlayViewController      *presenter;

@property (nonatomic, strong) NSIndexPath                       *currentIndexPath;
@property (nonatomic, assign) BOOL                              isCurPlayerPause;
@property (nonatomic, strong) NSMutableArray                    *data;

@end

@implementation PlayViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.data = (NSMutableArray *)self.dataObject;
    self.currentIndexPath = (NSIndexPath *)self.parameterObject;
    self.currentIndex = self.currentIndexPath.row;
    
//    [[VideoDownloadManager shareManager] startDownloadTaskWithModel:self.data];
    
    [self.view addSubview:self.tableView];
    
    NSMutableArray *arr = [NSMutableArray arrayWithObjects:self.data[self.currentIndex],self.data[self.currentIndex+1], nil];

    //渲染界面----缺少pageIndex传入
    [self.presenter reloadTableView:self.tableView withModel:self.data atIndex:self.currentIndex];
    
//    __weak __typeof(self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
//        [wself.presenter reloadDatas:wself.data];

        NSIndexPath *curIndexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        [self.tableView scrollToRowAtIndexPath:curIndexPath atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:NO];
        [self addObserver:self forKeyPath:@"currentIndex" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];

    });

}

#pragma mark Presenter_PlayViewControllerDelegate
-(void)shouldScrollView:(UIScrollView *)scrollView moveToIndex:(NSInteger)index {
    self.currentIndex = index;
    [UIView animateWithDuration:0.15
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            //UITableView滑动到指定cell
                            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        } completion:^(BOOL finished) {
                            //UITableView可以响应其他滑动手势
                            scrollView.panGestureRecognizer.enabled = YES;
                        }];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    //观察currentIndex变化
    if ([keyPath isEqualToString:@"currentIndex"]) {
        //设置用于标记当前视频是否播放的BOOL值为NO
        _isCurPlayerPause = NO;
        //获取当前显示的cell
        VideoCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        [cell startDownloadHighPriorityTask];
        __weak typeof (cell) wcell = cell;
        __weak typeof (self) wself = self;
        //判断当前cell的视频源是否已经准备播放
        
        
//        if (cell.isPlayerReady) {
            [cell replay];
//        }else{
//            //当前cell的视频源还未准备好播放，则实现cell的OnPlayerReady Block 用于等待视频准备好后通知播放
//            cell.onPlayerReady = ^{
//                NSIndexPath *indexPath = [wself.tableView indexPathForCell:wcell];
//                if(!wself.isCurPlayerPause && indexPath && indexPath.row == wself.currentIndex) {
//                    [wcell play];
//                }
//            };
//        }

    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

#pragma mark 懒加载
-(UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -SCREEN_H, SCREEN_W, SCREEN_H * 3)];
        _tableView.contentInset = UIEdgeInsetsMake(SCREEN_H, 0, SCREEN_H * 1, 0);
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self.presenter;
        _tableView.dataSource = self.presenter;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        [_tableView registerClass:VideoCell.class forCellReuseIdentifier:@"ddCell"];
    }
    return _tableView;
    
}

-(Presenter_PlayViewController *)presenter {
    
    if (!_presenter) {
        _presenter = [[Presenter_PlayViewController alloc] init];
        _presenter.delegate = self;
    }
    return _presenter;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

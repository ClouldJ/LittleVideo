//
//  ViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "ViewController.h"
#import "Presenter/Presenter_ViewController.h"
#import "WZPlayerManager.h"
#import "WZ_Player.h"


#import "AVPlayer/AVPlayerView.h"
@interface ViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) Presenter_ViewController *self_presenter;

@property (nonatomic, strong) WZ_Player *wz_player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
    
//    WZPlayerManager *playerManager = [[WZPlayerManager alloc] init];
//
//    self.wz_player = [playerManager wz_playerWithUrl:@"https://res.jaadee.net/appdir/ios/live/video/2019-05-08/20190508092710704-205814.mp4"];
//    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.wz_player];
//    layer.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
//    [self.view.layer addSublayer:layer];
//
//    [playerManager play];
    
//    AVPlayerView *pp = [[AVPlayerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
//    [pp setPlayerWithUrl:@"https://res.jaadee.net/appdir/ios/live/video/2019-05-08/20190508092710704-205814.mp4"];
//    [self.view addSubview:pp];

//    [pp play];
    
    [self.view addSubview:self.tableView];

    typeof(ViewController) *weakSelf = self;
    [self.self_presenter requestWithResult:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}

#pragma mark 懒加载
-(Presenter_ViewController *)self_presenter {
    if (!_self_presenter) {
        _self_presenter = [[Presenter_ViewController alloc] init];
        typeof(ViewController) *weakSelf = self;
        _self_presenter.didClickIndexPath = ^(NSIndexPath * _Nonnull indexPath, NSMutableArray * _Nonnull array) {
            [weakSelf pushChildrenViewController:@"PlayViewController" parameterObject:indexPath dataObject:array
             ];
        };
    }
    return _self_presenter;
}

-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        _tableView.delegate = self.self_presenter;
        _tableView.dataSource = self.self_presenter;
        _tableView.rowHeight = 44;
//        _tableView.sc
    }
    return _tableView;
}


@end

//
//  ViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "ViewController.h"
#import "Presenter/Presenter_ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) Presenter_ViewController *self_presenter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

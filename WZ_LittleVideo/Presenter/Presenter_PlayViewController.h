//
//  Presenter_PlayViewController.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CTMediaModel;
NS_ASSUME_NONNULL_BEGIN
@protocol Presenter_PlayViewControllerDelegate <NSObject>

-(void)shouldScrollView:(UIScrollView *)scrollView moveToIndex:(NSInteger)index;

@end
@interface Presenter_PlayViewController : NSObject <UITableViewDelegate,UITableViewDataSource>

-(void)reloadTableView:(UITableView *)tableView withModel:(NSMutableArray *)modelArray atIndex:(NSInteger)index;

@property (nonatomic, weak)id<Presenter_PlayViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

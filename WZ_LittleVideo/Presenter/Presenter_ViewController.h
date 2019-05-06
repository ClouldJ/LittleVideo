//
//  Presenter_ViewController.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickIndexPath)(NSIndexPath *indexPath,NSMutableArray *array);

@interface Presenter_ViewController : NSObject <UITableViewDelegate,UITableViewDataSource>

-(void)requestWithResult:(void(^)(void))callBack;

@property (nonatomic, strong) ClickIndexPath didClickIndexPath;

@end

NS_ASSUME_NONNULL_END

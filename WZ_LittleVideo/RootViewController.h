//
//  RootViewController.h
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootViewController : UIViewController

-(void)pushChildrenViewController:(NSString *)name parameterObject:(id)type dataObject:(id)dObject;

@property (nonatomic, strong) id dataObject; //controller之间数据传递参数
@property (nonatomic, strong) id parameterObject;//controller之间数据传递参数

@end

NS_ASSUME_NONNULL_END

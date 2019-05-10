//
//  RootViewController.m
//  WZ_LittleVideo
//
//  Created by 赵鹏飞 on 2019/5/5.
//  Copyright © 2019 赵鹏飞. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)pushChildrenViewController:(NSString *)name parameterObject:(id)type dataObject:(id)dObject {
    
    id controller = [[NSClassFromString(name) alloc] init];
    if (controller) {
        if (type) {
            ((RootViewController *)controller).parameterObject = type;
        }
        if (dObject) {
            ((RootViewController *)controller).dataObject = dObject;
        }
        ((RootViewController *)controller).view.backgroundColor = [UIColor blackColor];
        [YBKShareAppDelegate.navigationController pushViewController:controller animated:YES];
        
    }
    
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

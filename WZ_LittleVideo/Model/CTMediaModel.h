//
//  CTMediaModel.h
//  JadeLiveHD
//
//  Created by Linfeng Jiang on 2019/4/26.
//  Copyright © 2019 Linfeng Jiang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CTMediaStoreModel;
@interface CTMediaModel : NSObject

@property (nonatomic, copy) NSString *goodsId;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *goodsLogo;
@property (nonatomic, copy) NSString *attentionNum;
@property (nonatomic, copy) NSString *likeNum;
@property (nonatomic, copy) NSString *shareNum;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) BOOL hot;
@property (nonatomic, assign) BOOL live;

@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) CTMediaStoreModel *storeInfo;
@property (nonatomic, assign) CGSize logoSize;
@property (nonatomic, assign) CGFloat height;
//@property (nonatomic, strong) YYTextLayout *nameLayout;
@property (nonatomic, assign) NSTimeInterval duration;


@end

@interface CTMediaStoreModel : NSObject

@property (nonatomic, copy) NSString *accId;
@property (nonatomic, copy) NSString *headPortraits;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *serverAvatar;
@property (nonatomic, copy) NSString *storeId;
@property (nonatomic, copy) NSString *storeName;

@property (nonatomic, assign) BOOL isAttention;

@end

NS_ASSUME_NONNULL_END

//
//  CommunicationKeyDefinition.h
//  DOTACard
//
//  Created by eric on 13-4-19.
//  Copyright (c) 2013年 eric. All rights reserved.
//

#ifndef __COMMUNICATION_KEY_DEFINITION_H__
#define __COMMUNICATION_KEY_DEFINITION_H__

typedef enum
{
    //GET 方式
    DRT_TYPE_GET_BEGIN,

    
    DRT_TYPE_GET_END,
    
    //POST 方式
    DRT_TYPE_POST_BEGIN,
  
  JDRN_HOTUPDATE_TYPE,
  
  JDRN_NTELOGIN_TYPE,

    DRT_TYPE_POST_END,
    //从Resource 中取数据
    DRT_RESOURCE_BEGIN,
    
    DRT_RESOURCE_END,

    
} DataRequestType;

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif


//#ifdef DEBUG
//#define BASE_URL @"https://newapitest.jaadee.net/index.php/v2/"
//#else
#define BASE_URL @"https://newapi.jaadee.net/index.php/v2/"
//#endif

#pragma mark 检查更新地址
#define JDRN_CHECKHOTUPDATE_URL @"Sign/upgradeCheck"

#define JDRN_REGISTERNTESCHAT_URL @"NetEase/register"


#endif
static dispatch_queue_t url_session_manager_creation_queue() {
  static dispatch_queue_t af_url_session_manager_creation_queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    af_url_session_manager_creation_queue = dispatch_queue_create("com.alamofire.networking.session.manager.creation", DISPATCH_QUEUE_SERIAL);
  });
  
  return af_url_session_manager_creation_queue;
}

static void url_session_manager_create_task_safely(dispatch_block_t block) {
  if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
    // Fix of bug
    // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
    // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
    dispatch_sync(url_session_manager_creation_queue(), block);
  } else {
    block();
  }
}

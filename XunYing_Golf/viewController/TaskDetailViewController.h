//
//  TaskDetailViewController.h
//  XunYing_Golf
//
//  Created by LiuC on 15/12/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskDetailViewController : UIViewController


@property (strong, nonatomic) NSString  *taskTypeName;
@property (strong, nonatomic) NSString  *taskStatus;
@property (strong, nonatomic) NSString  *taskResult;
@property (strong, nonatomic) NSString  *taskRequstTime;
@property (strong, nonatomic) NSString  *taskRequestPerson;
@property (strong, nonatomic) NSString  *taskDetailName;
@property (strong, nonatomic) NSString  *taskCartNum;
@property (strong, nonatomic) NSString  *taskCaddyNum;
@property (strong, nonatomic) NSString  *taskJumpHoleNum;
@property (strong, nonatomic) NSString  *taskMendHoleNum;
@property (strong, nonatomic) NSString  *taskLeaveRebacktime;
@property (nonatomic)         NSInteger whichInterfaceFrom;//1:from taskList ;2:from eachtaskReqView
@property (nonatomic)         NSInteger selectRowNum;



@end

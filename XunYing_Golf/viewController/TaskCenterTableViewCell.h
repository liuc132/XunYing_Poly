//
//  TaskCenterTableViewCell.h
//  XunYing_Golf
//
//  Created by LiuC on 15/12/24.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskCenterTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *taskColorView;
@property (strong, nonatomic) IBOutlet UIImageView *taskTypeImageDis;
@property (strong, nonatomic) IBOutlet UILabel *taskTypeNameDis;
@property (strong, nonatomic) IBOutlet UILabel *taskStatusDis;
@property (strong, nonatomic) IBOutlet UILabel *taskReqTimeDis;


@end

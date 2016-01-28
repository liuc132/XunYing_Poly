//
//  NoResultTableViewCell.h
//  XunYing_Golf
//
//  Created by LiuC on 15/12/17.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoResultTableViewCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIView *disColorView;
@property (strong, nonatomic) IBOutlet UIImageView *disImageView;
@property (strong, nonatomic) IBOutlet UILabel *disTaskTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *taskStatusLabel;
@property (strong, nonatomic) IBOutlet UILabel *requestLabel;
@property (strong, nonatomic) IBOutlet UILabel *requestTimeLabel;


@end

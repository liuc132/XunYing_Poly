//
//  WaitToPlayTableViewController.h
//  XunYing_Golf
//
//  Created by LiuC on 15/9/21.
//  Copyright © 2015年 LiuC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "passValueLogInDelegate.h"

@interface WaitToPlayTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (copy,nonatomic) NSString* holeType;
@property (nonatomic) NSInteger customerCounts;
@property (nonatomic) BOOL      QRCodeEnable;
@property (strong, nonatomic)   NSArray *cusCardArray;
@property (copy, nonatomic) NSString *fieldName;


@property (strong, nonatomic) id<passValueLogInDelegate> passDelegate;

@end

//
//  UITableViewController+UICon.m
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/8.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "UITableViewController+UICon.h"

@implementation UITableViewController (UICon)

/**
 * 表格延迟加载问题
 */
-(void) cellTouches{
    for (id obj in self.view.subviews)
    {
        if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"])
        {
            UIScrollView *scroll = (UIScrollView *) obj;
            scroll.delaysContentTouches = NO;
            break;
        }
    }
    
    self.tableView.delaysContentTouches = NO;

}




@end

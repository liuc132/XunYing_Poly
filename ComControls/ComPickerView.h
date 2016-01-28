//
//  ComPickerView.h
//  hbuddy.iphone
//
//  Created by 周杨 on 15/5/27.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFactory.h"

@interface ComPickerView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic) NSArray * dbArr;

@property (nonatomic) ComLable * bingLib;

/**
 *  显示视图
 */
-(void) ShowView;

/**
 *  影藏视图
 */
-(void) HideView;

@end

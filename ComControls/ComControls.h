//
//  ComControls.h
//  Common
//
//  Created by 周杨 on 15/1/11.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#ifndef Common_ComControls_h
#define Common_ComControls_h
#import "ComImageView.h"
#import "NSString+FontAwesome.h"

/**
 * 边框的样式
 */
typedef enum
{
    BorderStyleRadius,        //圆角
    BorderStyleCircle,        //圆形
    BorderStyleNone           //无
} BorderStyle ;

/**
 * 颜色的样式
 */
typedef enum
{
    ColorBlack,     //黑色
    ColorGray,      //灰色
    ColorGreen,     //绿色
    ColorWhite,     //白色
    ColorClear
} ColorStyle ;

#endif

//
//  ComImageView.m
//  Common
//
//  Created by 周杨 on 15/1/9.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "ComImageView.h"
#import "UIImage+UICon.h"

@implementation ComImageView

/**
 *  设置为 黑色样式
 */
-(void) blackImageViewColorStyle{
    self.backgroundColor = [UIColor HexString:@"#ffffff"];
    self.layer.borderColor = [UIColor HexString:@"676c79"].CGColor;
    
}

/**
 *  设置为 灰色样式
 */
-(void) grayImageViewColorStyle{
    self.backgroundColor = [UIColor HexString:@"#393f4f"];
    self.layer.borderColor = [UIColor HexString:@"8e95a5"].CGColor;
}

/**
 *  设置为 白色样式
 */
-(void) whiteImageViewColorStyle{
    
    self.backgroundColor = [UIColor HexString:@"#292d39"];
    self.layer.borderColor = [UIColor HexString:@"ffffff"].CGColor;
}


/**
 *  设置 圆角边框
 */
-(void) imageViewBorderRadiusStyle{
    [self.layer setCornerRadius:6.0]; //设置矩圆角半径
    [self.layer setBorderWidth:3];   //边框宽度
    
    self.image=[UIImage roundedRectImage:self.image imgSize:self.bounds.size roundRadius:6];
}

/**
 *  设置 圆形边框
 */
-(void) imageViewBorderCircleStyle{
    [self.layer setCornerRadius:self.bounds.size.width/2]; //设置矩圆角半径
    [self.layer setBorderWidth:3];
    
    self.image=[UIImage circleImage:self.image ];
}

/**
 *  设置  图形圆角幅度
 *
 *  @param val 幅度值
 */
-(void) setBorderRadius:(double) val{
    [self.layer setCornerRadius:val]; //设置矩圆角半径
    self.layer.masksToBounds=YES;
//    self.image=[UIImage roundedRectImage:self.image imgSize:self.bounds.size roundRadius:val];
}

/**
 *  设置 无边框
 */
-(void) imageViewBorderNoneStyle{
    [self.layer setBorderWidth:0];
}

/**
 *  异步加载网络路径图片
 *
 *  @param url   URL地址
 *  @param frame 大小
 *
 *  @return ImageView实例
 */
-(instancetype) initForNSUrl:(NSString *)url andFrame:(CGRect)frame{
    self = [super init];

    if (self) {
        self.frame =frame;
        
        [self setBackgroundColor:[UIColor grayColor]];
        
        
        //如果目录imageCache 图片缓存目录
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * diskCachePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"imageCache"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath]) {
            NSError *error=nil;
            [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        
        
        //缓存图片路径
        NSString * fileName = [@"" stringByAppendingString:[url lastPathComponent]];
        NSString *localpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[@"/imageCache/" stringByAppendingString:fileName]];
        
        //如果有缓存图片，直接读取cache内的缓存图片
        if ([[NSFileManager defaultManager] fileExistsAtPath:localpath]) {
            NSData *data = [NSData dataWithContentsOfFile:localpath];
            self.image = [UIImage imageWithData:data];
        }
        else{
            //如果没有缓存图片，请求
            //通过GCD加载网络图片
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                NSURL *imageUrl = [NSURL URLWithString:url];
                NSData * imgData =[NSData dataWithContentsOfURL:imageUrl];
                UIImage *image = [UIImage imageWithData:imgData];
                
                [[NSFileManager defaultManager] createFileAtPath:localpath contents:imgData attributes:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = image;
                });
            });
            
        }
        
    }
    return self;
}

/**
 *  设置为圆形样式
 */
-(void) setCircleStyle{
    
    self.layer.masksToBounds=YES;
    [self.layer setCornerRadius:self.frame.size.width/2];
    //self.image=[UIImage circleImage:self.image ];
}

/**
 *  设置boder样式
 */
-(void) setBoderStyle:(NSString *) hexColor{
    
    // self.layer
    self.layer.shadowOffset = CGSizeMake(0, 0);
    
    self.layer.borderWidth =4;
    self.layer.borderColor = [UIColor HexString:hexColor].CGColor;
}

/**
 *  点击事件
 *
 *  @param actionBlock 事件闭包
 */
-(void) onClick:(ActionBlock)action{
    
    self.actionBlock = action;
    
    UITapGestureRecognizer *gensture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidFun)];
    self.userInteractionEnabled=YES;
    
    [self addGestureRecognizer:gensture];
}

- (void)hidFun{
    self.actionBlock();
}
@end

//
//  NSString+FontAwesome.m
//  Common
//
//  Created by 周杨 on 15/1/7.
//  Copyright (c) 2015年 zhouy. All rights reserved.
//

#import "NSString+FontAwesome.h"


static const NSArray *awesomeStrings;

@implementation NSString (FontAwesome)
+ (NSString *)stringFromAwesomeIcon:(FAIcon)icon
{
    if(awesomeStrings==nil) {
        //
        //UIFont* font = [UIFont fontWithName:@"FontAwesome" size:size];
        //
        //FontAwesome
        
        awesomeStrings=[UIFont fontNamesForFamilyName:@"FontAwesome"];
        
//        
//        for (NSString * fStr in awesomeStrings ) {
//            
//            NSLog(@"%@",fStr);
//        }
//        
//
//        NSArray *familyNames = [UIFont familyNames];
//        for( NSString *familyName in familyNames ){
//            printf( "Family: %s \n", [familyName UTF8String] );
//            NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
//            for( NSString *fontName in fontNames ){
//                printf( "\tFont: %s \n", [fontName UTF8String] );
//            }  
//        }
//
        
        
        awesomeStrings = [NSArray arrayWithObjects:@"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"", @"",@"",@"",@"",@"", @"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
    }
    
    return [awesomeStrings objectAtIndex:icon];
}

+ (UIFont *) getFromAwesomeSize:(int) size{

    return [UIFont fontWithName:@"FontAwesome" size:size];
}


- (NSString *)trimWhitespace
{
    NSMutableString *str = [self mutableCopy];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)str);
    return str;
}

- (BOOL)isEmpty
{
    return [[self trimWhitespace] isEqualToString:@""];
}

/**
 *  MD5字串
 *
 *  @param input 原始字串
 *
 *  @return MD5字串
 */
+ (NSString *)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%2s",result];
    }
    return ret;
}


@end

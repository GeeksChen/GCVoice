//
//  UIColor+GC.h
//  Bage
//
//  Created by 陈潇 on 17/3/7.
//  Copyright © 2017年 Geeks_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (GC)

+ (UIColor *)gc_colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)gc_colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

@end

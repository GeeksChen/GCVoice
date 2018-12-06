//
//  UIImage+GC.h
//  Bage
//
//  Created by 陈潇 on 17/3/8.
//  Copyright © 2017年 Geeks_Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GC)
#pragma mark -- 图片原图显示
+ (UIImage *)gc_imageWithRenderOriginal:(NSString *)name;
#pragma mark -- 根据颜色绘制图片
+ (UIImage *)gc_createImageWithColor:(UIColor*)color;
#pragma mark -- 对图片的尺寸处理
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end

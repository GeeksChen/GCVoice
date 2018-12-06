//
//  UIImage+GC.m
//  Bage
//
//  Created by 陈潇 on 17/3/8.
//  Copyright © 2017年 Geeks_Chen. All rights reserved.
//

#import "UIImage+GC.h"

@implementation UIImage (GC)
#pragma mark -- 图片原图显示
+ (UIImage *)gc_imageWithRenderOriginal:(NSString *)name{

    UIImage *image =  [UIImage imageNamed:name];
    
    [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    return image;
}
#pragma mark -- 根据颜色绘制图片
+ (UIImage*)gc_createImageWithColor:(UIColor*)color{
    
    CGRect rect =CGRectMake(0.0f,0.0f,1.0f,1.0f);UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context=UIGraphicsGetCurrentContext();CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();
    
    return theImage;
    
}
#pragma mark -- 对图片的尺寸处理
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize

{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}
@end

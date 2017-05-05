//
//  UILabel+Extension.m
//  BaiDaGe-iOS
//
//  Created by 冯倩 on 15/12/7.
//  Copyright © 2015年 SevenTian. All rights reserved.
//

#import "UILabel+Extension.h"
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
@implementation UILabel (Extension)

/**
 *  提示信息
 */
+ (void)promptMessage:(nullable NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        string = @"出现异常";
    }
    NSDictionary *attrs = @{NSFontAttributeName : @14};
    
    CGSize size = [string boundingRectWithSize:CGSizeMake(kScreenWidth - 30, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
    label.layer.cornerRadius = 5;
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.layer.masksToBounds = YES;
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = string;
    label.textAlignment = NSTextAlignmentCenter;
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    [window addSubview:label];
    CGFloat _width =size.width + 30;
    NSDictionary *views = NSDictionaryOfVariableBindings(label);
    NSDictionary *metrics = @{@"width" : @(_width) , @"height" : @(size.height + 20)};
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(width)]" options:0 metrics:metrics views:views]];
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(height)]" options:0 metrics:metrics views:views]];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [window addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:window attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [UIView animateWithDuration:3 animations:^{
        label.alpha = 0;
    }];
}
@end

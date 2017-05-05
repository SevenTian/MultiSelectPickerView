//
//  TitleButton.m
//  Mobile-Housekeeper
//
//  Created by dingwei on 15/10/16.
//  Copyright © 2015年 ST. All rights reserved.
//

#import "TitleButton.h"
#import "UIView+Extension.h"
@implementation TitleButton

- (TitleButton *)initWithFrame:(CGRect)frame font:(CGFloat)font titleColor:(UIColor *)titleColor normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
     
        [self setTitleColor:titleColor forState:UIControlStateNormal];
         self.titleLabel.font = [UIFont systemFontOfSize:font];
        [self setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:normalImage] forState:UIControlStateHighlighted];
        [self setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
        [self setTitle:title forState:UIControlStateNormal];
    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
//    frame.size.width += 2;
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 如果仅仅是调整按钮内部titleLabel和imageView的位置，那么在layoutSubviews中单独设置位置即可
    
    // 1.计算titleLabel的frame
//    self.titleLabel.x = self.imageView.x;
    self.titleLabel.x = 0;

    // 2.计算imageView的frame
    self.imageView.x = CGRectGetMaxX(self.titleLabel.frame) + 2;
    
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    // 只要修改了文字，就让按钮重新计算自己的尺寸
    [self sizeToFit];
    
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [super setImage:image forState:state];
    
    // 只要修改了图片，就让按钮重新计算自己的尺寸
    [self sizeToFit];
}


@end

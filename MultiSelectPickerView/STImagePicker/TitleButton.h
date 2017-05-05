//
//  TitleButton.h
//  Mobile-Housekeeper
//
//  Created by dingwei on 15/10/16.
//  Copyright © 2015年 ST. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleButton : UIButton
- (TitleButton *)initWithFrame:(CGRect)frame font:(CGFloat)font titleColor:(UIColor *)titleColor normalImage:(NSString *)normalImage selectedImage:(NSString *)selectedImage title:(NSString *)title;
@end

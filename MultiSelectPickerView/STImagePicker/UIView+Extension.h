//
//  UIView+Extension.h
//  XMPP-test
//
//  Created by dingwei on 15/10/13.
//  Copyright © 2015年 SYY. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (Extension)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
- (id)buttonSuperViewHierarchy:(int)hierarchy;
@end

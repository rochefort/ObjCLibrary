//
//  UIImage+UIImage_blur.h
//  RSSReader
//
//  Created by rochefort on 2013/11/17.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_blur)

+ (UIImage *)blurImageNamed:(NSString *)name;
- (UIImage *)blur:(UIImage *)image;
@end

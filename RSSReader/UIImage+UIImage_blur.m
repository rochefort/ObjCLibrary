//
//  UIImage+UIImage_blur.m
//  RSSReader
//
//  Created by rochefort on 2013/11/17.
//  Copyright (c) 2013年 rochefort. All rights reserved.
//

#import "UIImage+UIImage_blur.h"

@implementation UIImage (UIImage_blur)

+ (UIImage *)blurImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    return[image blur:image];
}

- (UIImage *)blur:(UIImage *)image;
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:10] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];

    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    UIImage *blurImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return blurImage;
}

@end

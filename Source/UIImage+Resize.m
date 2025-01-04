//
//  UIImage+Resize.m
//  SVGAPlayer
//
//  Created by smartzou on 2025/1/3.
//  Copyright © 2025 UED Center. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (NSUInteger)costForImage {
        CGImageRef imageRef = self.CGImage;
        if (!imageRef) {
            return 0;
        }
        NSUInteger bytesPerFrame = CGImageGetBytesPerRow(imageRef) * CGImageGetHeight(imageRef);
        NSUInteger frameCount = self.images.count > 0 ? self.images.count : 1;
        return bytesPerFrame * frameCount;
}

- (UIImage *)scaleToFillSize:(CGSize)size mode:(NSInteger)mode scale:(CGFloat)scale {
    if (CGSizeEqualToSize(self.size, size)) {
        return self;
    }
    
    CGRect rect;
    CGSize rendererSize;
    
    if (mode == 0) { // Assuming 0 is for .fill
        BOOL isEqualRatio = (size.width / size.height) == (self.size.width / self.size.height);
        if (isEqualRatio) {
            rendererSize = size;
            rect = CGRectMake(0, 0, size.width, size.height);
        } else {
            CGFloat scale = size.width / self.size.width;
            CGFloat scaleHeight = scale * self.size.height;
            CGFloat scaleWidth = size.width;
            if (scaleHeight < size.height) {
                scaleWidth = size.height / scaleHeight * size.width;
                scaleHeight = size.height;
            }
            rendererSize = CGSizeMake(scaleWidth, scaleHeight);
            rect = CGRectMake(0, 0, rendererSize.width, rendererSize.height);
        }
    } else {
        rendererSize = size;
        if (mode == 1) { // Assuming 1 is for .fit
            rect = CGRectMake(0, 0, size.width, size.height);
        } else {
            CGFloat scale = size.width / self.size.width;
            CGFloat scaleHeight = scale * self.size.height;
            if (scaleHeight < size.height) {
                scaleHeight = size.height;
            }
            rect = CGRectMake(0, -(scaleHeight - size.height) / 2, size.width, scaleHeight);
        }
    }
    
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    BOOL hasAlpha = [self CGImageContainsAlpha];
    format.opaque = !hasAlpha;
    format.scale = scale == 0 ? self.scale : scale;
    
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:rendererSize format:format];
    UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        [self drawInRect:rect];
    }];
    
    return image;
}

- (BOOL)CGImageContainsAlpha {
    if (!self.CGImage) {
        return NO;
    }
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(self.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    return hasAlpha;
}




@end

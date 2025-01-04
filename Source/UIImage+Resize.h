//
//  UIImage+Resize.h
//  SVGAPlayer
//
//  Created by smartzou on 2025/1/3.
//  Copyright © 2025 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Resize)
- (NSUInteger)costForImage;
- (UIImage *)scaleToFillSize:(CGSize)size mode:(NSInteger)mode scale:(CGFloat)scale;
@end

NS_ASSUME_NONNULL_END

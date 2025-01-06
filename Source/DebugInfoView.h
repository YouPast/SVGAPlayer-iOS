//
//  DebugInfoView.h
//  SVGAPlayer
//
//  Created by smartzou on 2025/1/4.
//  Copyright © 2025 UED Center. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DebugInfoView : UIView
@property (nonatomic, strong) UITextView *textView;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)updateWithText:(NSString *)text;
@end

NS_ASSUME_NONNULL_END

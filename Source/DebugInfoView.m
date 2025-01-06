//
//  DebugInfoView.m
//  SVGAPlayer
//
//  Created by smartzou on 2025/1/4.
//  Copyright © 2025 UED Center. All rights reserved.
//

#import "DebugInfoView.h"
#import <UIKit/UIKit.h>

@implementation DebugInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置视图背景颜色
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

        // 初始化 UITextView
        _textView = [[UITextView alloc] init];
        _textView.textColor = [UIColor whiteColor];
        _textView.backgroundColor = [UIColor clearColor]; // 背景透明
        _textView.editable = NO; // 禁止编辑
        _textView.scrollEnabled = NO; // 自动调整大小时禁用滚动
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;

        // 添加 UITextView 到视图中
        [self addSubview:_textView];

        // 设置 UITextView 的约束
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints {
    // 将 UITextView 在父视图中居中
    [NSLayoutConstraint activateConstraints:@[
        [_textView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_textView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [_textView.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.leadingAnchor constant:10],
        [_textView.trailingAnchor constraintLessThanOrEqualToAnchor:self.trailingAnchor constant:-10]
    ]];
}

- (void)updateWithText:(NSString *)text {
    // 更新 UITextView 的文本内容
    self.textView.text = text;

    // 调整 UITextView 的大小以适应文本
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.bounds.size.width - 20, CGFLOAT_MAX)];
    self.textView.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
}

@end


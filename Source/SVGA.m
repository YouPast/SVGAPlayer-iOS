//
//  SVGA.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import "SVGA.h"

@interface SVGA ()
@property (nonatomic,assign) BOOL deubg;
@end
    

@implementation SVGA
+ (SVGA *)shared {
    static SVGA *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SVGA alloc] init];
    });

    return sharedInstance;
}

- (void)setEnableDebug:(BOOL)enableDebug {
    _deubg = enableDebug;
}

- (BOOL)enableDebug {
    return _deubg;
}

@end

//
//  SVGA.h
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SVGAParser.h"
//#import "SVGAPlayer.h"
//#import "SVGAImageView.h"
//#import "SVGAVideoEntity.h"
//#import "SVGAExporter.h"

//#import <SVGAPlayer/SVGAParser.h>
//#import <SVGAPlayer/SVGAPlayer.h>
//#import <SVGAPlayer/SVGAImageView.h>
//#import <SVGAPlayer/SVGAVideoEntity.h>
//#import <SVGAPlayer/SVGAExporter.h>

@interface SVGA : NSObject
+ (SVGA *)shared;
- (void)setEnableDebug:(BOOL)enableDebug;
- (BOOL)enableDebug;
@end

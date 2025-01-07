//
//  SVGA.h
//  SVGA
//
//  Created by Xinyu Wang on 2024/4/10.
//  Copyright © 2024 UED Center. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for SVGA.
//FOUNDATION_EXPORT double SVGAVersionNumber;
//
////! Project version string for SVGA.
//FOUNDATION_EXPORT const unsigned char SVGAVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SVGA/PublicHeader.h>
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


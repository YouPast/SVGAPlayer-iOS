//
//  SVGAVideoEntity.m
//  SVGAPlayer
//
//  Created by 崔明辉 on 16/6/17.
//  Copyright © 2016年 UED Center. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SVGAVideoEntity.h"
#import "SVGABezierPath.h"
#import "SVGAVideoSpriteEntity.h"
#import "SVGAAudioEntity.h"
#import "Svga.pbobjc.h"
#import "UIImage+Resize.h"
#import "SVGA.h"
#define MP3_MAGIC_NUMBER "ID3"

@interface SVGAVideoEntity ()

@property (nonatomic, assign) CGSize videoSize;
@property (nonatomic, assign) int FPS;
@property (nonatomic, assign) int frames;
@property (nonatomic, copy) NSDictionary<NSString *, UIImage *> *images;
@property (nonatomic, copy) NSDictionary<NSString *, NSData *> *audiosData;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteEntity *> *sprites;
@property (nonatomic, copy) NSArray<SVGAAudioEntity *> *audios;
@property (nonatomic, copy) NSString *cacheDir;
@property (nonatomic,assign) NSInteger bytecount;
@property (nonatomic,assign) NSInteger memoryCount;
@end

@implementation SVGAVideoEntity

static inline UIImage *SVGAImageDecodeAndScaleDownUIKit(UIImage *image, CGSize destResolution) {
    // See: https://developer.apple.com/documentation/uikit/uiimage/3750835-imagebypreparingthumbnailofsize
    // Need CGImage-based
    if (@available(iOS 15, tvOS 15, *)) {
        // Calculate thumbnail point size
        CGFloat scale = image.scale ?: 1;
        CGSize thumbnailSize = CGSizeMake(destResolution.width / scale, destResolution.height / scale);
        UIImage *decodedImage = [image imageByPreparingThumbnailOfSize:thumbnailSize];
        if (decodedImage) {
            return decodedImage;
        }
    }
    return nil;
}

static NSCache *videoCache;
static NSMapTable * weakCache;
static dispatch_semaphore_t videoSemaphore;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        videoCache = [[NSCache alloc] init];
        weakCache = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory
        valueOptions:NSPointerFunctionsWeakMemory
            capacity:64];
        videoSemaphore = dispatch_semaphore_create(1);
    });
}

- (instancetype)initWithJSONObject:(NSDictionary *)JSONObject cacheDir:(NSString *)cacheDir {
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(100, 100);
        _FPS = 20;
        _images = @{};
        _cacheDir = cacheDir;
        [self resetMovieWithJSONObject:JSONObject];
    }
    return self;
}

- (void)resetMovieWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *movieObject = JSONObject[@"movie"];
        if ([movieObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *viewBox = movieObject[@"viewBox"];
            if ([viewBox isKindOfClass:[NSDictionary class]]) {
                NSNumber *width = viewBox[@"width"];
                NSNumber *height = viewBox[@"height"];
                if ([width isKindOfClass:[NSNumber class]] && [height isKindOfClass:[NSNumber class]]) {
                    _videoSize = CGSizeMake(width.floatValue, height.floatValue);
                }
            }
            NSNumber *FPS = movieObject[@"fps"];
            if ([FPS isKindOfClass:[NSNumber class]]) {
                _FPS = [FPS intValue];
            }
            NSNumber *frames = movieObject[@"frames"];
            if ([frames isKindOfClass:[NSNumber class]]) {
                _frames = [frames intValue];
            }
        }
    }
}

- (void)resetImagesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
        NSDictionary<NSString *, NSString *> *JSONImages = JSONObject[@"images"];
        if ([JSONImages isKindOfClass:[NSDictionary class]]) {
            [JSONImages enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSString *filePath = [self.cacheDir stringByAppendingFormat:@"/%@.png", obj];
//                    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                    NSData *imageData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:NULL];
                    if (imageData != nil) {
                        UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
                        UIImage *scaledImage = [self resizeImageIfNeed:image];
                        if (scaledImage != nil) {
                            [images setObject:scaledImage forKey:[key stringByDeletingPathExtension]];
                        }
                        if (self.enableDebug) {
                            self.memoryCount += [scaledImage costForImage];
                            self.bytecount += imageData.length;
                        }
                        
                    }
                }
            }];
        }
        self.images = images;
    }
}

- (void)resetSpritesWithJSONObject:(NSDictionary *)JSONObject {
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableArray<SVGAVideoSpriteEntity *> *sprites = [[NSMutableArray alloc] init];
        NSArray<NSDictionary *> *JSONSprites = JSONObject[@"sprites"];
        if ([JSONSprites isKindOfClass:[NSArray class]]) {
            [JSONSprites enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    SVGAVideoSpriteEntity *spriteItem = [[SVGAVideoSpriteEntity alloc] initWithJSONObject:obj];
                    [sprites addObject:spriteItem];
                }
            }];
        }
        self.sprites = sprites;
    }
}

- (instancetype)initWithProtoObject:(SVGAProtoMovieEntity *)protoObject cacheDir:(NSString *)cacheDir {
    self = [super init];
    if (self) {
        _videoSize = CGSizeMake(100, 100);
        _FPS = 20;
        _images = @{};
        _cacheDir = cacheDir;
        [self resetMovieWithProtoObject:protoObject];
    }
    return self;
}

- (void)resetMovieWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    if (protoObject.hasParams) {
        self.videoSize = CGSizeMake((CGFloat)protoObject.params.viewBoxWidth, (CGFloat)protoObject.params.viewBoxHeight);
        NSLog(@"videosize: %.1f, %.1f",_videoSize.width,_videoSize.height);
        self.FPS = (int)protoObject.params.fps;
        self.frames = (int)protoObject.params.frames;
    }
}

+ (BOOL)isMP3Data:(NSData *)data {
    BOOL result = NO;
    if (!strncmp([data bytes], MP3_MAGIC_NUMBER, strlen(MP3_MAGIC_NUMBER))) {
        result = YES;
    }
    return result;
}



- (void)resetImagesWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    NSMutableDictionary<NSString *, UIImage *> *images = [[NSMutableDictionary alloc] init];
    NSMutableDictionary<NSString *, NSData *> *audiosData = [[NSMutableDictionary alloc] init];
    NSDictionary *protoImages = [protoObject.images copy];
    self.bytecount = 0;
    self.memoryCount = 0;
    for (NSString *key in protoImages) {
        NSString *fileName = [[NSString alloc] initWithData:protoImages[key] encoding:NSUTF8StringEncoding];
        if (fileName != nil) {
            NSString *filePath = [self.cacheDir stringByAppendingFormat:@"/%@.png", fileName];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                filePath = [self.cacheDir stringByAppendingFormat:@"/%@", fileName];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
//                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                NSData *imageData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:NULL];
                if (imageData != nil) {
                    UIImage *image = [[UIImage alloc] initWithData:imageData scale:2.0];
                    if (image != nil) {
                        [images setObject:image forKey:key];
                    }
                }
            }
        }
        else if ([protoImages[key] isKindOfClass:[NSData class]]) {
            if ([SVGAVideoEntity isMP3Data:protoImages[key]]) {
                // mp3
                [audiosData setObject:protoImages[key] forKey:key];
            } else {
                NSData *data = protoImages[key];
                UIImage *image = [[UIImage alloc] initWithData:data scale:2.0];
                UIImage *scaledImage = [self resizeImageIfNeed:image];
                if (scaledImage != nil) {
                    
                    [images setObject:scaledImage forKey:key];
                    
                    
                }
                if (self.enableDebug) {
                    self.memoryCount += [scaledImage costForImage];
                    self.bytecount += data.length;
                }
            }
        }
    }
    self.images = images;
    self.audiosData = audiosData;
    if (self.enableDebug) {
        NSLog(@"SVGA filesize: %.1f kb , memorycost: %.1f kb", self.bytecount / 1024.0, self.memoryCount / 1024.0);
    }
}


- (void)resetSpritesWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    NSMutableArray<SVGAVideoSpriteEntity *> *sprites = [[NSMutableArray alloc] init];
    NSArray *protoSprites = [protoObject.spritesArray copy];
    [protoSprites enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SVGAProtoSpriteEntity class]]) {
            SVGAVideoSpriteEntity *spriteItem = [[SVGAVideoSpriteEntity alloc] initWithProtoObject:obj];
            [sprites addObject:spriteItem];
        }
    }];
    self.sprites = sprites;
}

- (void)resetAudiosWithProtoObject:(SVGAProtoMovieEntity *)protoObject {
    NSMutableArray<SVGAAudioEntity *> *audios = [[NSMutableArray alloc] init];
    NSArray *protoAudios = [protoObject.audiosArray copy];
    [protoAudios enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[SVGAProtoAudioEntity class]]) {
            SVGAAudioEntity *audioItem = [[SVGAAudioEntity alloc] initWithProtoObject:obj];
            [audios addObject:audioItem];
        }
    }];
    self.audios = audios;
}

+ (SVGAVideoEntity *)readCache:(NSString *)cacheKey {
    dispatch_semaphore_wait(videoSemaphore, DISPATCH_TIME_FOREVER);
    SVGAVideoEntity * object = [videoCache objectForKey:cacheKey];
    if (!object) {
        object = [weakCache objectForKey:cacheKey];
    }
    dispatch_semaphore_signal(videoSemaphore);

    return  object;
}

- (void)saveCache:(NSString *)cacheKey {
    dispatch_semaphore_wait(videoSemaphore, DISPATCH_TIME_FOREVER);
    [videoCache setObject:self forKey:cacheKey];
    dispatch_semaphore_signal(videoSemaphore);
}

- (void)saveWeakCache:(NSString *)cacheKey {
    dispatch_semaphore_wait(videoSemaphore, DISPATCH_TIME_FOREVER);
    [weakCache setObject:self forKey:cacheKey];
    dispatch_semaphore_signal(videoSemaphore);
}



- (UIImage *)resizeImageIfNeed:(UIImage *)image {
    UIImage *scaledImage;
    if ((self.targetSize.width > 0 && self.targetSize.height > 0) && (self.targetSize.width < image.size.width && self.targetSize.height < image.size.height)) {
        scaledImage = SVGAImageDecodeAndScaleDownUIKit(image,self.targetSize);
        if (!scaledImage) {
            // fill
            scaledImage = [image scaleToFillSize:self.targetSize mode:0 scale:image.scale?:2];
        }
    }else {
        scaledImage = image;
    }
    return scaledImage;
}

- (BOOL)enableDebug {
    return [[SVGA shared] enableDebug];
}

@end

@interface SVGAVideoSpriteEntity()

@property (nonatomic, copy) NSString *imageKey;
@property (nonatomic, copy) NSArray<SVGAVideoSpriteFrameEntity *> *frames;
@property (nonatomic, copy) NSString *matteKey;

@end


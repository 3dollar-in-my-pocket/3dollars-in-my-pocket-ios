//
//  NMGBounds.h
//  NMGeometryFramework
//
//  Created by mrtajo on 2017. 2. 6..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGPoint;

/**
 지도에 보여지는 사각형 영역을 정의한 Bounds.
 NMGBounds는 평면직교 좌표계에 대한 클래스입니다.
 */
NMG_EXPORT
@interface NMGBounds : NSObject <NMGBoundable>

@property (nonatomic, nonnull) NMGPoint *min;
@property (nonatomic, nonnull) NMGPoint *max;

@property (nonatomic, readonly, nonnull) NMGPoint *center;
@property (nonatomic, readonly) double width;
@property (nonatomic, readonly) double height;

@property (nonatomic, readonly) double minX;
@property (nonatomic, readonly) double minY;
@property (nonatomic, readonly) double maxX;
@property (nonatomic, readonly) double maxY;

+ (nonnull instancetype)bounds;
+ (nonnull instancetype)boundsWithMinX:(double)minX minY:(double)minY maxX:(double)maxX maxY:(double)maxY;
+ (nonnull instancetype)boundsWithMinX:(double)x minY:(double)y width:(double)width height:(double)height;
+ (nonnull instancetype)boundsWithMin:(nonnull NMGPoint *)min max:(nonnull NMGPoint *)max;

- (BOOL)hasPoint:(nonnull NMGPoint *)point;
- (BOOL)hasBounds:(nonnull NMGBounds *)bounds;
- (BOOL)isIntersect:(nonnull NMGBounds *)bounds;
- (nullable NMGBounds *)intersectionWithBounds:(nonnull NMGBounds *)bounds __attribute__((warn_unused_result));
- (nonnull NMGBounds *)expandToPoint:(nonnull NMGPoint *)point __attribute__((warn_unused_result));
- (nonnull NMGBounds *)unionBounds:(nonnull NMGBounds *)bounds __attribute__((warn_unused_result));

@end

static inline NMGBounds * _Nonnull NMGBoundsMake(double minX, double minY, double maxX, double maxY) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGBounds boundsWithMinX:minX minY:minY maxX:maxX maxY:maxY];
}

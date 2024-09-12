//
//  NMGPoint.h
//  NMGeometryFramework
//
//  Created by mrtajo on 2017. 1. 11..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

/**
 평면 직교 좌표계상의 한 점을 나타내는 클래스.
 */
NMG_EXPORT
@interface NMGPoint : NSObject <NMGPointable>

@property (nonatomic) double x;
@property (nonatomic) double y;

+ (nonnull instancetype)point;
+ (nonnull instancetype)pointWithX:(double)x y:(double)y;

- (nonnull instancetype)initWithX:(double)x y:(double)y;

/**
 다른 좌표와의 거리를 구합니다.
 
 @param other 다른 좌표.
 @return 거리. 미터 단위.
 */
- (double)distanceTo:(nonnull NMGPoint *)other;

@end

static inline NMGPoint * _Nonnull NMGPointMake(double x, double y) NS_SWIFT_UNAVAILABLE("Not use in swift.") {
    return [NMGPoint pointWithX:x y:y];
}

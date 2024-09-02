//
//  NMGSegment.h
//  NMGeometryFramework
//
//  Created by mrtajo on 2017. 2. 6..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMGGeometry.h"

/**
 두 점의 집합.
 PointType에 따라 Point, LatLng로 동작합니다.
 */
NMG_EXPORT
@interface NMGSegment<__covariant PointType> : NSObject <NMGGeometry>

/**
 시작점.
 */
@property (nonatomic, nullable) PointType<NMGPointable> from;
/**
 끝점.
 */
@property (nonatomic, nullable) PointType<NMGPointable> to;

+ (nonnull instancetype)segment;
+ (nonnull instancetype)segmentFrom:(nonnull PointType)fromPoint to:(nonnull PointType)toPoint;
- (nonnull instancetype)initWithFrom:(nonnull PointType)fromPoint to:(nonnull PointType)toPoint;

@end

//
//  NMGLineString.h
//  NMGeometryFramework
//
//  Created by mrtajo on 2017. 2. 3..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGSegment;

/**
 라인스트링을 표현하는 클래스.
 */
NMG_EXPORT
@interface NMGLineString<__covariant PointType> : NSObject <NMGMultiPointable>

/**
 라인스트링을 구성하는 점의 배열.
 */
@property (nonatomic, readonly, nonnull) NSArray<PointType> *points;

/**
 라인스트링을 구성하는 NMGSegment의 배열.
 */
@property (nonatomic, readonly, nonnull) NSArray<NMGSegment *> *segments;

/**
 라인스트링이 리니어 링의 특성을 만족하는지 여부.
 
 첫 번째 점과 마지막 점이 같을 경우 `YES`입니다.
 */
@property (nonatomic, readonly) BOOL isRing;

+ (nonnull instancetype)lineString;
+ (nonnull instancetype)lineStringWithPoints:(nonnull NSArray<PointType> *)points;
- (nonnull instancetype)initWithPoints:(nonnull NSArray<PointType> *)points;

- (nullable PointType)pointAtIndex:(NSUInteger)index;
- (nullable NMGSegment *)segmentAtIndex:(NSUInteger)index;

- (void)addPoint:(nonnull PointType)point;
- (void)insertPoint:(nonnull PointType)point atIndex:(NSUInteger)index;
- (void)removePointAtIndex:(NSUInteger)index;
- (void)removePoint:(nonnull PointType)point;

- (void)convertRing;

@end

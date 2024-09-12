//
//  NMGPolygon.h
//  NMGeometryFramework
//
//  Created by Kali on 2016. 10. 13..
//  Copyright © 2016년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGLineString<__covariant PointType>;

/**
 폴리곤을 나타내는 클래스.
 */
NMG_EXPORT
@interface NMGPolygon<__covariant PointType> : NSObject <NMGGeometry>

/**
 외곽선.
 */
@property (nonatomic, nonnull) NMGLineString<PointType> *exteriorRing;

/**
 내부 홀의 배열.
 */
@property (nonatomic, readonly, nonnull) NSArray<NMGLineString<PointType> *> *interiorRings;

/**
 내부 홀의 개수.
 */
@property (nonatomic, readonly) NSUInteger interiorRingCount;

+ (nonnull NMGPolygon *)polygon;
+ (nonnull NMGPolygon *)polygonWithRing:(nonnull NMGLineString<PointType> *)exteriorRing;
+ (nonnull NMGPolygon *)polygonWithRing:(nonnull NMGLineString<PointType> *)exteriorRing interiorRings:(nonnull NSArray<NMGLineString<PointType> *> *)interiorRings;

- (nonnull instancetype)initWithRing:(nonnull NMGLineString<PointType> *)exteriorRing;
- (nonnull instancetype)initWithRing:(nonnull NMGLineString<PointType> *)exteriorRing interiorRings:(nonnull NSArray<NMGLineString<PointType> *> *)interiorRings;
- (void)addInteriorRing:(nonnull NMGLineString<PointType> *)ring;
- (void)removeInteriorRingAtIndex:(NSUInteger)index;

@end


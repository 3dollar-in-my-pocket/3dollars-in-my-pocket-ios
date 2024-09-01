//
//  NMGMultiPolygon.h
//  NMGeometryFramework
//
//  Created by Won-Young Son on 2017. 3. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import "NMGGeometry.h"

@class NMGPolygon<__covariant PointType>;

/**
 지도상의 면을 표현하는 Polygon의 집합체.
 */
NMG_EXPORT
@interface NMGMultiPolygon<__covariant PointType> : NSObject <NMGGeometry>

@property (nonatomic, readonly, nonnull) NSArray<NMGPolygon<PointType> *> *polygons;

+ (nonnull NMGMultiPolygon *)multiPolygon;
+ (nonnull NMGMultiPolygon *)multiPolygonWithPolygons:(nonnull NSArray<NMGPolygon<PointType> *> *)polygons;

- (nonnull instancetype)initWithPolygons:(nonnull NSArray<NMGPolygon<PointType> *> *)polygons;
- (void)addPolygon:(nonnull NMGPolygon *)polygon;
- (void)insertPolygon:(nonnull NMGPolygon *)polygon AtIndex:(NSInteger)index;
- (void)removePolygonAtIndex:(NSInteger)index;

@end

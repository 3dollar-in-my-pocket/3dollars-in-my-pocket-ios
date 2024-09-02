//
//  NMGGeometry
//  NMGeometryFramework
//
//  Created by Won-Young Son on 2017. 1. 10..
//  Copyright © 2017년 NAVER. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define NMG_EXPORT __attribute__((visibility ("default")))

#pragma mark NMGGeometry Protocol

@class NMGLatLng;
@protocol NMGBoundable;

@protocol NMGGeometry <NSObject>

@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, readonly, nonnull, copy) NSString *description;

@optional
@property (nonatomic, readonly, nonnull) id<NMGBoundable> bounds;
@end

@protocol NMGPointable <NMGGeometry>
@optional
- (nonnull NMGLatLng *)toLatLng;
- (BOOL)isWithinCoverage;

@end

#pragma mark - NMGMultiPointable Protocol

@protocol NMGMultiPointable <NMGGeometry>

@required
@property (nonatomic, readonly, nonnull) NSArray *points;
@property (nonatomic, readonly) NSUInteger count;
- (void)addPoint:(nonnull id)point;
- (nullable id)pointAtIndex:(NSUInteger)index;

@optional
- (void)insertPoint:(nonnull id)point atIndex:(NSUInteger)index;
- (void)removePointAtIndex:(NSUInteger)index;
- (void)removePoint:(nonnull id)point;

- (void)addCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)insertCoordinate:(CLLocationCoordinate2D)coordinate atIndex:(NSUInteger)index;

@end

#pragma mark - NMGBoundable Protocol

@protocol NMGBoundable <NMGGeometry>

- (BOOL)hasPoint:(nonnull id<NMGPointable>)point;
- (BOOL)hasBounds:(nonnull id<NMGBoundable>)bounds;
- (BOOL)isIntersect:(nonnull id<NMGBoundable>)bounds;
- (nullable id<NMGBoundable>)intersectionWithBounds:(nonnull id<NMGBoundable>)bounds __attribute__((warn_unused_result));
- (nonnull id<NMGBoundable>)expandToPoint:(nonnull id<NMGPointable>)point __attribute__((warn_unused_result));
- (nonnull id<NMGBoundable>)unionBounds:(nonnull id<NMGBoundable>)bounds __attribute__((warn_unused_result));

@end

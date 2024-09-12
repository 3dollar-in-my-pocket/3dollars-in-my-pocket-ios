#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CGBase.h>
#import <NMapsGeometry/NMapsGeometry.h>

#import "NMFFoundation.h"

NS_ASSUME_NONNULL_BEGIN

/** Defines the area spanned by an `NMFCoordinateBounds`. */
typedef struct __attribute__((objc_boxable)) NMFCoordinateSpan {
    /** Latitudes spanned by an `NMFCoordinateBounds`. */
    CLLocationDegrees latitudeDelta;
    /** Longitudes spanned by an `NMFCoordinateBounds`. */
    CLLocationDegrees longitudeDelta;
} NMFCoordinateSpan;

/* Defines a point on the map in Mercator projection for a specific zoom level. */
typedef struct __attribute__((objc_boxable)) NMFMapPoint {
    /** X coordinate representing a longitude in Mercator projection. */
    CGFloat x;
    /** Y coordinate representing  a latitide in Mercator projection. */
    CGFloat y;
    /** Zoom level at which the X and Y coordinates are valid. */
    CGFloat zoomLevel;
} NMFMapPoint;

/* Defines a 4x4 matrix. */
typedef struct NMFMatrix4 {
    double m00, m01, m02, m03;
    double m10, m11, m12, m13;
    double m20, m21, m22, m23;
    double m30, m31, m32, m33;
} NMFMatrix4;


/**
 Creates a new `NMFCoordinateSpan` from the given latitudinal and longitudinal
 deltas.
 */
NS_INLINE NMFCoordinateSpan NMFCoordinateSpanMake(CLLocationDegrees latitudeDelta, CLLocationDegrees longitudeDelta) {
    NMFCoordinateSpan span;
    span.latitudeDelta = latitudeDelta;
    span.longitudeDelta = longitudeDelta;
    return span;
}

/**
 Creates a new `NMFMapPoint` from the given X and Y coordinates, and zoom level.
 */
NS_INLINE NMFMapPoint NMFMapPointMake(CGFloat x, CGFloat y, CGFloat zoomLevel) {
    NMFMapPoint point;
    point.x = x;
    point.y = y;
    point.zoomLevel = zoomLevel;
    return point;
}

/**
 Returns `YES` if the two coordinate spans represent the same latitudinal change
 and the same longitudinal change.
 */
NS_INLINE BOOL NMFCoordinateSpanEqualToCoordinateSpan(NMFCoordinateSpan span1, NMFCoordinateSpan span2) {
    return (span1.latitudeDelta == span2.latitudeDelta &&
            span1.longitudeDelta == span2.longitudeDelta);
}

/** An area of zero width and zero height. */
extern NMF_EXPORT const NMFCoordinateSpan NMFCoordinateSpanZero;

/** 
 A quadrilateral area as measured on a two-dimensional map projection.
 `NMFCoordinateQuad` differs from `NMFCoordinateBounds` in that it allows
 representation of non-axis aligned bounds and non-rectangular quadrilaterals.
 The coordinates are described in counter clockwise order from top left.
 */
@interface NMFCoordinateQuad : NSObject
/** Coordinate at the top left corner. */
@property(nonatomic) NMGLatLng *topLeft;
/** Coordinate at the bottom left corner. */
@property(nonatomic) NMGLatLng *bottomLeft;
/** Coordinate at the bottom right corner. */
@property(nonatomic) NMGLatLng *bottomRight;
/** Coordinate at the top right corner. */
@property(nonatomic) NMGLatLng *topRight;

/**
 Creates a new `NMFCoordinateQuad` structure from the given top left,
 bottom left, bottom right, and top right coordinates.
 */
+ (nonnull instancetype)coordinateQuadWithtopLeft:(NMGLatLng *)topLeft bottomLeftlng:(NMGLatLng *)bottomLeftlng bottomRight:(NMGLatLng *)bottomRight topRight:(NMGLatLng *)topRight;

/**
 Creates a new `NMFCoordinateQuad` structure from the given `NMFCoordinateBounds`.
 The returned quad uses the bounds' northeast coordinate as the top right, and the
 southwest coordinate at the bottom left.
 */
static inline NMFCoordinateQuad * _Nonnull NMFCoordinateQuadMakeFromLatLngBounds(NMGLatLngBounds *bounds);

@end

/** Returns the area spanned by the coordinate bounds. */
NS_INLINE NMFCoordinateSpan NMFCoordinateBoundsGetCoordinateSpan(NMGLatLngBounds *bounds) {
    return NMFCoordinateSpanMake(bounds.latSpan, bounds.lngSpan);
}

/**
 Returns a coordinate bounds with southwest and northeast coordinates that are
 offset from those of the source bounds.
 */
NS_INLINE NMGLatLngBounds* NMFCoordinateBoundsOffset(NMGLatLngBounds *bounds, NMFCoordinateSpan offset) {
    NMGLatLngBounds *offsetBounds = NMGLatLngBoundsMake(bounds.southWestLat, bounds.southWestLng, bounds.northEastLat, bounds.northEastLng);
    offsetBounds.southWest.lat += offset.latitudeDelta;
    offsetBounds.southWest.lng += offset.longitudeDelta;
    offsetBounds.northEast.lat += offset.latitudeDelta;
    offsetBounds.northEast.lng += offset.longitudeDelta;
    return offsetBounds;
}

/** Returns a formatted string for the given coordinate bounds. */
NS_INLINE NSString *NMFStringFromCoordinateBounds(NMGLatLngBounds *bounds) {
    return [NSString stringWithFormat:@"{ sw = {%.1f, %.1f}, ne = {%.1f, %.1f}}",
            bounds.southWestLat, bounds.southWestLng,
            bounds.northEastLat, bounds.northEastLng];
}

/** Returns a formatted string for the given coordinate quad. */
NS_INLINE NSString *NMFStringFromCoordinateQuad(NMFCoordinateQuad *quad) {
    return [NSString stringWithFormat:@"{ topleft = {%.1f, %.1f}, bottomleft = {%.1f, %.1f}}, bottomright = {%.1f, %.1f}, topright = {%.1f, %.1f}",
            quad.topLeft.lat, quad.topLeft.lng,
            quad.bottomLeft.lat, quad.bottomLeft.lng,
            quad.bottomRight.lat, quad.bottomRight.lng,
            quad.topRight.lat, quad.topRight.lng];
}

/** Returns radians, converted from degrees. */
NS_INLINE CGFloat NMFRadiansFromDegrees(CLLocationDegrees degrees) {
    return (CGFloat)(degrees * M_PI) / 180;
}

/** Returns degrees, converted from radians. */
NS_INLINE CLLocationDegrees NMFDegreesFromRadians(CGFloat radians) {
    return radians * 180 / M_PI;
}

/** Returns Mercator projection of a WGS84 coordinate at the specified zoom level. */
extern NMF_EXPORT NMFMapPoint NMFMapPointForLatLng(NMGLatLng *coordinate, double zoomLevel);

NS_ASSUME_NONNULL_END

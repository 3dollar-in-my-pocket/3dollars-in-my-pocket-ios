#import <CoreLocation/CoreLocation.h>

#import "NMFFoundation.h"

@class NMGLatLng;
@protocol NMFLocationManagerDelegate;

NMF_EXPORT
@interface NMFLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, getter=isUpdatingLocation) BOOL updatingLocation;
@property (nonatomic, getter=isUpdatingHeading) BOOL updatingHeading;

+ (NMFLocationManager *)sharedInstance;

- (void)addDelegate:(id<NMFLocationManagerDelegate>)delegate;
- (void)removeDelegate:(id<NMFLocationManagerDelegate>)delegate;

- (CLAuthorizationStatus)locationUpdateAuthorization;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;

- (NMGLatLng *)currentLatLng;

@end

@protocol NMFLocationManagerDelegate <NSObject>

@optional

// Responding to Location Events
- (void)locationManager:(NMFLocationManager *)locationManager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(NMFLocationManager *)locationManager didFailWithError:(NSError *)error;

// Responding to Heading Events
- (void)locationManager:(NMFLocationManager *)locationManager didUpdateHeading:(CLHeading *)newHeading;
// Authorization Status Change
- (void)locationManager:(NMFLocationManager *)locationManager didChangeAuthStatus:(CLAuthorizationStatus)status;

- (void)locationManagerDidStartLocationUpdates:(NMFLocationManager *)locationManager;
- (void)locationManagerDidStartHeadingUpdates:(NMFLocationManager *)locationManager;
- (void)locationManagerBackgroundLocationUpdatesDidTimeout:(NMFLocationManager *)locationManager;
- (void)locationManagerBackgroundLocationUpdatesDidAutomaticallyPause:(NMFLocationManager *)locationManager;
- (void)locationManagerDidStopLocationUpdates:(NMFLocationManager *)locationManager;
- (void)locationManagerDidStopHeadingUpdates:(NMFLocationManager *)locationManager;


@end

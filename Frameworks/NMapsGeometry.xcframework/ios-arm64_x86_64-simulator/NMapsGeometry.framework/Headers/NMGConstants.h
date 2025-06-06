#import "NMGGeometry.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static const double NaN = 0.0 / 0.0;
static const double POSITIVE_INFINITY = 1.0 / 0.0;
static const double NEGATIVE_INFINITY = -1.0 / 0.0;

static const double HALFPI = M_PI / 2;
static const double TWOPI = M_PI * 2;

/**
 지구의 적도 반경. 미터 단위.
 */
const static double NMG_EARTH_RADIUS = 6378137;

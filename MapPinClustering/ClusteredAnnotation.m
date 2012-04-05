//
//  ClusteredAnnotation.m
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//

#import "ClusteredAnnotation.h"

@implementation ClusteredAnnotation

@synthesize title, subtitle, coordinate, clusterCoordinate, actualCoordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D) aCoordinate{
    if ( self = [super init])
    {
        // The coordinate property is really just it's current location, which is set to
        // either the clusterCoordinate or the actualCoordinate from the ClusteredMapView
        coordinate = aCoordinate;
        // Set the current cluster coordinate to the original coordinate by default
        clusterCoordinate = aCoordinate;
        // Set the actual coordinate
        actualCoordinate = aCoordinate;
    }
    return self;
}

/*
 Returns a string of the lat-lon that is used as a dictionary key lookup for the annotation
*/
- (NSString *)getKey
{
    return [NSString stringWithFormat:@"%f-%f", actualCoordinate.latitude, actualCoordinate.longitude];
}

@end
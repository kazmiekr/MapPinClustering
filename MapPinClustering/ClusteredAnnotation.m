//
//  ClusteredAnnotation.m
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import "ClusteredAnnotation.h"

@implementation ClusteredAnnotation

@synthesize title, subtitle, coordinate, clusterCoordinate, actualCoordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D) aCoordinate{
    if ( self = [super init])
    {
        coordinate = aCoordinate;
        clusterCoordinate = aCoordinate;
        actualCoordinate = aCoordinate;
    }
    return self;
}

- (NSString *)getKey
{
    return [NSString stringWithFormat:@"%f-%f", actualCoordinate.latitude, actualCoordinate.longitude];
}

@end
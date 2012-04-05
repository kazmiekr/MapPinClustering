//
//  ClusteringMapView.h
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ClusteringMapView : MKMapView<MKMapViewDelegate>

@property (nonatomic,assign) id<MKMapViewDelegate> delegate;

- (void)centerMapOnAnnotationSet:(NSArray *)annotations;

@end

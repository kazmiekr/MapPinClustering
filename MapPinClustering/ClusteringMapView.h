//
//  ClusteringMapView.h
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ClusteringMapView : MKMapView<MKMapViewDelegate>

@property (nonatomic,assign) id<MKMapViewDelegate> delegate;

- (void)centerMapOnAnnotationSet:(NSArray *)annotations;

@end

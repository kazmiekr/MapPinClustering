//
//  ClusteringMapView.m
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//

#import "ClusteringMapView.h"
#import "ClusteredAnnotation.h"

@interface ClusteringMapView ()
- (BOOL)mapViewDidZoom;
- (void)updatePinClusters;
- (void)setup;
@end

@implementation ClusteringMapView
{
    BOOL hasLoaded;
    double zoomLevel;
    double priorZoomLevel;
    NSMutableArray *coordSet;
    NSMutableDictionary *coordDict;
    NSMutableDictionary *visiblePins;
    NSTimeInterval interval;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // Initialization code
    super.delegate = self;
    coordSet = [[NSMutableArray alloc] init];
    coordDict = [[NSMutableDictionary alloc] init];
    visiblePins = [[NSMutableDictionary alloc] init];
    interval = 0.5;
}

#pragma mark - MKMapViewDelegate methods

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinView = nil;
    if ( annotation != mapView.userLocation )
    {
        static NSString *defaultPin = @"pin";
        
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPin];
        
        if ( pinView == nil )
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPin];
        
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = NO; 
        pinView.hidden = YES;
        pinView.canShowCallout = YES;
    }
    return pinView;
}


- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    if ( hasLoaded == NO && [views count] > 1 )
    {
        hasLoaded = YES;
        [self updatePinClusters];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if ( [self mapViewDidZoom] && hasLoaded == YES )
    {
        [self updatePinClusters];
    }
    
    if( [delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)] )
    {
        [delegate mapView:mapView regionDidChangeAnimated:animated];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if( [delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)] )
    {
        [delegate mapViewDidFinishLoadingMap:mapView];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if( [delegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)] )
    {
        [delegate mapView:mapView didDeselectAnnotationView:view];
    }
}

#pragma mark - Utility methods

- (void)updatePinClusters
{
    [coordSet removeAllObjects];
    [coordDict removeAllObjects];
    
    for ( NSString *key in visiblePins )
    {
        ClusteredAnnotation *ca = [visiblePins objectForKey:key];
        MKAnnotationView *cav = [self viewForAnnotation:ca];
        cav.hidden = NO;
    }
    
    // Loop over location and upate visibility
    for ( ClusteredAnnotation *annotation in [self annotations] )
    {
        MKAnnotationView *av = [self viewForAnnotation:annotation];
        
        CGPoint point = [self convertCoordinate:annotation.coordinate toPointToView:nil];
        CGPoint roundedPoint;
        
        int distance = 75;
        
        roundedPoint.x = roundf(point.x/distance)*distance;
        roundedPoint.y = roundf(point.y/distance)*distance;
        
        // Convert the point to a value so we can stick it in the array
        NSValue *value = [NSValue valueWithCGPoint:roundedPoint];
        
        if ( zoomLevel < priorZoomLevel )
        {
            BOOL foundMatch = ([visiblePins objectForKey:[annotation getKey]] != nil ) ? YES : NO;

            if ( foundMatch == YES )
            {
                [coordDict setObject:annotation forKey:value];
                [coordSet addObject:value];
                annotation.coordinate = annotation.actualCoordinate;
                annotation.clusterCoordinate = annotation.actualCoordinate;
                continue;
            }
        }
        
        // Object is already displayed, set the cluster center
        if([coordSet containsObject:value])
        {
            ClusteredAnnotation *clusterCenter = [coordDict objectForKey:value];
            
            annotation.clusterCoordinate = clusterCenter.coordinate;
            
            [UIView animateWithDuration:interval animations:^{
                annotation.coordinate = annotation.clusterCoordinate;
            } completion:^(BOOL finished) {
                av.hidden = YES;
                [visiblePins removeObjectForKey:[annotation getKey]];
                annotation.coordinate = annotation.actualCoordinate;
            }];
        }
        // Display the item
        else
        {
            [coordDict setObject:annotation forKey:value];
            
            if ( av != nil )
                [visiblePins setValue:annotation forKey:[annotation getKey]];
            
            av.hidden = NO;
            
            [coordSet addObject:value];
            
            // Set the coordinate based on it's clusterCoordinate and update it to it's actual location
            annotation.coordinate = annotation.clusterCoordinate;
            annotation.clusterCoordinate = annotation.actualCoordinate;
            
            [UIView animateWithDuration:interval animations:^{
                annotation.coordinate = annotation.actualCoordinate;
            } completion:^(BOOL finished) {
                annotation.coordinate = annotation.actualCoordinate;
            }];
        }
    }
    priorZoomLevel = zoomLevel;
}

- (BOOL)mapViewDidZoom
{
    if( zoomLevel == self.visibleMapRect.size.width * self.visibleMapRect.size.height )
    {
        zoomLevel = self.visibleMapRect.size.width * self.visibleMapRect.size.height;
        return NO;
    }
    zoomLevel = self.visibleMapRect.size.width * self.visibleMapRect.size.height;
    return YES;
}

- (void)centerMapOnAnnotationSet:(NSArray *)annotations
{
    float minLng = 0;
    float maxLng = 0; 
    float minLat = 0;
    float maxLat = 0;
    
    for ( ClusteredAnnotation *annotation in annotations )
    {
        if ( minLat == 0 || annotation.coordinate.latitude < minLat )
            minLat = annotation.coordinate.latitude;
        if ( maxLat == 0 || annotation.coordinate.latitude > maxLat )
            maxLat = annotation.coordinate.latitude;
        
        if ( minLng == 0 || annotation.coordinate.longitude < minLng )
            minLng = annotation.coordinate.longitude;
        if ( maxLng == 0 || annotation.coordinate.longitude > maxLng )
            maxLng = annotation.coordinate.longitude;
    }
    
    float mapPadding = 1.1;
    float minVisLat = 0.01;
    
    MKCoordinateRegion region;
    region.center.latitude = (minLat + maxLat) / 2;
    region.center.longitude = (minLng + maxLng) / 2;
    
    region.span.latitudeDelta = (maxLat - minLat) * mapPadding;
    
    region.span.latitudeDelta = (region.span.latitudeDelta < minVisLat) ? minVisLat : region.span.latitudeDelta;
    
    region.span.longitudeDelta = (maxLng - minLng) * mapPadding;
    
    MKCoordinateRegion scaledRegion = [self regionThatFits:region];
    [self setRegion:scaledRegion animated:YES];
}

@end

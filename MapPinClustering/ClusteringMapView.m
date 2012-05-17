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
    // Flag to track if the annotations have initially loaded
    BOOL hasLoaded;
    // The current zoom level of the map
    double zoomLevel;
    // The previous zoom level of the map to track if we zoom in or out
    double priorZoomLevel;
    // A collection coordinates currently visible, it gets reset on every zoom change
    NSMutableArray *coordSet;
    // A dictionary of coordinates used to assign the clustered coordinate to non-visible pins
    NSMutableDictionary *coordDict;
    // A dictionary of visible pins that persist between zoom changes
    NSMutableDictionary *visiblePins;
    // Animation time interval
    NSTimeInterval interval;
    // Pixels for block clustering
    int distance;
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
    // Set itself as the delegate so we can operate on the messages
    super.delegate = self;
    // Init our collections
    coordSet = [[NSMutableArray alloc] init];
    coordDict = [[NSMutableDictionary alloc] init];
    visiblePins = [[NSMutableDictionary alloc] init];
    // Set the animation duration
    interval = 0.5;
    // Set the pixel distance used for block clustering
    distance = 75;
}

#pragma mark - MKMapViewDelegate methods

#pragma mark - Responding to Map Position Changes

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if ( [delegate respondsToSelector:@selector(mapView:regionWillChangeAnimated:)] )
        [delegate mapView:mapView regionWillChangeAnimated:animated];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // Only update the pins if the map zoomed and we've already loaded the annotations
    if ( [self mapViewDidZoom] && hasLoaded == YES )
    {
        [self updatePinClusters];
    }
    
    if ( [delegate respondsToSelector:@selector(mapView:regionDidChangeAnimated:)] )
        [delegate mapView:mapView regionDidChangeAnimated:animated];
}

#pragma mark - Loading the Map Data

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    if ( [delegate respondsToSelector:@selector(mapViewWillStartLoadingMap:)] )
        [delegate mapViewWillStartLoadingMap:mapView];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if ( [delegate respondsToSelector:@selector(mapViewDidFinishLoadingMap:)] )
        [delegate mapViewDidFinishLoadingMap:mapView];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    if ( [delegate respondsToSelector:@selector(mapViewDidFailLoadingMap:withError:)] )
        [delegate mapViewDidFailLoadingMap:mapView withError:error];
}

#pragma mark - Tracking the User Location

- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    if ( [delegate respondsToSelector:@selector(mapViewWillStartLocatingUser:)] )
        [delegate mapViewWillStartLocatingUser:mapView];
}

- (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
    if ( [delegate respondsToSelector:@selector(mapViewDidStopLocatingUser:)] )
        [delegate mapViewDidStopLocatingUser:mapView];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ( [delegate respondsToSelector:@selector(mapView:didUpdateUserLocation:)] )
        [delegate mapView:mapView didUpdateUserLocation:userLocation];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    if ( [delegate respondsToSelector:@selector(mapView:didFailToLocateUserWithError:)] )
        [delegate mapView:mapView didFailToLocateUserWithError:error];
}

- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    if ( [delegate respondsToSelector:@selector(mapView:didChangeUserTrackingMode:animated:)] )
        [delegate mapView:mapView didChangeUserTrackingMode:mode animated:animated];
}

#pragma mark - Managing Annotation Views

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ( [delegate respondsToSelector:@selector(mapView:viewForAnnotation:)] )
    {
        // Get the view from the delegate
        MKAnnotationView *view = [delegate mapView:mapView viewForAnnotation:annotation];
        // We need them to start off in the hidden position
        view.hidden = YES;
        return view;
    };
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    // We only want to update the pin clusters when the annotations aren't the user's current location
    if ( hasLoaded == NO && [views count] > 1 )
    {
        hasLoaded = YES;
        [self updatePinClusters];
    }
    else if ( hasLoaded == NO && [views count] == 1 )
    {
        MKAnnotationView *av = [views objectAtIndex:0];
        id<MKAnnotation> annotation = av.annotation;
        if (annotation != mapView.userLocation) {
            hasLoaded = YES;
            [self updatePinClusters];
        }
    }

    if ( [delegate respondsToSelector:@selector(mapView:didAddAnnotationViews:)] )
        [delegate mapView:mapView didAddAnnotationViews:views];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ( [delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)] )
        [delegate mapView:mapView annotationView:view calloutAccessoryControlTapped:control];
}

#pragma mark - Dragging an Annotation View

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if ( [delegate respondsToSelector:@selector(mapView:annotationView:didChangeDragState:fromOldState:)] )
    [delegate mapView:mapView annotationView:view didChangeDragState:newState fromOldState:oldState];
}

#pragma mark - Selecting Annotation Views

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ( [delegate respondsToSelector:@selector(mapView:didDeselectAnnotationView:)] )
        [delegate mapView:mapView didDeselectAnnotationView:view];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ( [delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)] )
        [delegate mapView:mapView didSelectAnnotationView:view];
}

#pragma mark - Selecting Annotation Views

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ( [delegate respondsToSelector:@selector(mapView:viewForOverlay:)] )
        return [delegate mapView:mapView viewForOverlay:overlay];
    return nil;
}

- (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
{
    if ( [delegate respondsToSelector:@selector(mapView:didAddOverlayViews:)] )
        [delegate mapView:mapView didAddOverlayViews:overlayViews];
}

#pragma mark - Utility methods

/*
 Utility method to handle the clustering of the pins
*/
- (void)updatePinClusters
{
    // Clear our collections as we'll reprocess them
    [coordSet removeAllObjects];
    [coordDict removeAllObjects];
    
    // Even though we're reprocessing the pins, we want to ensure that any pins that
    // were visible prior to this zoom are still visible.
    for ( NSString *key in visiblePins )
    {
        ClusteredAnnotation *ca = [visiblePins objectForKey:key];
        MKAnnotationView *cav = [self viewForAnnotation:ca];
        cav.hidden = NO;
    }
    
    // Loop over location and upate visibility
    for ( ClusteredAnnotation *annotation in [self annotations] )
    {
        // Skip over the MKUserLocation annotation
        if ( [annotation isKindOfClass:[MKUserLocation class]] )
            continue;
        
        // Get the annotation view for the annotaiton
        MKAnnotationView *av = [self viewForAnnotation:annotation];
        // Get the x/y point of the annotation
        CGPoint point = [self convertCoordinate:annotation.coordinate toPointToView:nil];
        CGPoint roundedPoint;
        // Calculate the block this point belongs to
        roundedPoint.x = roundf(point.x/distance)*distance;
        roundedPoint.y = roundf(point.y/distance)*distance;
        
        // Convert the point to a value so we can stick it in the array
        NSValue *value = [NSValue valueWithCGPoint:roundedPoint];
        
        // If we are zooming in, we want to ensure that the prior visible pins
        // stay visible, and then we'll process the others.  The issue here is
        // that we're using essential random blocks of distance pixels which
        // doesn't guarantee that after a zoom it'll pick the same pin to display
        if ( zoomLevel < priorZoomLevel )
        {
            // Is there an existing visible pin for this annotation?
            BOOL foundMatch = ([visiblePins objectForKey:[annotation getKey]] != nil ) ? YES : NO;

            if ( foundMatch == YES )
            {
                // Add our point to our collections and lookups
                [coordDict setObject:annotation forKey:value];
                [coordSet addObject:value];
                
                //since we're re-doing the clustering
                [annotation removeAllChildren];
                
                // Ensure the annotation is using it's actualCoordinate
                annotation.coordinate = annotation.actualCoordinate;
                annotation.clusterCoordinate = annotation.actualCoordinate;
                // Skip processing this annotation
                continue;
            }
        }
        
        // Object is already displayed, set the cluster center and hide it
        if([coordSet containsObject:value])
        {
            // Find the visible pin to associate this pin to
            ClusteredAnnotation *clusterCenter = [coordDict objectForKey:value];
            // Set it's clustered point
            annotation.clusterCoordinate = clusterCenter.coordinate;
            
            //add the pin to the cluster's children array
            [clusterCenter addChild:annotation];
            //clear the children for the newly created child
            [annotation removeAllChildren];
            
            // Animate the movement of the pin to it's cluster point.  This is
            // visible during zoom out operations
            [UIView animateWithDuration:interval animations:^{
                annotation.coordinate = annotation.clusterCoordinate;
            } completion:^(BOOL finished) {
                av.hidden = YES;
                [visiblePins removeObjectForKey:[annotation getKey]];
                // When we're done animating, we'll reset it's coordinate in the hidden state
                annotation.coordinate = annotation.actualCoordinate;
            }];
        }
        // Display the item
        else
        {
            // Add this point as the cluster point for any points for this location box
            [coordDict setObject:annotation forKey:value];
            
            // Add it to the visible pin collection
            if ( av != nil )
                [visiblePins setValue:annotation forKey:[annotation getKey]];
            
            // Make it visible
            av.hidden = NO;
            
            [coordSet addObject:value];
            
            // Set the coordinate based on it's clusterCoordinate and update it to it's actual location
            annotation.coordinate = annotation.clusterCoordinate;
            annotation.clusterCoordinate = annotation.actualCoordinate;
            
            //since this is a newly created cluster pin
            //removing all the child pins
            [annotation removeAllChildren];
            
            // Animate the pin from it's cluster point to it's actual location
            [UIView animateWithDuration:interval animations:^{
                annotation.coordinate = annotation.actualCoordinate;
            } completion:^(BOOL finished) {}];
        }
    }
    priorZoomLevel = zoomLevel;
}

/*
 Clever way to determine map zooms as it's a bit tricky if you try to watch the current lat/lon
 deltas.
 
 This was taken from the revolver.be example for his REVClusterMapView
*/
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

/*
 Utility method to center the map based on an array of annotations.
*/
- (void)centerMapOnAnnotationSet:(NSArray *)annotations
{
    float minLng = 0;
    float maxLng = 0; 
    float minLat = 0;
    float maxLat = 0;
    
    // Collect the min/max lat/lons
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
    
    // Create a span based on those lat/lons and apply a bit of padding
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

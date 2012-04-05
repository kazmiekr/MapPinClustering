//
//  ViewController.m
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//

#import "ViewController.h"
#import "ClusteredAnnotation.h"
#import "ClusteringMapView.h"

@interface ViewController ()
- (void)loadLocations;
@end

@implementation ViewController {
    NSMutableArray *locations;
}

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        locations = [[NSMutableArray alloc] init];
    }
    return self;
}

# pragma mark - View methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Load up our locations
    [self loadLocations];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

# pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id<MKAnnotation>)annotation
{
    // Create out mapView annotation
    MKPinAnnotationView *pinView = nil;
    if ( annotation != map.userLocation )
    {
        static NSString *defaultPin = @"pin";
        
        pinView = (MKPinAnnotationView *)[map dequeueReusableAnnotationViewWithIdentifier:defaultPin];
        
        if ( pinView == nil )
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPin];
        
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = NO; 
        pinView.canShowCallout = YES;
    }
    return pinView;
}

# pragma mark - Utility methods

- (void)loadLocations
{
    // Load up our locations from the locations.plist file that contains a few lat/lat records
    // around the boston area.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"plist"];
    NSDictionary *locationList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    // Loop over the locations and create an annotation record for them using the special
    // ClusteredAnnotation class
    for ( NSDictionary *d in locationList )
    {
        NSDictionary *dLoc = [locationList objectForKey:d];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[dLoc valueForKey:@"lat"] doubleValue], [[dLoc valueForKey:@"lon"] doubleValue]);
        ClusteredAnnotation *annotation = [[ClusteredAnnotation alloc] initWithCoordinate:location];
        // Name these to whatever you want really
        annotation.title = @"Pin";
        annotation.subtitle = @"Subtitle";
        
        [locations addObject:annotation];
    }
    
    // Center out map on our locations
    [mapView centerMapOnAnnotationSet:locations];
    // Add our annotations to the map
    [mapView addAnnotations:locations];
}

@end

//
//  ViewController.m
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLocations];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)loadLocations
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"locations" ofType:@"plist"];
    NSDictionary *locationList = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    for ( NSDictionary *d in locationList )
    {
        NSDictionary *dLoc = [locationList objectForKey:d];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[dLoc valueForKey:@"lat"] doubleValue], [[dLoc valueForKey:@"lon"] doubleValue]);
        ClusteredAnnotation *annotation = [[ClusteredAnnotation alloc] initWithCoordinate:location];
        annotation.title = @"Pin";
        annotation.subtitle = @"Subtitle";
        
        [locations addObject:annotation];
    }
    
    [mapView centerMapOnAnnotationSet:locations];
    [mapView addAnnotations:locations];
}

@end

//
//  ViewController.h
//  MapPinClustering
//
//  Created by Kevin Kazmierczak on 4/5/12.
//  Copyright (c) 2012 Universal Mind, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class ClusteringMapView;

@interface ViewController : UIViewController <MKMapViewDelegate>{
    ClusteringMapView *mapView;
}

@property (nonatomic, strong) IBOutlet ClusteringMapView *mapView;

@end
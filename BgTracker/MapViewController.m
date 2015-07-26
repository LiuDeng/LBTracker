//
//  MapViewController.m
//  BgTracker
//
//  Created by Gong Zhang on 2015/6/22.
//  Copyright © 2015年 Gong Zhang. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "LBLocationCenter.h"

@interface MapViewController () <MKMapViewDelegate, LBLocationCenterDelegate>
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) LBLocationCenter *locationCenter;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationCenter = [LBLocationCenter sharedLocationCenter];
    [self.mapView addAnnotations:self.locationCenter.locationRecords];
    [self.locationCenter addDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSArray *records = self.locationCenter.locationRecords;
    if (records.count > 0) {
        [self moveToRecord:records[0]];
    }
}

- (void)moveToRecord:(LBLocationRecord*)record {
    MKCoordinateRegion region = MKCoordinateRegionMake(record.coordinate, MKCoordinateSpanMake(0.01, 0.01));
    [self.mapView setRegion:region animated:YES];
}

- (void)locationCenter:(LBLocationCenter*)locationCenter didInsertRecordAtIndex:(NSUInteger)index {
    [self.mapView addAnnotation:self.locationCenter.locationRecords[index]];
}

- (void)locationCenterDidClearAllData:(LBLocationCenter*)locationCenter {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- ( MKAnnotationView *)mapView:( MKMapView *)mapView viewForAnnotation:( id<MKAnnotation>)annotation {
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    if ([annotation isKindOfClass:[LBLocationRecord  class]]) {
        MKPinAnnotationView *view = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:@"pin_view"];
        if (view == nil) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin_view"];
            view.canShowCallout = YES;
        } else {
            view.annotation = annotation;
        }
        return view;
    }
    
    return nil;
}

@end

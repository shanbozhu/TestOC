//
//  PBAnnotationView.h
//  TestOC
//
//  Created by DaMaiIOS on 2017/12/24.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PBAnnotationView;
@protocol PBAnnotationViewDelegate <NSObject>

- (void)annotationView:(PBAnnotationView *)annotationView andAnnotation:(id<MKAnnotation>)annotation;

@end

@interface PBAnnotationView : MKAnnotationView

@property (nonatomic, weak) id<PBAnnotationViewDelegate>delegate;

+ (id)annotationViewWithMapView:(MKMapView *)mapView andAnnotation:(id<MKAnnotation>)annotation;

@end

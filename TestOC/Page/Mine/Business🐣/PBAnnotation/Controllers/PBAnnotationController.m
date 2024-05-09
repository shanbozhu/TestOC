//
//  PBAnnotationController.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAnnotationController.h"
#import <MapKit/MapKit.h>
#import "PBAnnotation.h"
#import "PBAnnotationView.h"

@interface PBAnnotationController ()<MKMapViewDelegate, PBAnnotationViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) id<MKAnnotation> annotation;

@end

@implementation PBAnnotationController

- (void)requestData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *path = [[NSBundle mainBundle]pathForResource:@"pbannotation_info" ofType:@"json"];
        //NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *jsonStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"jsonDict = %@", jsonDict);
        
        NSArray *dataArr = jsonDict[@"data"];
        
        NSMutableArray *objs = [NSMutableArray array];
        for (NSDictionary *dict in dataArr) {
            PBAnnotation *annotation = [[PBAnnotation alloc]init];
            
            CLLocationDegrees latitude = [dict[@"coordinate"][@"latitute"] doubleValue];
            CLLocationDegrees longitude = [dict[@"coordinate"][@"longitude"] doubleValue];
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            annotation.title = dict[@"title"];
            annotation.subtitle = dict[@"subtitle"];
            
            [objs addObject:annotation];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 添加标注
            [self.mapView addAnnotations:objs];
            
            // 可视区域
            PBAnnotation *annotation = [objs firstObject];
            MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
            
            MKCoordinateRegion coordinateRegion = MKCoordinateRegionMake(annotation.coordinate, span);
            [self.mapView setRegion:coordinateRegion animated:YES];
            
            // 设置选中标注
            [self.mapView selectAnnotation:annotation animated:YES];
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // longitude 经度
    // latitude 纬度
    
    // 定位授权
    CLLocationManager *manager = [[CLLocationManager alloc]init];
    self.manager = manager;
    [manager requestWhenInUseAuthorization];
    
    // mapView
    MKMapView *mapView = [[MKMapView alloc]init];
    self.mapView = mapView;
    [self.view addSubview:mapView];
    mapView.frame = CGRectMake(0, APPLICATION_NAVIGATIONBAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APPLICATION_NAVIGATIONBAR_HEIGHT);
    
    mapView.showsUserLocation = YES;
    mapView.showsScale = YES;
    mapView.userTrackingMode = MKUserTrackingModeNone;
    mapView.mapType = MKMapTypeStandard;
    
    mapView.delegate = self;
    
    [self requestData];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // 反地理编码:根据经纬度查找地名
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count == 0 || error != nil) {
            NSLog(@"找不到位置");
            return;
        }
        
        CLPlacemark *placemark = placemarks.firstObject;
        
        // 用户位置的经纬度
        NSLog(@"longitude = %lf, latitude = %lf", placemark.location.coordinate.longitude, placemark.location.coordinate.latitude);
        
        // 区域名称
        userLocation.title = placemark.locality;
        // 详情名称
        userLocation.subtitle = placemark.name;
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    NSLog(@"annotation.title = %@", annotation.title);
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil; // 显示系统默认的 用户大头针
    }
    
    // 自定义大头针
    PBAnnotationView *annotationView = [PBAnnotationView annotationViewWithMapView:mapView andAnnotation:annotation];
    annotationView.delegate = self;
    
    return annotationView;
    
    /**
    // 地点大头针
    MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MKPinAnnotationView"];
    if (!pinAnnotationView) {
        pinAnnotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"MKPinAnnotationView"];
    }

    //pinAnnotationView.annotation = annotation;
    pinAnnotationView.canShowCallout = YES;
    pinAnnotationView.animatesDrop = YES;
    pinAnnotationView.rightCalloutAccessoryView = [self detailBtn];
    pinAnnotationView.pinTintColor = [UIColor yellowColor];

    return pinAnnotationView;
     */
}

- (UIButton *)detailBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"详情" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    return btn;
}

- (void)annotationView:(PBAnnotationView *)annotationView andAnnotation:(id<MKAnnotation>)annotation {
    self.annotation = annotation;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:[NSString stringWithFormat:@"导航到 %@", annotation.title] delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        [actionSheet addButtonWithTitle:@"百度地图"];
    }
    if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        [actionSheet addButtonWithTitle:@"高德地图"];
    }
    [actionSheet addButtonWithTitle:@"苹果地图"];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *mapName = [actionSheet buttonTitleAtIndex:buttonIndex];
    NSLog(@"buttonIndex = %ld, mapName = %@", buttonIndex, mapName);
    
    if ([mapName isEqualToString:@"苹果地图"]) {
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:self.annotation.coordinate addressDictionary:nil];
        MKMapItem *aimLocation = [[MKMapItem alloc]initWithPlacemark:placemark];
        
        [MKMapItem openMapsWithItems:@[currentLocation, aimLocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
    }
    
    if ([mapName isEqualToString:@"百度地图"]) {
        NSString *urlStr = [NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02", self.annotation.coordinate.latitude, self.annotation.coordinate.longitude];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]];
    }
    
    if ([mapName isEqualToString:@"高德地图"]) {
        NSString *urlStr = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2", @"TestOC", @"TestOCAAA", self.annotation.coordinate.latitude, self.annotation.coordinate.longitude];
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlStr]];
    }
}

- (void)dealloc {
    NSLog(@"PBAnnotationController对象被释放了");
}

@end

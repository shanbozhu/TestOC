//
//  PBAnnotationView.m
//  TestBundle
//
//  Created by DaMaiIOS on 2017/12/24.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBAnnotationView.h"

@interface PBAnnotationView ()

@property (nonatomic, strong) id<MKAnnotation> at;

@end

@implementation PBAnnotationView

+ (id)annotationViewWithMapView:(MKMapView *)mapView andAnnotation:(id<MKAnnotation>)annotation {
    PBAnnotationView *annotationView = (PBAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MKAnnotationView"];
    if (annotationView == nil) {
        annotationView = [[self alloc]initWithAnnotation:annotation reuseIdentifier:@"MKAnnotationView"];
        //annotationView.image = [UIImage imageNamed:@"pbaddress_location"];
    }
    return annotationView;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.at = annotation;
        
        // calloutView
        UIView *calloutView = [[UIView alloc]init];
        [self addSubview:calloutView];
        calloutView.backgroundColor = [UIColor whiteColor];
        calloutView.layer.cornerRadius = 5;
        calloutView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(calloutBtnClick:)];
        [calloutView addGestureRecognizer:tap];
        
        // titleLab
        UILabel *titleLab = [[UILabel alloc]init];
        [calloutView addSubview:titleLab];
        titleLab.frame = CGRectMake(10, 10, 200, 100);
        titleLab.font = [UIFont systemFontOfSize:13];
        titleLab.text = annotation.title;
        titleLab.numberOfLines = 2;
        [titleLab sizeToFit];
        //titleLab.backgroundColor = [UIColor lightGrayColor];
        
        // subtitleLab
        UILabel *subtitleLab = [[UILabel alloc]init];
        [calloutView addSubview:subtitleLab];
        subtitleLab.frame = CGRectMake(10, CGRectGetMaxY(titleLab.frame)+5, 200, 100);
        subtitleLab.font = [UIFont systemFontOfSize:11];
        subtitleLab.numberOfLines = 2;
        subtitleLab.text = annotation.subtitle;
        [subtitleLab sizeToFit];
        //subtitleLab.backgroundColor = [UIColor lightGrayColor];
        
        CGFloat width = CGRectGetMaxX(subtitleLab.frame)+10;
        if (CGRectGetMaxX(titleLab.frame) > CGRectGetMaxX(subtitleLab.frame)) {
            width = CGRectGetMaxX(titleLab.frame)+10;
        }
        
        calloutView.frame = CGRectMake(0, 0, width, CGRectGetMaxY(subtitleLab.frame)+10);
        
        // pinImageView
        UIImageView *pinImageView = [[UIImageView alloc]init];
        [self addSubview:pinImageView];
        pinImageView.frame = CGRectMake((width-37)/2.0, CGRectGetMaxY(calloutView.frame)+10, 37, 37);
        pinImageView.image = [UIImage imageNamed:@"pbaddress_location"];
        pinImageView.contentMode = UIViewContentModeCenter;
        //pinImageView.backgroundColor = [UIColor lightGrayColor];
        
        self.frame = CGRectMake(0, 0, width, CGRectGetMaxY(pinImageView.frame));
    }
    return self;
}

- (void)calloutBtnClick:(UIButton *)btn {
    NSLog(@"点击导航");
    [self.delegate annotationView:self andAnnotation:self.at];
}

@end

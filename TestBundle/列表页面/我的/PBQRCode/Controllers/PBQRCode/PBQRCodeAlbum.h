//
//  PBQRCodeAlbum.h
//  TestBundle
//
//  Created by DaMaiIOS on 17/8/31.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PBQRCodeAlbum;
@protocol PBQRCodeAlbumDelegate <NSObject>

- (void)qrCodeAlbum:(PBQRCodeAlbum *)qrCodeAlbum andDidFinishPickingMediaWithResult:(NSString *)result;

@end

@interface PBQRCodeAlbum : NSObject

@property (nonatomic, weak) id<PBQRCodeAlbumDelegate> delegate;

+ (id)sharedQRCodeAlbum;

- (void)qrCodeAlbumWithCurrentController:(UIViewController *)currentController;

@end

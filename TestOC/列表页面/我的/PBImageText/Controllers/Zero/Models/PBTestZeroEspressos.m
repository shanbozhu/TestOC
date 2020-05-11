//
//  PBTestZeroEspressos.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestZeroEspressos.h"
#import <YYText/YYText.h>
#import "UIImageView+WebCache.h"

#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface PBTestZeroEspressos ()

@property (nonatomic, copy) NSMutableAttributedString *lastAttributedString;

@end


@implementation PBTestZeroEspressos

- (NSMutableArray *)imageObjs {
    if (_imageObjs == nil) {
        _imageObjs = [NSMutableArray array];
    }
    return _imageObjs;
}

+ (id)testZeroEspressosWithHtmlStr:(NSString *)htmlStr {
    return [[self alloc] initWithHtmlStr:htmlStr];
}

- (id)initWithHtmlStr:(NSString *)htmlStr {
    if ([super init]) {
        // 替换为能够识别的标签
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<div" withString:@"<p"];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"div>" withString:@"p>"];
        
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<span" withString:@"<strong"];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"span>" withString:@"strong>"];
        
        {
            NSMutableArray *objs = [NSMutableArray array];
            
            NSArray *tmpArr = [htmlStr componentsSeparatedByString:@"<p>"];
            for (NSString *tmpStr in tmpArr) {
                NSArray *arr = [tmpStr componentsSeparatedByString:@"</p>"];
                [objs addObjectsFromArray:arr];
            }
            NSLog(@"objs = %@", objs);
            
            NSMutableString *tmpHtmlStr = [NSMutableString string];
            for (int i = 0; i < objs.count; i++) {
                NSString *tmpStr = [NSString stringWithFormat:@"<p>%@</p>", objs[i]];
                [tmpHtmlStr appendString:tmpStr];
            }
            NSLog(@"tmpHtmlStr = %@", tmpHtmlStr);
            
            htmlStr = tmpHtmlStr;
        }
        
        TFHpple *hpple = [[TFHpple alloc]initWithHTMLData:[htmlStr dataUsingEncoding:NSUTF8StringEncoding]];
        NSArray *pEle = [hpple searchWithXPathQuery:@"//p"];
        
        // pEle表示所有p标签组成的数组
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]init];
        
        NSMutableArray *imageArr = [NSMutableArray array];
        NSMutableArray *imageViewArr = [NSMutableArray array];
        
        for (TFHppleElement *hppleEle in pEle) { // 每执行一次此循环,会换一次行
            // hppleEle表示所有p标签组成的数组中的其中一个p标签
            
            self.lastAttributedString = attributedString.copy;
            
            for (int i = 0; i < hppleEle.children.count; i++) {
                TFHppleElement *ele = hppleEle.children[i];
                
                // 去除首尾空格和换行
                //NSString *content = [ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([ele.tagName isEqualToString:@"text"]) {
                    NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                    [tmpStr yy_setColor:UIColorFromRGB(0x666666) range:NSMakeRange(0, tmpStr.length)];
                    [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                    
                    [attributedString appendAttributedString:tmpStr];
                }
                
                if ([ele.tagName isEqualToString:@"strong"]) {
                    // strong->img
                    for (int j = 0; j < ele.children.count; j++) {
                        TFHppleElement *elee = ele.children[j];
                        
                        if ([elee.tagName isEqualToString:@"text"]) {
                            NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                            [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setColor:[UIColor redColor] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                            
                            [attributedString appendAttributedString:tmpStr];
                        }
                        
                        if ([elee.tagName isEqualToString:@"img"]) {
                            CGFloat height = [elee.attributes[@"height"] floatValue];
                            CGFloat width = [elee.attributes[@"width"] floatValue];
                            
                            CGFloat imageViewW = [UIScreen mainScreen].bounds.size.width-20;
                            CGFloat imageViewH = 0;
                            if (width != 0 && height != 0) {
                                imageViewH = (imageViewW/width) * height;
                            } else {
                                imageViewH = (0.618) * imageViewW;
                            }
                            
                            PBContentModel *contentModel = [[PBContentModel alloc]init];
                            contentModel.isImg = YES;
                            contentModel.src = elee.attributes[@"src"];
                            contentModel.imgWidth = imageViewW;
                            contentModel.imgHeight = imageViewH;
                                                        
                            [imageArr addObject:elee.attributes[@"src"]];
                        
                            {
                                UIImageView *imageView = [[UIImageView alloc]init];
                                imageView.frame = CGRectMake(0, 0, imageViewW, imageViewH);
                                imageView.backgroundColor = [UIColor lightGrayColor];
                                [imageView sd_setImageWithURL:[NSURL URLWithString:contentModel.src]];
                                imageView.layer.cornerRadius = 10;
                                imageView.layer.masksToBounds = YES;
                                imageView.userInteractionEnabled = YES;
                                
                                [imageViewArr addObject:imageView];
                                
                                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
                                [imageView addGestureRecognizer:tap];
                                tap.view.tag = imageArr.count-1;
                                
                                NSMutableAttributedString *tmpStr = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:[UIFont boldSystemFontOfSize:13] alignment:YYTextVerticalAlignmentCenter];
                                [tmpStr yy_setLineSpacing:10 range:tmpStr.yy_rangeOfAll];
                                
                                [attributedString appendAttributedString:tmpStr];
                            }
                        }
                        
                        if ([elee.tagName isEqualToString:@"a"]) {
                            NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                            [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                            
                            [attributedString appendAttributedString:tmpStr];
                        }
                    }
                }
                
                if ([ele.tagName isEqualToString:@"img"]) {
                    CGFloat height = [ele.attributes[@"height"] floatValue];
                    CGFloat width = [ele.attributes[@"width"] floatValue];
                    
                    CGFloat imageViewW = [UIScreen mainScreen].bounds.size.width-20;
                    CGFloat imageViewH = 0;
                    if (width != 0 && height != 0) {
                        imageViewH = (imageViewW/width) * height;
                    } else {
                        imageViewH = (0.618) * imageViewW;
                    }
                    
                    PBContentModel *contentModel = [[PBContentModel alloc]init];
                    contentModel.isImg = YES;
                    contentModel.src = ele.attributes[@"src"];
                    contentModel.imgWidth = imageViewW;
                    contentModel.imgHeight = imageViewH;
                    
                    [imageArr addObject:ele.attributes[@"src"]];
                    
                    {
                        UIImageView *imageView = [[UIImageView alloc]init];
                        imageView.frame = CGRectMake(0, 0, imageViewW, imageViewH);
                        imageView.backgroundColor = [UIColor lightGrayColor];
                        [imageView sd_setImageWithURL:[NSURL URLWithString:contentModel.src]];
                        imageView.layer.cornerRadius = 10;
                        imageView.layer.masksToBounds = YES;
                        imageView.userInteractionEnabled = YES;
                        
                        [imageViewArr addObject:imageView];
                        
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick:)];
                        [imageView addGestureRecognizer:tap];
                        tap.view.tag = imageArr.count-1;
                        
                        NSMutableAttributedString *tmpStr = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:[UIFont boldSystemFontOfSize:13] alignment:YYTextVerticalAlignmentCenter];
                        [tmpStr yy_setLineSpacing:10 range:tmpStr.yy_rangeOfAll];
                        
                        [attributedString appendAttributedString:tmpStr];
                    }
                }
                
                if ([ele.tagName isEqualToString:@"a"]) {
                    NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                    [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                    [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                    
                    [attributedString appendAttributedString:tmpStr];
                }
            }
            
            if (self.lastAttributedString.length != attributedString.length) {
                [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\n"]];
            }
        }
        
        // 移除可能出现的最后一个换行
        NSString *str = [attributedString.string substringFromIndex:attributedString.length-1];
        if ([str isEqualToString:@"\n"]) {
            [attributedString deleteCharactersInRange:NSMakeRange(attributedString.length-1, 1)];
        }
    
        NSMutableArray *objsP = [[NSMutableArray alloc]init];
        
        PBContentModel *contentModel = [[PBContentModel alloc]init];
        contentModel.text = attributedString;
        contentModel.imageArr = imageArr;
        contentModel.imageViewArr = imageViewArr;
        
        [objsP addObject:contentModel];
        
        self.pEle = objsP;
    }
    return self;
}

- (void)tapClick:(UITapGestureRecognizer *)tap {
    NSDictionary *userInfo = @{@"tag":@(tap.view.tag)};
    [[NSNotificationCenter defaultCenter]postNotificationName:@"hhhh" object:nil userInfo:userInfo];
}

@end

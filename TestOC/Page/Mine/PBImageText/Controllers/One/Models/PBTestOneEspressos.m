//
//  PBTestOneEspressos.m
//  TestOC
//
//  Created by DaMaiIOS on 17/7/9.
//  Copyright © 2017年 DaMaiIOS. All rights reserved.
//

#import "PBTestOneEspressos.h"
#import <YYText/YYText.h>
#import "UIImageView+WebCache.h"

#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation PBTestOneEspressos

- (NSMutableArray *)imageObjs {
    if (_imageObjs == nil) {
        _imageObjs = [NSMutableArray array];
    }
    return _imageObjs;
}

+ (id)testOneEspressosWithHtmlStr:(NSString *)htmlStr {
    return [[self alloc]initWithHtmlStr:htmlStr];
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
        
        NSMutableArray *objsP = [[NSMutableArray alloc]init];
        
        for (TFHppleElement *hppleEle in pEle) { // 每执行一次此循环,会换一次行
            // hppleEle表示所有p标签组成的数组中的其中一个p标签
            
            for (int i = 0; i < hppleEle.children.count; i++) {
                TFHppleElement *ele = hppleEle.children[i];
                
                // 去除首尾空格和换行
                //NSString *content = [ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([ele.tagName isEqualToString:@"text"]) {
                    if (i == 0) {
                        PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                        contentOneModel.isImg = NO;
                        
                        NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                        [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                        [tmpStr yy_setColor:UIColorFromRGB(0x666666) range:NSMakeRange(0, tmpStr.length)];
                        [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                        
                        contentOneModel.text = tmpStr;
                        
                        [objsP addObject:contentOneModel];
                    } else {
                        PBContentOneModel *lastContentOneModel = [objsP lastObject];
                        if (lastContentOneModel.isImg == YES) {
                            PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                            contentOneModel.isImg = NO;
                            
                            NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                            [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setColor:UIColorFromRGB(0x666666) range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                            
                            contentOneModel.text = tmpStr;
                            
                            [objsP addObject:contentOneModel];
                        } else {
                            NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                            [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setColor:UIColorFromRGB(0x666666) range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                            
                            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:lastContentOneModel.text];
                            [str appendAttributedString:tmpStr];
                            lastContentOneModel.text = str;
                        }
                    }
                }
                
                if ([ele.tagName isEqualToString:@"strong"]) {
                    // strong->img
                    for (int j = 0; j < ele.children.count; j++) {
                        TFHppleElement *elee = ele.children[j];
                        
                        if ([elee.tagName isEqualToString:@"text"]) {
                            if (i == 0) {
                                PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                                contentOneModel.isImg = NO;
                                
                                NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                                [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                                [tmpStr yy_setColor:[UIColor redColor] range:NSMakeRange(0, tmpStr.length)];
                                [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                                
                                contentOneModel.text = tmpStr;
                                
                                [objsP addObject:contentOneModel];
                            } else {
                                PBContentOneModel *lastContentOneModel = [objsP lastObject];
                                if (lastContentOneModel.isImg == YES) {
                                    PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                                    contentOneModel.isImg = NO;
                                    
                                    NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                                    [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setColor:[UIColor redColor] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                                    
                                    contentOneModel.text = tmpStr;
                                    
                                    [objsP addObject:contentOneModel];
                                } else {
                                    NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                                    [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setColor:[UIColor redColor] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                                    
                                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:lastContentOneModel.text];
                                    [str appendAttributedString:tmpStr];
                                    lastContentOneModel.text = str;
                                }
                            }
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
                            
                            PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                            contentOneModel.isImg = YES;
                            contentOneModel.src = elee.attributes[@"src"];
                            contentOneModel.imgWidth = imageViewW;
                            contentOneModel.imgHeight = imageViewH;
                            
                            [objsP addObject:contentOneModel];
                            
                            // 加载图片链接
                            [self.imageObjs addObject:elee.attributes[@"src"]];
                        }
                        
                        if ([elee.tagName isEqualToString:@"a"]) {
                            if (i == 0) {
                                PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                                contentOneModel.isImg = NO;
                                
                                NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                                [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                                [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                                [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                                
                                contentOneModel.text = tmpStr;
                                
                                [objsP addObject:contentOneModel];
                            } else {
                                PBContentOneModel *lastContentOneModel = [objsP lastObject];
                                if (lastContentOneModel.isImg == YES) {
                                    PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                                    contentOneModel.isImg = NO;
                                    
                                    NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                                    [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                                    
                                    contentOneModel.text = tmpStr;
                                    
                                    [objsP addObject:contentOneModel];
                                } else {
                                    NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[elee.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                                    [tmpStr yy_setFont:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                                    [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                                    
                                    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:lastContentOneModel.text];
                                    [str appendAttributedString:tmpStr];
                                    lastContentOneModel.text = str;
                                }
                            }
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
                    
                    PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                    contentOneModel.isImg = YES;
                    contentOneModel.src = ele.attributes[@"src"];
                    contentOneModel.imgWidth = imageViewW;
                    contentOneModel.imgHeight = imageViewH;
                    
                    [objsP addObject:contentOneModel];
                    
                    // 加载图片链接
                    [self.imageObjs addObject:ele.attributes[@"src"]];
                }
                
                if ([ele.tagName isEqualToString:@"a"]) {
                    if (i == 0) {
                        PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                        contentOneModel.isImg = NO;
                        
                        NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                        [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                        [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                        [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                        
                        contentOneModel.text = tmpStr;
                        
                        [objsP addObject:contentOneModel];
                    } else {
                        PBContentOneModel *lastContentOneModel = [objsP lastObject];
                        if (lastContentOneModel.isImg == YES) {
                            PBContentOneModel *contentOneModel = [[PBContentOneModel alloc]init];
                            contentOneModel.isImg = NO;
                            
                            NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                            [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                            
                            contentOneModel.text = tmpStr;
                            
                            [objsP addObject:contentOneModel];
                        } else {
                            NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc]initWithString:[ele.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                            [tmpStr yy_setFont:[UIFont systemFontOfSize:13] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setColor:[UIColor blueColor] range:NSMakeRange(0, tmpStr.length)];
                            [tmpStr yy_setLineSpacing:10 range:NSMakeRange(0, tmpStr.length)];
                            
                            NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithAttributedString:lastContentOneModel.text];
                            [str appendAttributedString:tmpStr];
                            lastContentOneModel.text = str;
                        }
                    }
                }
            }
        }
        self.pEle = objsP;
    }
    return self;
}

@end

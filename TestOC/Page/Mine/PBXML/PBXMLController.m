//
//  PBXMLController.m
//  TestOC
//
//  Created by zhushanbo on 2025/7/3.
//  Copyright © 2025 DaMaiIOS. All rights reserved.
//

#import "PBXMLController.h"

#import <Foundation/Foundation.h>

// XML解析器代理
@interface XMLToJSONParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSMutableDictionary *jsonDict;
@property (nonatomic, strong) NSString *currentElement;
@property (nonatomic, strong) NSMutableString *currentValue;
@property (nonatomic, strong) NSMutableArray *stack;

- (NSDictionary *)parseXML:(NSString *)xmlString;
@end

@implementation XMLToJSONParser
- (instancetype)init {
    self = [super init];
    if (self) {
        _jsonDict = [NSMutableDictionary dictionary];
        _stack = [NSMutableArray array];
        _currentValue = [NSMutableString string];
    }
    return self;
}

- (NSDictionary *)parseXML:(NSString *)xmlString {
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
    return _jsonDict;
}

// 解析开始标签
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    _currentElement = elementName;
    [_currentValue setString:@""];
    if ([elementName isEqualToString:@"root"]) {
        [_stack addObject:_jsonDict];
    }
}

// 收集元素内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_currentValue appendString:string];
}

// 解析结束标签
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    NSString *trimmedValue = [_currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedValue.length > 0) {
        _jsonDict[elementName] = trimmedValue;
    }
    _currentElement = nil;
    _currentValue = [NSMutableString string];
}

// 解析完成
- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Parsing completed: %@", _jsonDict);
}

@end

#pragma mark - PBXMLController

@interface PBXMLController ()

@end

@implementation PBXMLController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *jsonDict = @{
        @"person": @{
            @"name": @"Tom",
            @"age": @(30),
            @"city": @"Tokyo",
            @"hobbies": @[@"reading", @"traveling"]
        }
    };

    NSString *xml = [self convertDictionaryToXML:jsonDict withRoot:@"root"];
    NSLog(@"xml = %@", xml);

    {
        // 示例XML字符串
        NSString *xmlString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                               "<root>"
                               "<name>John</name>"
                               "<age>30</age>"
                               "<city>New York</city>"
                               "</root>";
        NSLog(@"xmlString = %@", xmlString);
        
        XMLToJSONParser *parser = [[XMLToJSONParser alloc] init];
        NSDictionary *jsonDict = [parser parseXML:xmlString];
        
        // 转换为JSON
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        if (!error) {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"JSON Output:\n%@", jsonString);
        } else {
            NSLog(@"Error converting to JSON: %@", error.localizedDescription);
        }
    }

}

#pragma mark - JSON转XML

- (NSString *)convertDictionaryToXML:(NSDictionary *)dict withRoot:(NSString *)rootName {
    NSMutableString *xml = [NSMutableString string];
    [xml appendFormat:@"<%@>", rootName];

    for (NSString *key in dict) {
        id value = dict[key];

        if ([value isKindOfClass:[NSDictionary class]]) {
            NSString *childXML = [self convertDictionaryToXML:value withRoot:key];
            [xml appendString:childXML];
        } else if ([value isKindOfClass:[NSArray class]]) {
            for (id item in value) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSString *childXML = [self convertDictionaryToXML:item withRoot:key];
                    [xml appendString:childXML];
                } else {
                    [xml appendFormat:@"<%@>%@</%@>", key, item, key];
                }
            }
        } else {
            [xml appendFormat:@"<%@>%@</%@>", key, value, key];
        }
    }

    [xml appendFormat:@"</%@>", rootName];
    return xml;
}


@end

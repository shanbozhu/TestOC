//
//  PBXMLController.m
//  TestOC
//
//  Created by zhushanbo on 2025/7/3.
//  Copyright © 2025 DaMaiIOS. All rights reserved.
//

#import "PBXMLController.h"

#pragma mark - XML转JSON

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

#pragma mark - JSON转XML

#import <Foundation/Foundation.h>

@interface JSONToXMLConverter : NSObject
+ (NSString *)xmlStringFromJSON:(id)jsonObject rootElement:(NSString *)rootElement;
@end

@implementation JSONToXMLConverter

+ (NSString *)xmlStringFromJSON:(id)jsonObject rootElement:(NSString *)rootElement {
    NSMutableString *xmlString = [NSMutableString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<%@>", rootElement];
    
    [self appendXML:jsonObject toString:xmlString indentLevel:1];
    
    [xmlString appendFormat:@"\n</%@>", rootElement];
    return xmlString;
}

+ (void)appendXML:(id)object toString:(NSMutableString *)xmlString indentLevel:(NSInteger)level {
    NSString *indent = [@"" stringByPaddingToLength:level * 2 withString:@" " startingAtIndex:0];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)object;
        for (NSString *key in dict) {
            id value = dict[key];
            [xmlString appendFormat:@"\n%@<%@>", indent, key];
            [self appendXML:value toString:xmlString indentLevel:level + 1];
            [xmlString appendFormat:@"\n%@</%@>", indent, key];
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)object;
        for (id value in array) {
            [xmlString appendFormat:@"\n%@<item>", indent];
            [self appendXML:value toString:xmlString indentLevel:level + 1];
            [xmlString appendFormat:@"\n%@</item>", indent];
        }
    } else {
        NSString *value = [NSString stringWithFormat:@"%@", object];
        [xmlString appendString:[self escapeXML:value]];
    }
}

// 转义XML特殊字符
+ (NSString *)escapeXML:(NSString *)string {
    return [[[[[string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
               stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
               stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
               stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"]
               stringByReplacingOccurrencesOfString:@"'" withString:@"&apos;"];
}

@end

#pragma mark - PBXMLController

@interface PBXMLController ()

@end

@implementation PBXMLController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        // 示例JSON字符串
        NSString *jsonString = @"{\"name\":\"John\",\"age\":\"30\",\"city\":\"New York\"}";
        
        // 解析JSON
        NSError *error;
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        if (!error) {
            // 转换为XML
            NSString *xmlString = [JSONToXMLConverter xmlStringFromJSON:jsonDict rootElement:@"root"];
            NSLog(@"XML Output:\n%@", xmlString);
        } else {
            NSLog(@"Error parsing JSON: %@", error.localizedDescription);
        }
    }
    
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

@end

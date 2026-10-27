//
//  PBCrossIdentifier.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossIdentifier.h"

NSString *PBCrossIdentifierKindToString(PBCrossIdentifierKind kind)
{
    switch (kind) {
        case PBCrossIdentifierKindFingerprint:
            return @"fingerprint";
        case PBCrossIdentifierKindRemote:
            return @"remote";
        case PBCrossIdentifierKindServer:
            return @"server";
    }
    return @"fingerprint";
}

PBCrossIdentifierKind PBCrossIdentifierKindFromString(NSString *string)
{
    if ([string isEqualToString:@"remote"]) {
        return PBCrossIdentifierKindRemote;
    }
    if ([string isEqualToString:@"server"]) {
        return PBCrossIdentifierKindServer;
    }
    return PBCrossIdentifierKindFingerprint;
}

@implementation PBCrossIdentifier

+ (nullable instancetype)identifierWithValue:(NSString *)value
                                     version:(NSString *)version
                                        kind:(PBCrossIdentifierKind)kind
{
    return [[self alloc] initWithValue:value version:version kind:kind];
}

- (nullable instancetype)initWithValue:(NSString *)value
                               version:(NSString *)version
                                  kind:(PBCrossIdentifierKind)kind
{
    if (![value isKindOfClass:[NSString class]] || ![version isKindOfClass:[NSString class]]) {
        return nil;
    }

    NSString *trimmedValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimmedVersion = [version stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedValue.length == 0 || trimmedValue.length > 128 || trimmedVersion.length == 0) {
        return nil;
    }

    self = [super init];
    if (self) {
        _value = [trimmedValue copy];
        _version = [trimmedVersion copy];
        _kind = kind;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

- (BOOL)isEqualToIdentifier:(PBCrossIdentifier *)identifier
{
    if (![identifier isKindOfClass:[PBCrossIdentifier class]]) {
        return NO;
    }
    return [self.value caseInsensitiveCompare:identifier.value] == NSOrderedSame
        && [self.version isEqualToString:identifier.version]
        && self.kind == identifier.kind;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    return [self isEqualToIdentifier:object];
}

- (NSUInteger)hash
{
    return self.value.lowercaseString.hash ^ self.version.hash ^ self.kind;
}

- (NSDictionary<NSString *, id> *)dictionaryRepresentation
{
    return @{
        @"id": self.value,
        @"version": self.version,
        @"kind": PBCrossIdentifierKindToString(self.kind),
    };
}

+ (nullable instancetype)identifierWithDictionaryRepresentation:(NSDictionary<NSString *, id> *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    id value = dictionary[@"id"] ?: dictionary[@"value"];
    id version = dictionary[@"version"];
    if (![value isKindOfClass:[NSString class]] || ![version isKindOfClass:[NSString class]]) {
        return nil;
    }

    PBCrossIdentifierKind kind = PBCrossIdentifierKindFromString([dictionary[@"kind"] isKindOfClass:[NSString class]]
                                                                ? dictionary[@"kind"] : @"fingerprint");
    return [self identifierWithValue:value version:version kind:kind];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; id=%@; version=%@; kind=%@>",
            NSStringFromClass([self class]),
            self,
            self.value,
            self.version,
            PBCrossIdentifierKindToString(self.kind)];
}

@end

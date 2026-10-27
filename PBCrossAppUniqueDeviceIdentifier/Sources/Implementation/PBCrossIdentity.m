//
//  PBCrossIdentity.m
//  PBCrossAppUniqueDeviceIdentifier
//
//  Created by Codex on 2026/10/27.
//  Copyright © 2026年 DaMaiIOS. All rights reserved.
//

#import "PBCrossIdentity.h"
#import "PBCrossConfiguration.h"

NSString *PBCrossIdentitySourceDescription(PBCrossIdentitySource source)
{
    NSMutableArray<NSString *> *tokens = [NSMutableArray arrayWithCapacity:4];
    if (source & PBCrossIdentitySourceFingerprint) {
        [tokens addObject:@"fingerprint"];
    }
    if (source & PBCrossIdentitySourceSharedStorage) {
        [tokens addObject:@"shared_storage"];
    }
    if (source & PBCrossIdentitySourceRemote) {
        [tokens addObject:@"remote"];
    }
    if (source & PBCrossIdentitySourceServer) {
        [tokens addObject:@"server"];
    }
    return [tokens componentsJoinedByString:@","];
}

static PBCrossIdentitySource PBCrossIdentitySourceFromStrings(NSArray *strings)
{
    PBCrossIdentitySource source = PBCrossIdentitySourceNone;
    for (id value in strings) {
        if (![value isKindOfClass:[NSString class]]) {
            continue;
        }
        if ([value isEqualToString:@"fingerprint"]) {
            source |= PBCrossIdentitySourceFingerprint;
        } else if ([value isEqualToString:@"shared_storage"] || [value isEqualToString:@"shared"]) {
            source |= PBCrossIdentitySourceSharedStorage;
        } else if ([value isEqualToString:@"remote"]) {
            source |= PBCrossIdentitySourceRemote;
        } else if ([value isEqualToString:@"server"]) {
            source |= PBCrossIdentitySourceServer;
        }
    }
    return source;
}

static NSDate *PBCrossDateFromJSONValue(id value)
{
    if ([value isKindOfClass:[NSNumber class]]) {
        return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSTimeInterval interval = [value doubleValue];
        return interval > 0 ? [NSDate dateWithTimeIntervalSince1970:interval] : nil;
    }
    return nil;
}

@interface PBCrossIdentity ()

- (nullable PBCrossIdentifier *)currentIdentifierValue;
- (nullable PBCrossIdentifier *)previousIdentifierValue;

@end

@implementation PBCrossIdentity

- (instancetype)initWithSharedID:(NSString *)sharedID
                     identifiers:(NSArray<PBCrossIdentifier *> *)identifiers
                      attributes:(PBCrossDeviceAttributes *)attributes
       previousSystemUpdateTime:(NSString *)previousSystemUpdateTime
                       algorithm:(NSString *)algorithm
                         sources:(PBCrossIdentitySource)sources
                     generatedAt:(NSDate *)generatedAt
                remoteResolvedAt:(nullable NSDate *)remoteResolvedAt
{
    self = [super init];
    if (self) {
        _sharedID = [sharedID isKindOfClass:[NSString class]] ? [sharedID copy] : @"";
        NSArray *candidateIdentifiers = [identifiers isKindOfClass:[NSArray class]] ? identifiers : @[];
        NSMutableArray<PBCrossIdentifier *> *validIdentifiers =
            [NSMutableArray arrayWithCapacity:candidateIdentifiers.count];
        for (id identifier in candidateIdentifiers) {
            if ([identifier isKindOfClass:[PBCrossIdentifier class]]) {
                [validIdentifiers addObject:identifier];
            }
        }
        _identifiers = [validIdentifiers copy];
        _attributes = [attributes isKindOfClass:[PBCrossDeviceAttributes class]]
            ? attributes
            : [PBCrossDeviceAttributes attributesWithValues:@{}];
        _previousSystemUpdateTime = [previousSystemUpdateTime isKindOfClass:[NSString class]]
            ? [previousSystemUpdateTime copy] : @"";
        _algorithm = ([algorithm isKindOfClass:[NSString class]] && algorithm.length > 0)
            ? [algorithm copy] : [PBCrossIdentifierAlgorithmName copy];
        _sources = sources;
        _generatedAt = [generatedAt isKindOfClass:[NSDate class]] ? generatedAt : [NSDate date];
        _remoteResolvedAt = [remoteResolvedAt isKindOfClass:[NSDate class]] ? remoteResolvedAt : nil;
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

#pragma mark - 便捷访问

- (nullable NSString *)currentIdentifier
{
    return [self currentIdentifierValue].value;
}

- (nullable NSString *)currentVersion
{
    return [self currentIdentifierValue].version;
}

- (nullable NSString *)previousIdentifier
{
    return [self previousIdentifierValue].value;
}

- (nullable NSString *)previousVersion
{
    return [self previousIdentifierValue].version;
}

- (nullable PBCrossIdentifier *)currentIdentifierValue
{
    for (PBCrossIdentifier *identifier in self.identifiers) {
        if (identifier.kind == PBCrossIdentifierKindFingerprint) {
            return identifier;
        }
    }
    return self.identifiers.firstObject;
}

- (nullable PBCrossIdentifier *)previousIdentifierValue
{
    PBCrossIdentifier *current = [self currentIdentifierValue];
    BOOL foundCurrent = NO;
    for (PBCrossIdentifier *identifier in self.identifiers) {
        if (identifier.kind != PBCrossIdentifierKindFingerprint) {
            continue;
        }
        if (!foundCurrent) {
            foundCurrent = (identifier == current);
            continue;
        }
        return identifier;
    }
    return nil;
}

- (NSArray<PBCrossIdentifier *> *)allIdentifiers
{
    NSMutableArray<PBCrossIdentifier *> *result = [NSMutableArray arrayWithCapacity:self.identifiers.count];
    NSMutableSet<NSString *> *seen = [NSMutableSet setWithCapacity:self.identifiers.count];
    for (PBCrossIdentifier *identifier in self.identifiers) {
        NSString *key = identifier.value.lowercaseString;
        if (key.length == 0 || [seen containsObject:key]) {
            continue;
        }
        [seen addObject:key];
        [result addObject:identifier];
    }
    return [result copy];
}

- (NSArray<PBCrossIdentifier *> *)identifiersWithKind:(PBCrossIdentifierKind)kind
{
    NSMutableArray<PBCrossIdentifier *> *result = [NSMutableArray array];
    for (PBCrossIdentifier *identifier in self.identifiers) {
        if (identifier.kind == kind) {
            [result addObject:identifier];
        }
    }
    return [result copy];
}

- (nullable PBCrossIdentifier *)identifierForVersion:(NSString *)version
{
    if (version.length == 0) {
        return nil;
    }
    for (PBCrossIdentifier *identifier in self.identifiers) {
        if ([identifier.version isEqualToString:version]) {
            return identifier;
        }
    }
    return nil;
}

#pragma mark - 序列化

- (NSDictionary<NSString *, id> *)dictionaryRepresentation
{
    NSMutableArray<NSDictionary<NSString *, id> *> *identifiers = [NSMutableArray arrayWithCapacity:self.identifiers.count];
    for (PBCrossIdentifier *identifier in self.identifiers) {
        [identifiers addObject:[identifier dictionaryRepresentation]];
    }

    NSMutableDictionary<NSString *, id> *dictionary = [@{
        @"shared_id": self.sharedID ?: @"",
        @"algorithm": self.algorithm,
        @"sources": PBCrossIdentitySourceDescription(self.sources).length > 0
            ? [PBCrossIdentitySourceDescription(self.sources) componentsSeparatedByString:@","]
            : @[],
        @"generated_at": @([self.generatedAt timeIntervalSince1970]),
        @"identifiers": identifiers,
        @"attributes": [self.attributes dictionaryRepresentation],
    } mutableCopy];

    if (self.previousSystemUpdateTime.length > 0) {
        dictionary[@"previous_system_update_time"] = self.previousSystemUpdateTime;
    }
    if (self.remoteResolvedAt) {
        dictionary[@"remote_resolved_at"] = @([self.remoteResolvedAt timeIntervalSince1970]);
    }
    return [dictionary copy];
}

+ (nullable instancetype)identityWithDictionaryRepresentation:(NSDictionary<NSString *, id> *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }

    NSMutableArray<PBCrossIdentifier *> *identifiers = [NSMutableArray array];
    id rawIdentifiers = dictionary[@"identifiers"];
    if ([rawIdentifiers isKindOfClass:[NSArray class]]) {
        for (id rawIdentifier in (NSArray *)rawIdentifiers) {
            if (![rawIdentifier isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            PBCrossIdentifier *identifier = [PBCrossIdentifier identifierWithDictionaryRepresentation:rawIdentifier];
            if (identifier) {
                [identifiers addObject:identifier];
            }
        }
    }

    id rawAttributes = dictionary[@"attributes"];
    PBCrossDeviceAttributes *attributes = nil;
    if ([rawAttributes isKindOfClass:[NSDictionary class]]) {
        attributes = [PBCrossDeviceAttributes attributesWithDictionaryRepresentation:rawAttributes];
    }
    if (!attributes) {
        attributes = [PBCrossDeviceAttributes attributesWithValues:@{}];
    }

    id rawSources = dictionary[@"sources"];
    PBCrossIdentitySource sources = [rawSources isKindOfClass:[NSArray class]]
        ? PBCrossIdentitySourceFromStrings(rawSources)
        : PBCrossIdentitySourceNone;
    if (sources == PBCrossIdentitySourceNone) {
        for (PBCrossIdentifier *identifier in identifiers) {
            if (identifier.kind == PBCrossIdentifierKindFingerprint) {
                sources |= PBCrossIdentitySourceFingerprint;
            } else if (identifier.kind == PBCrossIdentifierKindRemote) {
                sources |= PBCrossIdentitySourceRemote;
            } else if (identifier.kind == PBCrossIdentifierKindServer) {
                sources |= PBCrossIdentitySourceServer;
            }
        }
        if ([dictionary[@"shared_id"] isKindOfClass:[NSString class]]
            && [dictionary[@"shared_id"] length] > 0) {
            sources |= PBCrossIdentitySourceSharedStorage;
        }
    }

    NSString *sharedID = [dictionary[@"shared_id"] isKindOfClass:[NSString class]] ? dictionary[@"shared_id"] : @"";
    NSString *algorithm = [dictionary[@"algorithm"] isKindOfClass:[NSString class]] ? dictionary[@"algorithm"] : PBCrossIdentifierAlgorithmName;
    NSString *previousUpdateTime = [dictionary[@"previous_system_update_time"] isKindOfClass:[NSString class]]
        ? dictionary[@"previous_system_update_time"] : @"";
    NSDate *generatedAt = PBCrossDateFromJSONValue(dictionary[@"generated_at"]) ?: [NSDate date];
    NSDate *remoteResolvedAt = PBCrossDateFromJSONValue(dictionary[@"remote_resolved_at"]);

    return [[self alloc] initWithSharedID:sharedID
                              identifiers:identifiers
                               attributes:attributes
                previousSystemUpdateTime:previousUpdateTime
                                algorithm:algorithm
                                  sources:sources
                              generatedAt:generatedAt
                         remoteResolvedAt:remoteResolvedAt];
}

+ (nullable instancetype)identityWithAdRequestExtension:(NSDictionary<NSString *, id> *)extension
{
    if (![extension isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    id crossApp = extension[@"pb_cross_app"];
    if ([crossApp isKindOfClass:[NSDictionary class]]) {
        return [self identityWithDictionaryRepresentation:crossApp];
    }
    return [self identityWithDictionaryRepresentation:extension];
}

+ (nullable instancetype)identityWithAdRequestExtensionJSONString:(NSString *)jsonString
{
    if (jsonString.length == 0) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [self identityWithAdRequestExtension:object];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[PBCrossIdentity class]]) {
        return NO;
    }
    PBCrossIdentity *other = object;
    return [self.sharedID isEqualToString:other.sharedID]
        && [self.identifiers isEqualToArray:other.identifiers]
        && [self.attributes isEqual:other.attributes]
        && [self.previousSystemUpdateTime isEqualToString:other.previousSystemUpdateTime]
        && [self.algorithm isEqualToString:other.algorithm]
        && self.sources == other.sources;
}

- (NSUInteger)hash
{
    return self.sharedID.hash ^ self.identifiers.hash ^ self.attributes.hash ^ self.sources;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; current=%@/%@; ids=%lu; shared=%@; sources=%@>",
            NSStringFromClass([self class]),
            self,
            self.currentIdentifier ?: @"-",
            self.currentVersion ?: @"-",
            (unsigned long)self.identifiers.count,
            self.sharedID.length > 0 ? self.sharedID : @"-",
            PBCrossIdentitySourceDescription(self.sources)];
}

@end

//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateNull.h"


@implementation InnateNull {
}
+ (instancetype)init {
    return [[InnateNull alloc] init];
}

- (BOOL)isObject {
    return NO;
}

- (BOOL)isArray {
    return NO;
}

- (BOOL)isString {
    return NO;
}

- (BOOL)isNumber {
    return NO;
}

- (BOOL)isBool {
    return NO;
}

- (BOOL)isNull {
    return YES;
}

- (NSDictionary<NSString *, id<InnateValue>> *)asObject {
    return nil;
}

- (NSArray<id<InnateValue>>  *)asArray {
    return nil;
}

- (NSString *)asString {
    return nil;
}

- (NSNumber *)asNumber {
    return nil;
}

- (InnateBoolean *)asBool {
    return nil;
}

- (InnateNull *)asNull {
    return self;
}

- (NSString *)toString {
    return nil;
}

- (NSString *)getType {
    return @"null";
}

@end

//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateNumber.h"

@implementation NSNumber (InnateNumber)
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
    return NO;
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
    return self;
}

- (InnateBoolean *)asBool {
    return nil;
}

- (InnateNull *)asNull {
    return nil;
}

- (NSString *)toString {
    return nil; // TODO
}

@end

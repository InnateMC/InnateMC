//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateArray.h"


@implementation NSArray (InnateArray)

- (BOOL)isArray {
    return YES;
}

- (BOOL)isObject {
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
    return self;
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
    return nil;
}

- (NSString *)toString {
    return nil; // TODO
}

@end

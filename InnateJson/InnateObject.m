//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateObject.h"

@implementation NSDictionary (InnateObject)
- (BOOL)isObject {
    return YES;
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
    return self;
}

- (NSArray<id<InnateValue>> *)asArray {
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
    return nil;
}

- (NSString *)toString {
    return nil;
}

@end

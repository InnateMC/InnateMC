//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateString.h"


@implementation NSString (InnateString)
- (BOOL)isObject {
    return NO;
}

- (BOOL)isArray {
    return NO;
}

- (BOOL)isString {
    return YES;
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

- (NSDictionary<NSString *, id <InnateValue>> *)asObject {
    return nil;
}

- (NSArray<id <InnateValue>> *)asArray {
    return nil;
}

- (NSString *)asString {
    return self;
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
    return self;
}

- (NSString *)getType {
    return @"string";
}

@end

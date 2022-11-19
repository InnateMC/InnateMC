//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateBoolean.h"

@implementation InnateBoolean {
}

+ (instancetype)initWithBool:(BOOL)value {
    InnateBoolean* boolean = [[InnateBoolean alloc] init];
    boolean->booleanValue = value;
    return boolean;
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
    return YES;
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
    return nil;
}

- (InnateBoolean *)asBool {
    return self;
}

- (InnateNull *)asNull {
    return nil;
}

- (NSString *)toString {
    return nil;
}

- (NSString *)getType {
    return @"boolean";
}

@end

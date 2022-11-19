//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateValue.h"
#import "InnateArray.h"
#import "InnateObject.h"
#import "InnateString.h"
#import "InnateNumber.h"
#import "InnateBoolean.h"
#import "InnateNull.h"


@implementation InnateValue

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

- (InnateObject *)asObject {
    return nil;
}

- (InnateArray *)asArray {
    return nil;
}

- (InnateString *)asString {
    return nil;
}

- (InnateNumber *)asNumber {
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

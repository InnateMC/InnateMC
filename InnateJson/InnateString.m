//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateString.h"


@implementation InnateString {
}

+ (instancetype) initWithString:(NSString *)string {
    InnateString *innateString = [[InnateString alloc] init];
    innateString->stringValue = string;
    return innateString;
}

- (BOOL)isString {
    return YES;
}

@end

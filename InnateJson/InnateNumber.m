//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateNumber.h"


@implementation InnateNumber {
}

+ (instancetype)initWithNumber:(NSNumber *)number {
    InnateNumber *innateNumber = [[InnateNumber alloc] init];
    innateNumber->numberValue = number;
    return innateNumber;
}

- (BOOL)isNumber {
    return YES;
}

@end

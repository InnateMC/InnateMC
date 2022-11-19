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

- (BOOL)isBool {
    return YES;
}

@end

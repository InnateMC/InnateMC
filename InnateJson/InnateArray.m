//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateArray.h"


@implementation InnateArray {
    NSArray<InnateValue *> *_array;
}
+ (instancetype)initWithArray:(NSArray<InnateValue *> *)array {
    InnateArray* arr = [[InnateArray alloc] init];
    arr->_array = array;
    return arr;
}

- (InnateValue *)get:(NSUInteger)index {
    return _array[index];
}

- (NSUInteger)size {
    return _array.count;
}

- (BOOL)isArray {
    return YES;
}

@end

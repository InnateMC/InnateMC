//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>
#import "InnateValue.h"


@interface InnateArray : InnateValue
+ (instancetype) initWithArray:(NSArray<InnateValue *> *)array;

- (InnateValue *)get:(NSUInteger)index;

- (NSUInteger)size;
@end

//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateObject.h"


@implementation InnateObject {
    NSDictionary<NSString *, InnateValue *> *dictionary;
}

+ (instancetype) initWithDictionary:(NSDictionary<NSString *, InnateValue *> *)dictionary {
    InnateObject *object = [[InnateObject alloc] init];
    object->dictionary = dictionary;
    return object;
}

- (InnateValue *)get:(NSString *)key {
    return dictionary[key];
}

- (BOOL)isObject {
    return YES;
}

@end

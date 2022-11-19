//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>
#import "InnateValue.h"


@interface InnateObject : InnateValue {

}

+ (instancetype) initWithDictionary:(NSDictionary<NSString *, InnateValue *> *)dictionary;

- (InnateValue *)get:(NSString *)key;

@end

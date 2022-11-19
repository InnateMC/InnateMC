//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>
#import "InnateValue.h"


@interface InnateBoolean : InnateValue {
    BOOL booleanValue;
}

+ (instancetype) initWithBool:(BOOL)boolean;

@end

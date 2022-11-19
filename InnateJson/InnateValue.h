//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>

@class InnateArray;
@class InnateObject;
@class InnateString;
@class InnateNumber;
@class InnateBoolean;
@class InnateNull;


@interface InnateValue : NSObject

- (BOOL) isObject;

- (BOOL) isArray;

- (BOOL) isString;

- (BOOL) isNumber;

- (BOOL) isBool;

- (BOOL) isNull;

- (InnateObject *) asObject;

- (InnateArray *) asArray;

- (InnateString *) asString;

- (InnateNumber *) asNumber;

- (InnateBoolean *) asBool;

- (InnateNull *) asNull;

- (NSString *) toString;

@end

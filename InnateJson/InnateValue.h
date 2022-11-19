//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>

@class NSArray;
@class NSDictionary;
@class NSNumber;
@class NSString;
@class InnateBoolean;
@class InnateNull;


@protocol InnateValue

- (BOOL) isObject;

- (BOOL) isArray;

- (BOOL) isString;

- (BOOL) isNumber;

- (BOOL) isBool;

- (BOOL) isNull;

- (NSDictionary<NSString *, id<InnateValue>> *) asObject;

- (NSArray<id<InnateValue>> *) asArray;

- (NSString *) asString;

- (NSNumber *) asNumber;

- (InnateBoolean *) asBool;

- (InnateNull *) asNull;

- (NSString *) toString;

- (NSString *) getType;

@end

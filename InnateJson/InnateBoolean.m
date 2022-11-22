//
// Copyright © 2022 Shrish Deshpande
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "InnateBoolean.h"

@implementation InnateBoolean {
}

+ (instancetype)initWithBool:(BOOL)value {
    InnateBoolean* boolean = [[InnateBoolean alloc] init];
    boolean->booleanValue = value;
    return boolean;
}

- (BOOL)isObject {
    return NO;
}

- (BOOL)isArray {
    return NO;
}

- (BOOL)isString {
    return NO;
}

- (BOOL)isNumber {
    return NO;
}

- (BOOL)isBool {
    return YES;
}

- (BOOL)isNull {
    return NO;
}

- (NSDictionary<NSString *, id<InnateValue>> *)asObject {
    return nil;
}

- (NSArray<id<InnateValue>>  *)asArray {
    return nil;
}

- (NSString *)asString {
    return nil;
}

- (NSNumber *)asNumber {
    return nil;
}

- (InnateBoolean *)asBool {
    return self;
}

- (InnateNull *)asNull {
    return nil;
}

- (NSString *)toString {
    return nil;
}

- (NSString *)getType {
    return @"boolean";
}

@end

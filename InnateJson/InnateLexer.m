//
//  InnateLexer.m
//  InnateJson
//
//  Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>
#import "InnateLexer.h"

@implementation InnateLexer

- (instancetype) init:(NSString *)json {
    self = [super init];
    original = json
    return self
}

- (void) lex {
}

- (NSString *) lexString:(NSString *)value {
    return nil
}

- (NSString *) lexNumber:(NSString *)value {
    return nil
}

- (NSString *) lexBool:(NSString *)value {
    return nil
}

- (NSString *) lexNull:(NSString *)value {
    return nil
}

@end

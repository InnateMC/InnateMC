//
// Created by Shrish Deshpande on 11/19/22.
//

#import "InnateParser.h"
#import "InnateValue.h"
#import "InnateObject.h"
#import "InnateArray.h"
#import "InnateNull.h"
#import "InnateBoolean.h"
#import "InnateString.h"
#import "InnateNumber.h"

@implementation InnateParser {
}

+ (InnateParser *)parserWithTokens:(NSArray<NSString *> *)tokens {
    InnateParser *parser = [[InnateParser alloc] init];
    parser->tokens = tokens;
    parser->current = 0;
    return parser;
}

- (NSString *)nextToken {
    if (self->current >= self->tokens.count) {
        return nil;
    }
    return self->tokens[self->current++];
}

- (NSDictionary<NSString *, id<InnateValue>> *)parseObject {
    NSMutableDictionary<NSString *, id<InnateValue>> *dict = [NSMutableDictionary dictionary];
    NSString *token = [self nextToken];
    if ([token isEqualToString:@"}"]) {
        return dict;
    }
    while (token != nil) {
        id<InnateValue> key = [self parse];
        if (![key isString]) {
            @throw [NSException exceptionWithName:@"InnateParserException" reason:@"Key must be a string" userInfo:nil];
        }
        token = [self nextToken];
        if (![token isEqualToString:@":"]) {
            @throw [NSException exceptionWithName:@"InnateParserException" reason:@"Expected ':'" userInfo:nil];
        }
        id<InnateValue> value = [self parse];
        dict[key.asString] = value;
        token = [self nextToken];
        if ([token isEqualToString:@"}"]) {
            return dict;
        }
        if (![token isEqualToString:@","]) {
            @throw [NSException exceptionWithName:@"InnateParserException" reason:@"Expected ','" userInfo:nil];
        }
    }
    return nil;
}

- (NSArray<id<InnateValue>> *)parseArray {
    NSMutableArray<id<InnateValue>> *arr = [NSMutableArray array];
    NSString *token = [self nextToken];
    if ([token isEqualToString:@"]"]) {
        return arr;
    }

    while (token != nil) {
        [arr addObject:[self parse]];
        token = [self nextToken];
        if ([token isEqualToString:@"]"]) {
            return arr;
        }
        if (![token isEqualToString:@","]) {
            @throw [NSException exceptionWithName:@"InvalidJson" reason:@"No closing right bracket" userInfo:nil];
        }
    }

    @throw [NSException exceptionWithName:@"InvalidJson" reason:@"No closing right bracket" userInfo:nil];
}

- (NSString *)parseString {
    return [self nextToken];
}

- (NSNumber *)parseNumber {
    return [self parseString].asNumber;
}

- (id <InnateValue>)parse {
    NSString *token = [self nextToken];
    if ([token isEqualToString:@"{"]) {
        return [self parseObject];
    } else if ([token isEqualToString:@"["]) {
        return [self parseArray];
    } else if ([token isEqualToString:@"true"]) {
        return [InnateBoolean initWithBool:YES];
    } else if ([token isEqualToString:@"false"]) {
        return [InnateBoolean initWithBool:NO];
    } else if ([token isEqualToString:@"null"]) {
        return [InnateNull init];
    } else if ([token characterAtIndex:0] == '"') {
        return [self parseString];
    } else {
        return [self parseNumber];
    }
}

@end

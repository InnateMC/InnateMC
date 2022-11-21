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
#import "InnateLexer.h"

@implementation InnateParser {
}

+ (NSDictionary<NSString *, id <InnateValue>> *)readJson:(NSString *)tokens {
    InnateLexer *lexer = [[InnateLexer alloc] init:tokens];
    InnateParser *parser = [InnateParser parserWithTokens:[lexer lex]];
    return [[parser parse] asObject];
}

+ (InnateParser *)parserWithTokens:(NSArray<NSString *> *)tokens {
    InnateParser *parser = [[InnateParser alloc] init];
    parser->tokens = tokens;
    parser->current = 0;
    return parser;
}

- (NSString *)nextToken {
    NSString *token = tokens[current];
    current++;
    return token;
}

- (NSDictionary<NSString *, id<InnateValue>> *)parseObject {
    NSMutableDictionary<NSString *, id<InnateValue>> *dict = [NSMutableDictionary dictionary];
    NSString *token = @"";
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
    @throw [NSException exceptionWithName:@"InnateParserException" reason:@"Expected '}'" userInfo:nil];
}

- (NSArray<id<InnateValue>> *)parseArray {
    NSMutableArray<id<InnateValue>> *arr = [NSMutableArray array];
    NSString *token = @"";

    while (token != nil) {
        [arr addObject:[self parse]];
        token = [self nextToken];
        if ([token isEqualToString:@"]"]) {
            return arr;
        }
        if (![token isEqualToString:@","]) {
            @throw [NSException exceptionWithName:@"InvalidJson" reason:@"Missing Comma" userInfo:nil];
        }
    }

    @throw [NSException exceptionWithName:@"InvalidJson" reason:@"No closing right bracket" userInfo:nil];
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
        return [token substringWithRange:NSMakeRange(1, token.length - 2)];
    } else {
        return token.asNumber;
    }
}

@end

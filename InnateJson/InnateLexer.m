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

#import <Foundation/Foundation.h>
#import "InnateLexer.h"

@implementation InnateLexer

- (instancetype) init:(NSString *)json {
    self = [super init];
    original = json;
    return self;
}

- (NSArray *) lex {
    current = [NSMutableString stringWithString:original];
    NSMutableArray<NSString *> *tokens = [[NSMutableArray alloc] init];
    NSString *lexed;

    while (current.length > 0) {
        lexed = [self lexString];
        if (lexed != nil) {
            [tokens addObject:lexed];
            continue;
        }
        lexed = [self lexNumber];
        if (lexed != nil) {
            [tokens addObject:lexed];
            continue;
        }
        lexed = [self lexBool];
        if (lexed != nil) {
            [tokens addObject:lexed];
            continue;
        }
        lexed = [self lexNull];
        if (lexed != nil) {
            [tokens addObject:lexed];
            continue;
        }
        unichar lexedChar = [current characterAtIndex:0];
        if (lexedChar == ' ' || lexedChar == '\t' || lexedChar == '\r' || lexedChar == '\n') {
            [current deleteCharactersInRange:NSMakeRange(0, 1)];
            continue;
        } else if (lexedChar == JSON_COLON || lexedChar == JSON_COMMA || lexedChar == JSON_LBRACE || lexedChar == JSON_RBRACE || lexedChar == JSON_LBRACKET || lexedChar == JSON_RBRACKET) {
            [tokens addObject:[NSString stringWithFormat:@"%c", lexedChar]];
            [current deleteCharactersInRange:NSMakeRange(0, 1)];
            continue;
        } else {
            @throw [NSException exceptionWithName:@"InnateLexerException" reason:[NSString stringWithFormat:@"Unexpected character: %c", lexedChar] userInfo:nil];
        }
    }

    return tokens;
}

- (NSString *) lexString {
    NSMutableString *lexed = [[NSMutableString alloc] init];
    if ([current characterAtIndex:0] == JSON_QUOTE) {
        [lexed appendString:[NSString stringWithFormat:@"%c", JSON_QUOTE]];
        [current deleteCharactersInRange:NSMakeRange(0, 1)];
        while (current.length > 0) {
            unichar lexedChar = [current characterAtIndex:0];
            if (lexedChar == JSON_QUOTE) {
                [lexed appendString:[NSString stringWithFormat:@"%c", JSON_QUOTE]];
                [current deleteCharactersInRange:NSMakeRange(0, 1)];
                return lexed;
            } else if (lexedChar == '\\') {
                [lexed appendString:[NSString stringWithFormat:@"%c", '\\']];
                [current deleteCharactersInRange:NSMakeRange(0, 1)];
                if (current.length > 0) {
                    lexedChar = [current characterAtIndex:0];
                    if (lexedChar == 'b' || lexedChar == 'f' || lexedChar == 'n' || lexedChar == 'r' || lexedChar == 't' || lexedChar == '\\' || lexedChar == '/' || lexedChar == '"') {
                        [lexed appendString:[NSString stringWithFormat:@"%c", lexedChar]];
                        [current deleteCharactersInRange:NSMakeRange(0, 1)];
                    } else {
                        @throw [NSException exceptionWithName:@"InvalidEscapeSequence" reason:@"Invalid escape sequence" userInfo:nil];
                    }
                } else {
                    @throw [NSException exceptionWithName:@"InvalidEscapeSequence" reason:@"Invalid escape sequence" userInfo:nil];
                }
            } else {
                [lexed appendString:[NSString stringWithFormat:@"%c", lexedChar]];
                [current deleteCharactersInRange:NSMakeRange(0, 1)];
            }
        }
    }
    return nil;
}

- (NSString *) lexNumber {
    NSMutableString *lexed = [[NSMutableString alloc] init];
    if ([current characterAtIndex:0] == '-' || [current characterAtIndex:0] == '0' || [current characterAtIndex:0] == '1' || [current characterAtIndex:0] == '2' || [current characterAtIndex:0] == '3' || [current characterAtIndex:0] == '4' || [current characterAtIndex:0] == '5' || [current characterAtIndex:0] == '6' || [current characterAtIndex:0] == '7' || [current characterAtIndex:0] == '8' || [current characterAtIndex:0] == '9') {
        [lexed appendString:[NSString stringWithFormat:@"%c", [current characterAtIndex:0]]];
        [current deleteCharactersInRange:NSMakeRange(0, 1)];
        while (current.length > 0) {
            unichar lexedChar = [current characterAtIndex:0];
            if (lexedChar == '0' || lexedChar == '1' || lexedChar == '2' || lexedChar == '3' || lexedChar == '4' || lexedChar == '5' || lexedChar == '6' || lexedChar == '7' || lexedChar == '8' || lexedChar == '9') {
                [lexed appendString:[NSString stringWithFormat:@"%c", lexedChar]];
                [current deleteCharactersInRange:NSMakeRange(0, 1)];
            } else if (lexedChar == '.') {
                [lexed appendString:[NSString stringWithFormat:@"%c", lexedChar]];
                [current deleteCharactersInRange:NSMakeRange(0, 1)];
                if (current.length > 0) {
                    lexedChar = [current characterAtIndex:0];
                    if (lexedChar == '0' || lexedChar == '1' || lexedChar == '2' || lexedChar == '3' || lexedChar == '4' || lexedChar == '5' || lexedChar == '6' || lexedChar == '7' || lexedChar == '8' || lexedChar == '9') {
                        [lexed appendString:[NSString stringWithFormat:@"%c", lexedChar]];
                        [current deleteCharactersInRange:NSMakeRange(0, 1)];
                    }
                }
            } else {
                return lexed;
            }
        }
    }
    return nil;
}

- (NSString *) lexBool {
    if ([current characterAtIndex:0] == 't') {
        if (current.length >= 4) {
            if ([[current substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"true"]) {
                [current deleteCharactersInRange:NSMakeRange(0, 4)];
                return @"true";
            } else {
                @throw [NSException exceptionWithName:@"InvalidBoolean" reason:@"Invalid boolean" userInfo:nil];
            }
        } else {
            @throw [NSException exceptionWithName:@"InvalidBoolean" reason:@"Invalid boolean" userInfo:nil];
        }
    } else if ([current characterAtIndex:0] == 'f') {
        if (current.length >= 5) {
            if ([[current substringWithRange:NSMakeRange(0, 5)] isEqualToString:@"false"]) {
                [current deleteCharactersInRange:NSMakeRange(0, 5)];
                return @"false";
            } else {
                @throw [NSException exceptionWithName:@"InvalidBoolean" reason:@"Invalid boolean" userInfo:nil];
            }
        } else {
            @throw [NSException exceptionWithName:@"InvalidBoolean" reason:@"Invalid boolean" userInfo:nil];
        }
    }
    return nil;
}

- (NSString *) lexNull {
    if ([current characterAtIndex:0] == 'n') {
        if (current.length >= 4) {
            if ([[current substringWithRange:NSMakeRange(0, 4)] isEqualToString:@"null"]) {
                [current deleteCharactersInRange:NSMakeRange(0, 4)];
                return @"null";
            } else {
                @throw [NSException exceptionWithName:@"InvalidNull" reason:@"Invalid null" userInfo:nil];
            }
        } else {
            @throw [NSException exceptionWithName:@"InvalidNull" reason:@"Invalid null" userInfo:nil];
        }
    }
    return nil;
}

@end

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

#import <XCTest/XCTest.h>
#import "InnateLexer.h"
#import "InnateParser.h"
#import "InnateValue.h"

@interface InnateJsonTests : XCTestCase

@end

@implementation InnateJsonTests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testLexing {
    __block InnateLexer *lexer;
    __block NSArray<NSString *> *tokens;
    [self measureBlock:^{
        lexer = [[InnateLexer alloc] init:@"{\"glossary\":{\"title\":\"example glossary\",\"GlossDiv\":{\"title\":\"S\",\"GlossList\":{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"Standard Generalized Markup Language\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO 8879:1986\",\"GlossDef\":{\"para\":\"A meta-markup language, used to create markup languages such as DocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}}}}"];
        tokens = [lexer lex];
    }];
    NSArray<NSString *> *expected = @[@"{", @"\"glossary\"", @":", @"{", @"\"title\"", @":", @"\"example glossary\"", @",", @"\"GlossDiv\"", @":", @"{", @"\"title\"", @":", @"\"S\"", @",", @"\"GlossList\"", @":", @"{", @"\"GlossEntry\"", @":", @"{", @"\"ID\"", @":", @"\"SGML\"", @",", @"\"SortAs\"", @":", @"\"SGML\"", @",", @"\"GlossTerm\"", @":", @"\"Standard Generalized Markup Language\"", @",", @"\"Acronym\"", @":", @"\"SGML\"", @",", @"\"Abbrev\"", @":", @"\"ISO 8879:1986\"", @",", @"\"GlossDef\"", @":", @"{", @"\"para\"", @":", @"\"A meta-markup language, used to create markup languages such as DocBook.\"", @",", @"\"GlossSeeAlso\"", @":", @"[", @"\"GML\"", @",", @"\"XML\"", @"]", @"}", @",", @"\"GlossSee\"", @":", @"\"markup\"", @"}", @"}", @"}", @"}", @"}"];
    XCTAssertEqualObjects(tokens, expected);
}

- (void)testParsing {
    NSArray<NSString *> *tokens = [[[InnateLexer alloc] init:@"{\"key\":\"value\"}"] lex];
    InnateParser *parser = [InnateParser parserWithTokens:tokens];
    id <InnateValue> value = [parser parse];
    XCTAssert([value isObject]);
    NSDictionary<NSString *, id <InnateValue>> *dict = value.asObject;
    XCTAssertNotNil(dict);
    XCTAssertEqualObjects(dict[@"key"].asString, @"value");
}

@end

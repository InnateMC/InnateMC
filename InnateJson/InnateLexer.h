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

#ifndef InnateLexer_h
#define InnateLexer_h

#define JSON_COLON ':'
#define JSON_COMMA ','
#define JSON_LBRACE '{'
#define JSON_RBRACE '}'
#define JSON_LBRACKET '['
#define JSON_RBRACKET ']'
#define JSON_QUOTE '"'


@interface InnateLexer : NSObject {
    NSString *original;
    NSMutableString *current;
}

- (instancetype) init:(NSString *)json;

- (NSArray *) lex;

- (NSString *) lexString;

- (NSString *) lexNumber;

- (NSString *) lexBool;

- (NSString *) lexNull;

@end

#endif /* InnateLexer_h */

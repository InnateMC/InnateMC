//
//  InnateLexer.h
//  InnateJson
//
//  Created by Shrish Deshpande on 11/19/22.
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

//
//  InnateLexer.h
//  InnateJson
//
//  Created by Shrish Deshpande on 11/19/22.
//

#ifndef InnateLexer_h
#define InnateLexer_h

@interface InnateLexer : NSObject;

@property (readonly) NSString *original;
@property NSMutableString *current;

- (id)init;

- (void)lex;

- (NSString *) lexString:(NSString *)value;

- (NSString *) lexNumber:(NSString *)value;

- (NSString *) lexBool:(NSString *)value;

- (NSString *) lexNull:(NSString *)value;

@end

#endif /* InnateLexer_h */

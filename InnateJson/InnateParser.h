//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>

@protocol InnateValue;


@interface InnateParser : NSObject {
    NSArray<NSString *> *tokens;
    NSUInteger current;
}

+ (NSDictionary<NSString *, id<InnateValue>> *)readJson:(NSString*)tokens;

+ (InnateParser *)parserWithTokens:(NSArray<NSString *> *)tokens;

- (id <InnateValue>)parse;

@end

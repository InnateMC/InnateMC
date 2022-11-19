//
// Created by Shrish Deshpande on 11/19/22.
//

#import <Foundation/Foundation.h>

@protocol InnateValue;


@interface InnateParser : NSObject {
    NSArray<NSString *> *tokens;
    NSUInteger current;
}

+ (InnateParser *)parserWithTokens:(NSArray<NSString *> *)tokens;

- (id <InnateValue>)parse;

@end

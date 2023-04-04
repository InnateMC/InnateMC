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
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.
//

#import <Foundation/Foundation.h>
#import "InnateZipExtractor.h"
#import "InnateNativeExtractor.h"

@implementation InnateZipExtractor

+ (instancetype)create:(NSURL *)inputFile output:(NSURL *)outputDir {
    InnateZipExtractor* ize = [[InnateZipExtractor alloc] init:inputFile output:outputDir];
    return ize;
}

- (instancetype)init:(NSURL *)inputFile output:(NSURL *)outputDir {
    self = [super init];
    input = inputFile;
    output = outputDir;
    return self;
}

- (void)extract {
    const char* inputStr = strdup([input.path UTF8String]);
    const char* outputStr = strdup([output.path UTF8String]);
    extractNatives(inputStr, outputStr);
    free((void *)inputStr);
    free((void *)outputStr);
}

@end

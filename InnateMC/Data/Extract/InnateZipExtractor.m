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
#include <zip.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <limits.h>
#include <sys/stat.h>

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

void extractNatives(const char* input, const char* output) {
    struct zip *zip_file;
    struct zip_file *file;
    struct zip_stat stat;
    
    zip_file = zip_open(input, 0, NULL);
    if (!zip_file) {
        printf("Failed to open zip file %s\n", input);
    }
    
    int num_files = zip_get_num_files(zip_file);
    for (int i = 0; i < num_files; i++) {
        zip_stat_init(&stat);
        zip_stat_index(zip_file, i, 0, &stat);
        
        const char *filename = stat.name;
        const char *extension = strrchr(filename, '.');
        if (extension && (strcmp(extension, ".dylib") == 0 || strcmp(extension, ".jnilib") == 0)) {
            char output_filename[PATH_MAX];
            sprintf(output_filename, "%s/%s", output, filename);
            
            file = zip_fopen_index(zip_file, i, 0);
            if (!file) {
                printf("Failed to open file %s in zip\n", filename);
                continue;
            }
            
            FILE *output_file = fopen(output_filename, "wb");
            if (!output_file) {
                printf("Failed to create output file %s\n", output_filename);
                zip_fclose(file);
                continue;
            }
            
            char buffer[1024];
            int num_bytes;
            while ((num_bytes = zip_fread(file, buffer, sizeof(buffer))) > 0) {
                fwrite(buffer, 1, num_bytes, output_file);
            }
            
            fclose(output_file);
            zip_fclose(file);
        }
    }
    
    zip_close(zip_file);
}

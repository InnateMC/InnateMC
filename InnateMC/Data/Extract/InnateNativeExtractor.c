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

#include "InnateNativeExtractor.h"
#include "zip.h"
#include <stdlib.h>
#include "string.h"
#include <stdio.h>

void extractNatives(const char* input, const char* output) {
    int errorp = 0;
    zip_t* archive = zip_open(input, 0, &errorp);
    struct zip_stat* finfo = calloc(512, sizeof(int));
    zip_stat_init(finfo);
    zip_file_t* fd = NULL;
    char* contents = NULL;
    int count = 0;
    while ((zip_stat_index(archive, count, 0, finfo)) == 0) {
        fd = zip_fopen_index(archive, count, 0); // opens file at count index
        if (strstr(finfo->name, "dylib") != NULL || strstr(finfo->name, "jnilib") != NULL) {
            contents = calloc(finfo->size + 1, sizeof(char));
            zip_fread(fd, contents, finfo->size);
            char *buffer;
            size_t bufferLen = strlen(output) + strlen(finfo->name) + 1;
            buffer = (char *)malloc(bufferLen);
            strcpy(buffer, output);
            strcat(buffer, finfo->name);
            FILE *file = fopen(buffer, "w");
            fprintf(file, "%s", contents);
            free(buffer);
            free(contents);
        }
        count++;
    }
}

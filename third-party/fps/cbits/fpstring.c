/*
 * Copyright (c) 2003 David Roundy
 * Copyright (c) 2005-6 Don Stewart
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the names of the authors or the names of any contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include "fpstring.h"

/* copy a string in reverse */
void reverse(unsigned char *dest, unsigned char *from, int len) {
    unsigned char *p, *q;
    p = from + len - 1;
    q = dest;

    while (p >= from)
        *q++ = *p--;
}

/* compare bytes ascii-wise */
static int cmp(const void *p, const void *q) {
    return (*(unsigned char *)p - *(unsigned char *)q);
}

/* quicksort wrapper */
void my_qsort(unsigned char *base, size_t size) {
    qsort(base, size, sizeof(char), cmp);
}

/* duplicate a string, interspersing the character through the elements
   of the duplicated string */
void intersperse(unsigned char *dest, unsigned char *from, int len, char c) {
    unsigned char *p, *q;
    p = from;
    q = dest;
    while (p < from + len - 1) {
        *q++ = *p++; 
        *q++ = c;
    }
    *q = *p;
}

/* find maximum char in a packed string */
unsigned char maximum(unsigned char *p, int len) {
    unsigned char *q, c = *p;
    for (q = p; q < p + len; q++)
        if (*q > c)
            c = *q;
    return c;
}

/* find minimum char in a packed string */
unsigned char minimum(unsigned char *p, int len) {
    unsigned char *q, c = *p;
    for (q = p; q < p + len; q++)
        if (*q < c)
            c = *q;
    return c;
}

/* count the number of occurences of a char in a string */
int count(unsigned char *p, int len, unsigned char w) {
    int c;
    for (c = 0; len--; ++p)
        if (*p == w)
            ++c;
    return c;
}

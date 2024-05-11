//
//  PunyCode.m
//  BBAFoundation
//
//  Created by Zhu,Yusong on 2018/9/28.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "PunyCode.h"

#ifndef MAX_HOSTNAME_LEN
#ifdef NI_MAXHOST
#define MAX_HOSTNAME_LEN NI_MAXHOST
#else
#define MAX_HOSTNAME_LEN 1024
#endif
#endif

#define ACEPrefix @"xn--"   // Prefix for encoded labels, defined in RFC3490 [5]

#define encode_character(c) (c) < 26 ? (c) + 'a' : (c) - 26 + '0'

static int adaptPunycodeDelta(int delta, int number, BOOL firstTime)
{
    int power;
    
    delta = firstTime ? delta / 700 : delta / 2;
    delta += delta / number;
    
    for (power = 0; delta > (35 * 26) / 2; power += 36)
        delta /= 35;
    return power + (35 + 1) * delta / (delta + 38);
}

@implementation PunyCode

+ (NSString *)utf8HostToAscii:(NSString *)string {
    if ([string canBeConvertedToEncoding:NSASCIIStringEncoding]) {
        return string;
    }
    NSMutableArray *labels = [[string componentsSeparatedByString:@"."] mutableCopy];
    for (NSUInteger i = 0; i < labels.count; ++i) {
        NSString *part = labels[i];
        if (![part canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            [labels replaceObjectAtIndex:i withObject:[PunyCode encode:part]];
        }
    }
    NSString *result = [labels componentsJoinedByString:@"."];
    return result;
}

+ (NSString *)encode:(NSString *)aString {
    // setup buffers
    char outputBuffer[MAX_HOSTNAME_LEN];
    size_t stringLength = [aString length];
    unichar *inputBuffer = alloca(stringLength * sizeof(unichar));
    unichar *inputPtr, *inputEnd = inputBuffer + stringLength;
    char *outputEnd = outputBuffer + MAX_HOSTNAME_LEN;
    char *outputPtr = outputBuffer;
    
    // check once for hostname too long here and just refuse to encode if it is (this handles it if all ASCII)
    // there are additional checks for running over the buffer during the encoding loop
    if (stringLength > MAX_HOSTNAME_LEN)
        return aString;
    
    [aString getCharacters:inputBuffer];
    
    // handle ASCII characters
    for (inputPtr = inputBuffer; inputPtr < inputEnd; inputPtr++) {
        if (*inputPtr < 0x80)
            *outputPtr++ = *inputPtr;
    }
    unsigned int handled = (unsigned int)(outputPtr - outputBuffer);
    
    if (handled == stringLength)
        return aString;
    
    // add dash separator
    if (handled > 0 && outputPtr < outputEnd)
        *outputPtr++ = '-';
    
    // encode the rest
    int n = 0x80;
    int delta = 0;
    int bias = 72;
    BOOL firstTime = YES;
    
    while (handled < stringLength) {
        unichar max = (unichar)-1;
        for (inputPtr = inputBuffer; inputPtr < inputEnd; inputPtr++) {
            if (*inputPtr >= n && *inputPtr < max)
                max = *inputPtr;
        }
        
        delta += (max - n) * (handled + 1);
        n = max;
        
        for (inputPtr = inputBuffer; inputPtr < inputEnd; inputPtr++) {
            if (*inputPtr < n)
                delta++;
            else if (*inputPtr == n) {
                int oldDelta = delta;
                int power = 36;
                
                while (1) {
                    int t;
                    if (power <= bias)
                        t = 1;
                    else if (power >= bias + 26)
                        t = 26;
                    else
                        t = power - bias;
                    if (delta < t)
                        break;
                    if (outputPtr >= outputEnd)
                        return aString;
                    *outputPtr++ = encode_character(t + (delta - t) % (36 - t));
                    delta = (delta - t) / (36 - t);
                    power += 36;
                }
                
                if (outputPtr >= outputEnd)
                    return aString;
                *outputPtr++ = encode_character(delta);
                bias = adaptPunycodeDelta(oldDelta, ++handled, firstTime);
                firstTime = NO;
                delta = 0;
            }
        }
        delta++;
        n++;
    }
    if (outputPtr >= outputEnd)
        return aString;
    *outputPtr = '\0';
    
    return [ACEPrefix stringByAppendingString:[NSString stringWithUTF8String:outputBuffer]];
}

@end

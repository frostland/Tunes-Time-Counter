/*
 * FLDurationTransformer.m
 * Tunes Time Counter
 * 
 * Created by François LAMBOLEY on 5/22/11.
 * Copyright 2011 Frost Land. All rights reserved.
 */

#import "FLDurationTransformer.h"

#import "FLUtils.h"

@implementation FLDurationTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)number
{
	return FLDurationToString([number doubleValue]);
}

@end

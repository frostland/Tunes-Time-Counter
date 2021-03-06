/*
 * FRLDurationTransformer.m
 * Tunes Time Counter
 * 
 * Created by François LAMBOLEY on 5/22/11.
 * Copyright 2011 Frost Land. All rights reserved.
 */

#import "FRLDurationTransformer.h"

#import "FRLUtils.h"



@implementation FRLDurationTransformer

+ (Class)transformedValueClass
{
    return NSString.class;
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)number
{
	return FRLDurationToString([number doubleValue], YES);
}

@end

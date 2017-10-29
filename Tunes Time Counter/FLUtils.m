/*
 *  FLUtils.c
 *  Tunes Time Counter
 *
 *  Created by François LAMBOLEY on 5/22/11.
 *  Copyright 2011 Frost Land. All rights reserved.
 */

#import "FLUtils.h"



NSString *FLDurationToString(double d, BOOL full) {
	NSUInteger j = d / (3600*24);
	NSUInteger h = d / 3600;
	NSUInteger m = d / 60;
	NSUInteger s = d + .5;
	
	s -= m*60;
	m -= h*60;
	h -= j*24;
	if (full) {
		if (j == 0 && h == 0) return [NSString stringWithFormat:@"%lu:%02lu", (unsigned long)m, (unsigned long)s];
		else if (j == 0)      return [NSString stringWithFormat:@"%lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
		else                  return [NSString stringWithFormat:@"%lu:%02lu:%02lu:%02lu", (unsigned long)j, (unsigned long)h, (unsigned long)m, (unsigned long)s];
	} else {
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter new] autorelease];
		[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[numberFormatter setRoundingIncrement:[NSNumber numberWithFloat:.1]];
		
		float v;
		NSString *fmt;
		if (j == 0 && h == 0 && m == 0) return [NSString stringWithFormat:NSLocalizedString(@"n second(s)", nil), (NSUInteger)(d+0.5), (d < 0.5 || d >= 1.5)? NSLocalizedString(@"plural", nil): @""];
		else if (j == 0 && h == 0)      {v = d/60.;         fmt = NSLocalizedString(@"str minute(s)", nil);}
		else if (j == 0)                {v = d/3600.;       fmt = NSLocalizedString(@"str hour(s)", nil);}
		else                            {v = d/(3600.*24.); fmt = NSLocalizedString(@"str day(s)", nil);}
		
		NSString *vrstr = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:v]];
		float vr = [[numberFormatter numberFromString:vrstr] floatValue];
		return [NSString stringWithFormat:fmt, vrstr, (vr == 1)? @"": NSLocalizedString(@"plural", nil)];
	}
}

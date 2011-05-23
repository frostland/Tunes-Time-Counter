/*
 *  FLUtils.c
 *  Tunes Time Counter
 *
 *  Created by François LAMBOLEY on 5/22/11.
 *  Copyright 2011 Frost Land. All rights reserved.
 */

#import "FLUtils.h"

// TODO: localize
NSString *FLDurationToString(double d, BOOL full) {
	NSUInteger j = d / (3600*24);
	NSUInteger h = d / 3600;
	NSUInteger m = d / 60;
	NSUInteger s = d;
	
	s -= m*60;
	m -= h*60;
	h -= j*24;
	if (full) {
		if (j == 0 && h == 0) return [NSString stringWithFormat:@"%u:%02u", m, s];
		else if (j == 0)      return [NSString stringWithFormat:@"%u:%02u:%02u", h, m, s];
		else                  return [NSString stringWithFormat:@"%u:%02u:%02u:%02u", j, h, m, s];
	} else {
		if (j == 0 && h == 0 && m == 0) return [NSString stringWithFormat:@"%u seconds", (NSUInteger)d];
		else if (j == 0 && h == 0)      return [NSString stringWithFormat:@"%.1f minutes", d/60.];
		else if (j == 0)                return [NSString stringWithFormat:@"%.1f hours", d/3600.];
		else                            return [NSString stringWithFormat:@"%.1f days", d/(3600.*24.)];
	}
}

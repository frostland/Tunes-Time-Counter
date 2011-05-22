/*
 *  FLUtils.c
 *  Tunes Time Counter
 *
 *  Created by François LAMBOLEY on 5/22/11.
 *  Copyright 2011 Frost Land. All rights reserved.
 */

#import "FLUtils.h"

NSString *FLDurationToString(double d) {
	NSUInteger j = d / (3600*24);
	NSUInteger h = d / 3600;
	NSUInteger m = d / 60;
	NSUInteger s = d;
	
	s -= m*60;
	m -= h*60;
	h -= j*24;
	if (j == 0 && h == 0) return [NSString stringWithFormat:@"%u:%02u", m, s];
	else if (j == 0)      return [NSString stringWithFormat:@"%u:%02u:%02u", h, m, s];
	else                  return [NSString stringWithFormat:@"%u:%02u:%02u:%02u", j, h, m, s];
}

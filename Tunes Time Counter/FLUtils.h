/*
 *  FLUtils.h
 *  Tunes Time Counter
 *
 *  Created by François LAMBOLEY on 5/22/11.
 *  Copyright 2011 Frost Land. All rights reserved.
 */

#import <Foundation/Foundation.h>

#ifdef DEBUG
/* Not standard, but very useful... */
#define NSDLog(...) NSLog(__VA_ARGS__)
#else
#define NSDLog(...) ((void)0)
#endif

NSString *FLDurationToString(double d, BOOL full);

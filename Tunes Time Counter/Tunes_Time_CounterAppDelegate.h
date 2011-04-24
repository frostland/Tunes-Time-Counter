//
//  Tunes_Time_CounterAppDelegate.h
//  Tunes Time Counter
//
//  Created by François LAMBOLEY on 4/24/11.
//  Copyright 2011 Frost Land. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Tunes_Time_CounterAppDelegate : NSObject <NSApplicationDelegate> {
@private
	NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end

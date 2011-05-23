/*
 * TunesTimeCounterAppDelegate.h
 * Tunes Time Counter
 * 
 * This class is the delegate of the application
 * It will also be the main class of the project
 * 
 * Created by François LAMBOLEY on 4/24/11.
 * Copyright 2011 Frost Land. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import "iTunes.h"

@interface TunesTimeCounterAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate> {
	BOOL fullInfos;
	NSString *infos;
	NSMutableArray *tracksProperties;
	
@private
	NSWindow *window;
	NSWindow *windowRefreshing;
	NSProgressIndicator *progressIndicator;
	NSArrayController *tracksPropertiesController;
	
	NSThread *threadRefreshingTracksInfos;
	iTunesApplication *iTunes;
	
	BOOL justLaunched;
}
@property(assign) IBOutlet NSWindow *window;
@property(assign) IBOutlet NSWindow *windowRefreshing;
@property(assign) IBOutlet NSProgressIndicator *progressIndicator;
@property(assign) IBOutlet NSArrayController *tracksPropertiesController;
@property(copy) NSString *infos;
@property(retain) NSMutableArray *tracksProperties;

- (IBAction)noteFilterChanged:(id)sender;
- (IBAction)goToNextDisplayType:(id)sender;

- (IBAction)refreshTracksInfos:(id)sender;
- (IBAction)stopRefresh:(id)sender;

@end

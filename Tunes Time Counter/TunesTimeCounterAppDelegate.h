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

#import "FLPreferencesWindowController.h"



@interface TunesTimeCounterAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate> {
	BOOL fullInfos;
	NSString *infos;
	NSMutableArray *tracksProperties;
	
@private
	NSWindow *window;
	
	NSButton *buttonStop;
	NSWindow *windowRefreshing;
	NSProgressIndicator *progressIndicator;
	
	NSArrayController *tracksPropertiesController;
	NSTableColumn *tableColumnArtist, *tableColumnAlbum, *tableColumnComposer;
	NSMenuItem *columnMenuItemArtist, *columnMenuItemAlbum, *columnMenuItemComposer;
	
	FLPreferencesWindowController *prefWindowController;
	
	NSThread *threadRefreshingTracksInfos;
	iTunesApplication *iTunes;
	
	BOOL justLaunched;
}

@property(retain) IBOutlet NSWindow *window;

@property(retain) IBOutlet NSButton *buttonStop;
@property(retain) IBOutlet NSWindow *windowRefreshing;
@property(retain) IBOutlet NSProgressIndicator *progressIndicator;

@property(retain) IBOutlet NSArrayController *tracksPropertiesController;
@property(retain) IBOutlet NSTableColumn *tableColumnArtist;
@property(retain) IBOutlet NSTableColumn *tableColumnAlbum;
@property(retain) IBOutlet NSTableColumn *tableColumnComposer;
@property(retain) IBOutlet NSMenuItem *columnMenuItemArtist;
@property(retain) IBOutlet NSMenuItem *columnMenuItemAlbum;
@property(retain) IBOutlet NSMenuItem *columnMenuItemComposer;

@property(copy) NSString *infos;
@property(retain) NSArray *tracksProperties;

- (IBAction)showPreferences:(id)sender;

- (IBAction)noteFilterChanged:(id)sender;
- (IBAction)goToNextDisplayType:(id)sender;

- (IBAction)refreshTracksInfos:(id)sender;
- (IBAction)stopRefresh:(id)sender;

- (IBAction)switchArtistColumn:(id)sender;
- (IBAction)switchAlbumColumn:(id)sender;
- (IBAction)switchComposerColumn:(id)sender;

@end

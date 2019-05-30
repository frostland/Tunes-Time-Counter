/*
 * TunesTimeCounterAppDelegate.m
 * Tunes Time Counter
 *
 * Created by François LAMBOLEY on 4/24/11.
 * Copyright 2011 Frost Land. All rights reserved.
 */

#import "TunesTimeCounterAppDelegate.h"

#import "FLUtils.h"
#import "FLConstants.h"

@interface TunesTimeCounterAppDelegate (Private)

- (void)updateInfosString;

@end

@implementation TunesTimeCounterAppDelegate

@synthesize window, windowRefreshing, progressIndicator, tracksPropertiesController, buttonStop;
@synthesize columnMenuItemArtist, columnMenuItemAlbum, columnMenuItemComposer;
@synthesize tableColumnArtist, tableColumnAlbum, tableColumnComposer;
@synthesize infos, tracksProperties;

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:FL_UDK_FULL_INFOS];
	[defaultValues setValue:[NSNumber numberWithBool:NO]  forKey:FL_UDK_SHOW_ZERO_LENGTH_TRACKS];
	
	[NSUserDefaults.standardUserDefaults registerDefaults:defaultValues];
}

- (id)init
{
	if ((self = [super init]) != nil) {
		fullInfos = [NSUserDefaults.standardUserDefaults boolForKey:FL_UDK_FULL_INFOS];
		
		justLaunched = YES;
		[self updateInfosString];
		tracksProperties = [NSMutableArray new];
		iTunes = (iTunesApplication *)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
	}
	return self;
}

- (void)dealloc
{
	[prefWindowController release];
	prefWindowController = nil;
	
	[threadRefreshingTracksInfos release];
	threadRefreshingTracksInfos = nil;
	[tracksProperties release];
	tracksProperties = nil;
	[iTunes release];
	iTunes = nil;
	
	self.infos = nil;
	
	[super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[columnMenuItemArtist   setState:[tableColumnArtist   isHidden]? NSOffState: NSOnState];
	[columnMenuItemAlbum    setState:[tableColumnAlbum    isHidden]? NSOffState: NSOnState];
	[columnMenuItemComposer setState:[tableColumnComposer isHidden]? NSOffState: NSOnState];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	if (justLaunched) {
		justLaunched = NO;
		[self refreshTracksInfos:nil];
	}
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

- (void)doRefreshTracksInfos:(id)threadDatas
{
	/* We are in a thread */
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[self willChangeValueForKey:@"tracksProperties"];
	
	if (!iTunes.isRunning) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"iTunes not running", nil)
														defaultButton:NSLocalizedString(@"ok maj", nil)
													 alternateButton:nil
														  otherButton:nil
										informativeTextWithFormat:NSLocalizedString(@"please launch iTunes to refresh track infos", nil)];
			[alert runModal];
		});
		goto end;
	}
	
	BOOL showsZeroLength = [NSUserDefaults.standardUserDefaults boolForKey:FL_UDK_SHOW_ZERO_LENGTH_TRACKS];
	[self.tracksProperties removeAllObjects];
	
	for (iTunesSource *curSource in iTunes.sources) {
		if ([curSource kind] != iTunesESrcLibrary) continue;
		
		for (iTunesPlaylist *curPlaylist in [curSource libraryPlaylists]) {
			for (iTunesFileTrack *curTrack in [[curPlaylist tracks] get]) {
				if ([[NSThread currentThread] isCancelled]) goto end;
				
				NSInteger playedCount = [curTrack playedCount];
				double duration = [curTrack finish]-[curTrack start];
				NSMutableDictionary *added = [NSMutableDictionary dictionary];
				[added setObject:[curTrack name] forKey:@"track_name"];
				[added setObject:[curTrack sortName] forKey:@"sort_track_name"];
				[added setObject:[curTrack artist] forKey:@"artist"];
				[added setObject:[curTrack sortArtist] forKey:@"sort_artist"];
				[added setObject:[curTrack album] forKey:@"album"];
				[added setObject:[curTrack sortAlbum] forKey:@"sort_album"];
				[added setObject:[curTrack composer] forKey:@"composer"];
				[added setObject:[curTrack sortComposer] forKey:@"sort_composer"];
				[added setObject:[NSNumber numberWithDouble:duration] forKey:@"track_length"];
				[added setObject:[NSNumber numberWithInteger:playedCount] forKey:@"play_count"];
				[added setObject:[NSNumber numberWithDouble:duration*playedCount] forKey:@"total_play_time"];
				if ([curTrack playedDate] != nil) [added setObject:[curTrack playedDate] forKey:@"last_played_date"];
				
				if ([[added objectForKey:@"sort_track_name"] isEqualToString:@""]) [added setObject:[added objectForKey:@"track_name"] forKey:@"sort_track_name"];
				if ([[added objectForKey:@"sort_artist"] isEqualToString:@""]) [added setObject:[added objectForKey:@"artist"] forKey:@"sort_artist"];
				if ([[added objectForKey:@"sort_album"] isEqualToString:@""]) [added setObject:[added objectForKey:@"album"] forKey:@"sort_album"];
				if ([[added objectForKey:@"sort_composer"] isEqualToString:@""]) [added setObject:[added objectForKey:@"composer"] forKey:@"sort_composer"];
				if (showsZeroLength || duration > 0) [self.tracksProperties addObject:added];
			}
		}
	}
	
end:
	[self didChangeValueForKey:@"tracksProperties"];
	[pool drain];
	[NSThread exit];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateInfosString];
}

- (IBAction)showPreferences:(id)sender
{
	if (!prefWindowController) prefWindowController = [[FLPreferencesWindowController alloc] initWithWindowNibName:@"FLPreferencesWindow"];
	[prefWindowController showWindow:self];
}

- (IBAction)switchArtistColumn:(id)sender
{
	[tableColumnArtist setHidden:![tableColumnArtist isHidden]];
	[columnMenuItemArtist setState:([columnMenuItemArtist state] == NSOnState)? NSOffState: NSOnState];
}

- (IBAction)switchAlbumColumn:(id)sender
{
	[tableColumnAlbum setHidden:![tableColumnAlbum isHidden]];
	[columnMenuItemAlbum setState:([columnMenuItemAlbum state] == NSOnState)? NSOffState: NSOnState];
}

- (IBAction)switchComposerColumn:(id)sender
{
	[tableColumnComposer setHidden:![tableColumnComposer isHidden]];
	[columnMenuItemComposer setState:([columnMenuItemComposer state] == NSOnState)? NSOffState: NSOnState];
}

- (IBAction)refreshTracksInfos:(id)sender
{
	if ([threadRefreshingTracksInfos isExecuting]) {
		NSDLog(@"We shouldn't arrive here...");
		return;
	}
	
	[buttonStop setEnabled:YES];
	[buttonStop setTitle:NSLocalizedString(@"stop", nil)];
	[progressIndicator setIndeterminate:YES];
	[progressIndicator stopAnimation:self];
	[progressIndicator startAnimation:self];
	[NSApp beginSheet:windowRefreshing modalForWindow:window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	
	threadRefreshingTracksInfos = [[NSThread alloc] initWithTarget:self selector:@selector(doRefreshTracksInfos:) object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillExit:) name:NSThreadWillExitNotification object:threadRefreshingTracksInfos];
	
	[threadRefreshingTracksInfos start];
}

- (IBAction)noteFilterChanged:(id)sender
{
	[self updateInfosString];
}

- (IBAction)goToNextDisplayType:(id)sender
{
	fullInfos = !fullInfos;
	[NSUserDefaults.standardUserDefaults setBool:fullInfos forKey:FL_UDK_FULL_INFOS];
	
	[self updateInfosString];
}

- (void)threadWillExit:(NSNotification *)n
{
	[threadRefreshingTracksInfos release];
	threadRefreshingTracksInfos = nil;
	[self updateInfosString];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[NSApp endSheet:windowRefreshing];
	});
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[windowRefreshing orderOut:nil];
}

- (IBAction)stopRefresh:(id)sender
{
	[buttonStop setEnabled:NO];
	[buttonStop setTitle:NSLocalizedString(@"stopping", nil)];
	if (![threadRefreshingTracksInfos isCancelled])
		[threadRefreshingTracksInfos cancel];
}

@end

@implementation TunesTimeCounterAppDelegate (Private)

- (void)updateInfosString
{
	BOOL infoForSelection = YES;
	
	NSUInteger nSelectedObjects;
	NSArray *selectedObjects = [tracksPropertiesController selectedObjects];
	if ([selectedObjects count] <= 1) {
		infoForSelection = NO;
		selectedObjects = [tracksPropertiesController arrangedObjects];
	}
	
	nSelectedObjects = [selectedObjects count];
	
	double sTotalDuration = 0;
	double sTotalListenedDuration = 0;
	for (NSDictionary *curTrack in selectedObjects) {
		double tl = [[curTrack objectForKey:@"track_length"] doubleValue];
		sTotalDuration += tl;
		sTotalListenedDuration += tl*[[curTrack objectForKey:@"play_count"] doubleValue];
	};
	
	NSString *selectedInfoString = infoForSelection? NSLocalizedString(@" selected", nil): @"";
	self.infos = [NSString stringWithFormat:NSLocalizedString(@"general infos str", nil),
					  nSelectedObjects, (nSelectedObjects == 0 || nSelectedObjects > 1)? NSLocalizedString(@"plural", nil): @"",
					  selectedInfoString,
					  selectedInfoString, FLDurationToString(sTotalDuration, fullInfos),
					  selectedInfoString, FLDurationToString(sTotalListenedDuration, fullInfos)];
}

@end

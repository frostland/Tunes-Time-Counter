/*
 * FRLAppDelegate.m
 * Tunes Time Counter
 *
 * Created by François LAMBOLEY on 4/24/11.
 * Copyright 2011 Frost Land. All rights reserved.
 */

#import "FRLAppDelegate.h"

#import "FRLUtils.h"
#import "FRLConstants.h"



@interface FRLAppDelegate (Private)

- (void)updateInfosString;

@end


@implementation FRLAppDelegate

+ (void)initialize
{
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	[defaultValues setValue:[NSNumber numberWithBool:YES] forKey:FRL_UDK_FULL_INFOS];
	[defaultValues setValue:[NSNumber numberWithBool:NO]  forKey:FRL_UDK_SHOW_ZERO_LENGTH_TRACKS];
	
	[NSUserDefaults.standardUserDefaults registerDefaults:defaultValues];
}

- (id)init
{
	if ((self = [super init]) != nil) {
		fullInfos = [NSUserDefaults.standardUserDefaults boolForKey:FRL_UDK_FULL_INFOS];
		
		justLaunched = YES;
		[self updateInfosString];
		self.tracksProperties = [NSMutableArray new];
		iTunes = (iTunesApplication *)[[SBApplication alloc] initWithBundleIdentifier:@"com.apple.iTunes"];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[self.columnMenuItemArtist   setState:[self.tableColumnArtist   isHidden]? NSOffState: NSOnState];
	[self.columnMenuItemAlbum    setState:[self.tableColumnAlbum    isHidden]? NSOffState: NSOnState];
	[self.columnMenuItemComposer setState:[self.tableColumnComposer isHidden]? NSOffState: NSOnState];
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
	if (!iTunes.isRunning) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"iTunes not running", nil)
														defaultButton:NSLocalizedString(@"ok maj", nil)
													 alternateButton:nil
														  otherButton:nil
										informativeTextWithFormat:NSLocalizedString(@"please launch iTunes to refresh track infos", nil)];
			[alert runModal];
		});
		[NSThread exit];
		return;
	}
	
	BOOL showsZeroLength = [NSUserDefaults.standardUserDefaults boolForKey:FRL_UDK_SHOW_ZERO_LENGTH_TRACKS];
	
	NSMutableArray *newTrackProperties = [NSMutableArray new];
	void (^end)(void) = ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			self.tracksProperties = newTrackProperties;
		});
		[NSThread exit];
	};
	
	for (iTunesSource *curSource in iTunes.sources) {
		if ([curSource kind] != iTunesESrcLibrary) continue;
		
		for (iTunesPlaylist *curPlaylist in [curSource libraryPlaylists]) {
			for (iTunesFileTrack *curTrack in [[curPlaylist tracks] get]) {
				if (NSThread.currentThread.isCancelled) {end(); return;}
				
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
				if (showsZeroLength || duration > 0) [newTrackProperties addObject:added];
			}
		}
	}
	
	end();
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateInfosString];
}

- (IBAction)showPreferences:(id)sender
{
	if (!prefWindowController) prefWindowController = [[FRLPreferencesWindowController alloc] initWithWindowNibName:@"FRLPreferencesWindow"];
	[prefWindowController showWindow:self];
}

- (IBAction)switchArtistColumn:(id)sender
{
	[self.tableColumnArtist setHidden:![self.tableColumnArtist isHidden]];
	[self.columnMenuItemArtist setState:([self.columnMenuItemArtist state] == NSOnState)? NSOffState: NSOnState];
}

- (IBAction)switchAlbumColumn:(id)sender
{
	[self.tableColumnAlbum setHidden:![self.tableColumnAlbum isHidden]];
	[self.columnMenuItemAlbum setState:([self.columnMenuItemAlbum state] == NSOnState)? NSOffState: NSOnState];
}

- (IBAction)switchComposerColumn:(id)sender
{
	[self.tableColumnComposer setHidden:![self.tableColumnComposer isHidden]];
	[self.columnMenuItemComposer setState:([self.columnMenuItemComposer state] == NSOnState)? NSOffState: NSOnState];
}

- (IBAction)refreshTracksInfos:(id)sender
{
	if (threadRefreshingTracksInfos.isExecuting) {
		NSDLog(@"We shouldn't arrive here...");
		return;
	}
	
	[self.buttonStop setEnabled:YES];
	[self.buttonStop setTitle:NSLocalizedString(@"stop", nil)];
	[self.progressIndicator setIndeterminate:YES];
	[self.progressIndicator stopAnimation:self];
	[self.progressIndicator startAnimation:self];
	[NSApp beginSheet:self.windowRefreshing modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:NULL];
	
	threadRefreshingTracksInfos = [[NSThread alloc] initWithTarget:self selector:@selector(doRefreshTracksInfos:) object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(threadWillExit:) name:NSThreadWillExitNotification object:threadRefreshingTracksInfos];
	
	[threadRefreshingTracksInfos start];
}

- (IBAction)noteFilterChanged:(id)sender
{
	[self updateInfosString];
}

- (IBAction)goToNextDisplayType:(id)sender
{
	fullInfos = !fullInfos;
	[NSUserDefaults.standardUserDefaults setBool:fullInfos forKey:FRL_UDK_FULL_INFOS];
	
	[self updateInfosString];
}

- (void)threadWillExit:(NSNotification *)n
{
	threadRefreshingTracksInfos = nil;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self updateInfosString];
		[NSApp endSheet:self.windowRefreshing];
	});
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[self.windowRefreshing orderOut:nil];
}

- (IBAction)stopRefresh:(id)sender
{
	[self.buttonStop setEnabled:NO];
	[self.buttonStop setTitle:NSLocalizedString(@"stopping", nil)];
	if (!threadRefreshingTracksInfos.isCancelled)
		[threadRefreshingTracksInfos cancel];
}

@end


@implementation FRLAppDelegate (Private)

- (void)updateInfosString
{
	BOOL infoForSelection = YES;
	
	NSUInteger nSelectedObjects;
	NSArray *selectedObjects = [self.tracksPropertiesController selectedObjects];
	if ([selectedObjects count] <= 1) {
		infoForSelection = NO;
		selectedObjects = [self.tracksPropertiesController arrangedObjects];
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
					  selectedInfoString, FRLDurationToString(sTotalDuration, fullInfos),
					  selectedInfoString, FRLDurationToString(sTotalListenedDuration, fullInfos)];
}

@end

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


#define MUSIC_BUNDLE_ID  (@"com.apple.Music")
#define ITUNES_BUNDLE_ID (@"com.apple.iTunes")



@interface FRLAppDelegate (Private)

- (void)updateInfosString;
- (BOOL)hasAccessToMusicApp;

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
		music = (MusicApplication *)[[SBApplication alloc] initWithBundleIdentifier:MUSIC_BUNDLE_ID];
		iTunes = (iTunesApplication *)[[SBApplication alloc] initWithBundleIdentifier:ITUNES_BUNDLE_ID];
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
	if (!iTunes.isRunning && !music.isRunning) {
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
	
	if (![self hasAccessToMusicApp]) {
		dispatch_async(dispatch_get_main_queue(), ^{
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"needs permission title", nil)
														defaultButton:NSLocalizedString(@"ok maj", nil)
													 alternateButton:nil
														  otherButton:nil
										informativeTextWithFormat:NSLocalizedString(@"needs permission content", nil)];
			[alert runModal];
		});
		[NSThread exit];
		return;
	}
	
	BOOL showsZeroLength = [NSUserDefaults.standardUserDefaults boolForKey:FRL_UDK_SHOW_ZERO_LENGTH_TRACKS];
	
	NSMutableArray *newTracksProperties = [NSMutableArray new];
	void (^end)(void) = ^{
		dispatch_async(dispatch_get_main_queue(), ^{
			self.tracksProperties = newTracksProperties;
		});
		[NSThread exit];
	};
	
#define CREATE_NEW_TRACKS_PROPERTIES(APP_NAME, APP_INSTANCE) \
	for (APP_NAME ## Source *curSource in (APP_INSTANCE).sources) { \
		if ([curSource kind] != APP_NAME ## ESrcLibrary) continue; \
		\
		for (APP_NAME ## Playlist *curPlaylist in curSource.libraryPlaylists) { \
			for (APP_NAME ## FileTrack *curTrack in [curPlaylist.tracks get]) { \
				if (NSThread.currentThread.isCancelled) {end(); return;} \
				\
				NSInteger playedCount = curTrack.playedCount; \
				double duration = curTrack.finish-curTrack.start; \
				NSMutableDictionary *added = [NSMutableDictionary dictionary]; \
				added[@"track_name"]      = curTrack.name; \
				added[@"sort_track_name"] = curTrack.sortName; \
				added[@"artist"]          = curTrack.artist; \
				added[@"sort_artist"]     = curTrack.sortArtist; \
				added[@"album"]           = curTrack.album; \
				added[@"sort_album"]      = curTrack.sortAlbum; \
				added[@"composer"]        = curTrack.composer; \
				added[@"sort_composer"]   = curTrack.sortComposer; \
				added[@"track_length"]    = @(duration); \
				added[@"play_count"]      = @(playedCount); \
				added[@"total_play_time"] = @(duration*playedCount); \
				if ([curTrack playedDate] != nil) \
					added[@"last_played_date"]  = curTrack.playedDate; \
				\
				if ([added[@"sort_track_name"] isEqualToString:@""]) added[@"sort_track_name"] = added[@"track_name"]; \
				if ([added[@"sort_artist"] isEqualToString:@""])     added[@"sort_artist"]     = added[@"artist"]; \
				if ([added[@"sort_album"] isEqualToString:@""])      added[@"sort_album"]      = added[@"album"]; \
				if ([added[@"sort_composer"] isEqualToString:@""])   added[@"sort_composer"]   = added[@"composer"]; \
				if (showsZeroLength || duration > 0) [newTracksProperties addObject:added]; \
			} \
		} \
	}
	
	if      (music != nil)  {CREATE_NEW_TRACKS_PROPERTIES(Music, music);}
	else if (iTunes != nil) {CREATE_NEW_TRACKS_PROPERTIES(iTunes, iTunes);}
	
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

- (BOOL)hasAccessToMusicApp
{
	if (@available(macOS 10.14, *)) {
		NSString *bundleId = (music != nil ? MUSIC_BUNDLE_ID : ITUNES_BUNDLE_ID);
		
		const AEDesc *aeDesc = [NSAppleEventDescriptor descriptorWithBundleIdentifier:bundleId].aeDesc;
		if (aeDesc == nil) return NO;
		
		OSStatus permission = AEDeterminePermissionToAutomateTarget(aeDesc, typeAppleEvent, typeWildCard, YES);
		AEDisposeDesc((AEDesc *)aeDesc);
		
		NSLog(@"DEBUG - Got permission %d", permission);
		return permission == noErr;
	}
	
	return YES;
}
@end

#define COUNT_FORMAT_SINGULAR [[NSBundle fuseUIBundle] localizedStringForKey:@"SONGS_COUNT_SINGULAR" value:@"%lu Song" table:@"FuseUI"]
#define COUNT_FORMAT_PLURAL [[NSBundle fuseUIBundle] localizedStringForKey:@"SONGS_COUNT_PLURAL" value:@"%lu Songs" table:@"FuseUI"]

#define DELEGATE_CLASS NSClassFromString(@"MusicLibraryBrowseTableViewController")

/*
Okay children. Apparently you just stumbled across this project hoping that you could learn from it.
Well. I hope you can, lol. There's some stuff ahead that I don't actually recommend doing if it can be avoided - the reason why I did it in this instance
is basically because I don't have an iOS 8.4 device to test this on and the proper way of doing so (== how its done on iOS < 8.4) refuses to work on 8.4 (it just won't set the count string -.-).
Alrighty, fasten your seatbelts!
*/

%hook MusicTableView

- (void)layoutSubviews // basically making sure setCountString: gets called
{
	%orig;

	if ([[self delegate] isMemberOfClass:DELEGATE_CLASS])
		[self setCountString:nil];
}

/*
The reason why I didn't just pass setCountString: my desired string from within layoutSubviews or tableViewDidFinishReload: is basically because there might be some
calls to setCountString: passing nil that happen after I set my desired string. This would, in turn, eliminate the count label altogether ;_;
Unfortunately I cannot debug this since I, again, don't have an 8.4 device.
So instead I'm just doing my custom string creation inside setCountString: to make absolutely sure it gets set.
*/
- (void)setCountString:(NSString *)string
{
	if (![[self delegate] isMemberOfClass:DELEGATE_CLASS])
		return %orig;
	
	int songs = MSHookIvar<int>([self delegate], "_numberOfEntities"); // Fetching the # of songs. For various reasons, this returns #songs + 1 inside playlist song lists as entities are not necessarily cells representing songs
	// There's certainly a way better and more reliable way of fetching songs, but the FuseUI headers are the only thing I have for reference, and they are bothersome to dig through.

	NSString *countString = [NSString stringWithFormat:(songs == 1 ? COUNT_FORMAT_SINGULAR : COUNT_FORMAT_PLURAL), songs];
	%orig(countString);
}

%end

%hook MusicLibraryBrowseTableViewController

/*
Yet again making sure setCountString: gets called to set / update the count.
From what I've observed on my 8.1 device, this is actually the only method that calls the setCountString: method on MusicTableView instances, but it doesn't seem
to be too reliable on 8.4. I didn't even bother giving it an in-depth check, so I'm just leaving that tiny hook here. Can't hurt, after all.
*/
- (void)tableViewDidFinishReload:(UITableView *)tableView
{
	%orig;

	if ([tableView isKindOfClass:NSClassFromString(@"MusicTableView")])
		[tableView setCountString:nil];
}

%end
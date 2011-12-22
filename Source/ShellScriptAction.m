//
//  ShellScriptAction.m
//  ControlPlane
//
//  Created by David Symonds on 23/04/07.
//

#import "DSLogger.h"
#import "ShellScriptAction.h"


@implementation ShellScriptAction

- (id)init
{
	if (!(self = [super init]))
		return nil;

	path = [[NSString alloc] init];

	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
	if (!(self = [super initWithDictionary:dict]))
		return nil;

	path = [[dict valueForKey:@"parameter"] copy];

	return self;
}

- (void)dealloc
{
	[path release];

	[super dealloc];
}

- (NSMutableDictionary *)dictionary
{
	NSMutableDictionary *dict = [super dictionary];

	[dict setObject:[[path copy] autorelease] forKey:@"parameter"];

	return dict;
}

- (NSString *)description
{
	return [NSString stringWithFormat:NSLocalizedString(@"Running shell script '%@'.", @""), path];
}

- (BOOL)execute:(NSString **)errorString
{
    NSString *app, *fileType;
    
	if (![[NSWorkspace sharedWorkspace] getInfoForFile:path application:&app type:&fileType]) {
		*errorString = [NSString stringWithFormat:NSLocalizedString(@"Failed opening '%@'.", @""), path];
		return NO;
	}
    
	// Split on "|", add "--" to the start so that the shell won't try to parse arguments
	NSMutableArray *args = [[[path componentsSeparatedByString:@"|"] mutableCopy] autorelease];
	[args insertObject:@"--" atIndex:0];
    
    NSTask *task = nil;
    
    if ([[fileType uppercaseString] isEqualToString:@"SH"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:args];
	}
    else if ([[fileType uppercaseString] isEqualToString:@"SCPT"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/osascript" arguments:args];
	}
    else if ([[fileType uppercaseString] isEqualToString:@"PL"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/perl" arguments:args];
	}
    else if ([[fileType uppercaseString] isEqualToString:@"PY"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/python" arguments:args];
	}
    else if ([[fileType uppercaseString] isEqualToString:@"PHP"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/php" arguments:args];
	}
    else if ([[fileType uppercaseString] isEqualToString:@"EXPECT"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/expect" arguments:args];
	}
    else if ([[fileType uppercaseString] isEqualToString:@"TCL"]) {
		task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/tclsh" arguments:args];
	}
	[task waitUntilExit];
	
	if ([task terminationStatus] != 0) {
		DSLog(@"Failed to execute '%@'", path);
		*errorString = NSLocalizedString(@"Failed executing shell script!", @"");
		return NO;
	}

	return YES;
}

+ (NSString *)helpText
{
	return NSLocalizedString(@"The parameter for ShellScript actions is the full path of the "
				 "shell script, which will be executed with /bin/sh.", @"");
}

- (id)initWithFile:(NSString *)file
{
	self = [super init];
	[path release];
	path = [file copy];
	return self;
}

@end

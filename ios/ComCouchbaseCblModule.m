/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComCouchbaseCblModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLManagerProxy.h"
#import "CBLDatabaseProxy.h"
#import "CBLAttachmentProxy.h"
#import "CBLModelProxy.h"
#import "CBLDocumentProxy.h"
#import "CBLQueryProxy.h"
#import "CBLReplicationProxy.h"
#import "NSErrorProxy.h"

@implementation ComCouchbaseCblModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"7d8a0a9e-c4cb-464c-b64d-3eec5cc3922d";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.couchbase.cbl";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
    
    // TODO: Delete.
    //[CBLManager enableLogging:@"Sync"];
    //[CBLManager enableLogging:@"Query"];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma mark MANAGER:

-(CBLManagerProxy *)sharedManager
{
    return [CBLManagerProxy proxyWithDelegateBlock:^CBLManager *{
        return CBLManager.sharedInstance;
    } onNewThread:YES];
}

-(NSNumber *)isValidDatabaseName:(id)args
{
    NSString * name;
    ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
    
    return [NSNumber numberWithBool:[CBLManager isValidDatabaseName:name]];
}

-(NSString *)defaultManagerDirectory
{
    return CBLManager.defaultDirectory;
}

-(CBLManagerProxy *)createManager:(id)args
{
    return [CBLManagerProxy proxyWithDelegateBlock:^CBLManager *{
        if ([args count] == 2) {
            NSString * directory;
            ENSURE_ARG_OR_NIL_AT_INDEX(directory, args, 0, NSString);
            NSDictionary * optionsArgs;
            ENSURE_ARG_OR_NIL_AT_INDEX(optionsArgs, args, 1, NSDictionary);
            struct CBLManagerOptions options;
            options.readOnly = ((NSNumber *)optionsArgs[@"readOnly"]).boolValue;
            options.noReplicator = ((NSNumber *)optionsArgs[@"noReplicator"]).boolValue;
            
            NSError * error;
            CBLManager * manager = [[CBLManager alloc] initWithDirectory:directory options:&options error:&error];
            
            if (!manager) {
                [TitaniumUtils throwError:error withProxy:self];
            }
            
            return manager;
        } else {
            return [[CBLManager alloc] init];
        }
    } onNewThread:YES];
}

#pragma mark ATTACHMENT:

-(CBLAttachmentProxy *)createAttachment:(id)args
{
    NSString * contentType;
    ENSURE_ARG_AT_INDEX(contentType, args, 0, NSString);
    id body = args[1];
    
    if ([body isKindOfClass:NSString.class]) {
        body = [NSURL URLWithString:body];
    } else if ([body isKindOfClass:TiBlob.class]) {
        body = ((TiBlob *)body).data;
    }
    
    return [CBLAttachmentProxy proxyWithDelegate:[[CBLAttachment alloc] initWithContentType:contentType body:body]];
}


#pragma mark MODEL:

-(CBLModelProxy *)createModel:(id)args
{
    CBLModelProxy * model;
    
    if ([args count] == 0) {
        model = [CBLModelProxy proxyWithDelegate:[[CBLModel alloc] init]];
    } else if ([args count] == 1) {
        CBLDatabaseProxy * database;
        ENSURE_ARG_AT_INDEX(database, args, 0, CBLDatabaseProxy);
        
        model = [CBLModelProxy proxyWithDelegate:[[CBLModel alloc] initWithNewDocumentInDatabase:database.delegate]];
    }
    
    return model;
}

#pragma mark CONSTANTS:

-(NSString *)VERSION_STRING
{
    return CBLVersionString();
}

-(NSString *)HTTP_ERROR_DOMAIN
{
    return CBLHTTPErrorDomain;
}

MAKE_SYSTEM_PROP(REPLICATION_MODE_STOPPED, kCBLReplicationStopped)
MAKE_SYSTEM_PROP(REPLICATION_MODE_OFFLINE, kCBLReplicationOffline)
MAKE_SYSTEM_PROP(REPLICATION_MODE_IDLE, kCBLReplicationIdle)
MAKE_SYSTEM_PROP(REPLICATION_MODE_ACTIVE, kCBLReplicationActive)

MAKE_SYSTEM_PROP(QUERY_STALE_NEVER, kCBLStaleNever)
MAKE_SYSTEM_PROP(QUERY_STALE_OK, kCBLStaleOK)
MAKE_SYSTEM_PROP(QUERY_STALE_UPDATE_AFTER, kCBLStaleUpdateAfter)

@end

/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLDatabaseProxy.h"
#import "NSErrorProxy.h"
#import "CBLManagerProxy.h"
#import "CBLDocumentProxy.h"
#import "CBLQueryProxy.h"
#import "CBLViewProxy.h"
#import "CBLReplicationProxy.h"
#import "CBLModelProxy.h"
#import "CBLRevisionProxy.h"

#pragma mark CBLValidationBlockProxy

// TODO: Add to spec.
@interface CBLValidationBlockProxy : TiProxy

+(CBLValidationBlockProxy *)proxyWithDelegate:(CBLValidationBlock)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLValidationBlock delegate;

-(NSNumber *)validate:(id)args;

@end

@implementation CBLValidationBlockProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLValidationBlock)delegate
{
    if (self = [super init]) {
        _delegate = [delegate copy];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLValidationBlockProxy *)proxyWithDelegate:(CBLValidationBlock)delegate
{
    return (delegate ? [[CBLValidationBlockProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLValidationBlockProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(NSNumber *)validate:(id)args
{
    return invoke_block_on_thread(^id{
        CBLRevisionProxy * revision;
        ENSURE_ARG_OR_NIL_AT_INDEX(revision, args, 0, CBLRevisionProxy);
        CBLValidationContextProxy * validationContext;
        ENSURE_ARG_OR_NIL_AT_INDEX(validationContext, args, 1, CBLValidationContextProxy);
        
        BOOL result = _delegate(revision.delegate, validationContext.delegate);
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


#pragma mark CBLFilterBlockProxy

// TODO: Add to spec.
@interface CBLFilterBlockProxy : TiProxy

+(CBLFilterBlockProxy *)proxyWithDelegate:(CBLFilterBlock)delegate;
+(NSArray *)proxiesWithDelegates:(NSArray *)delegates;

@property (readonly) CBLFilterBlock delegate;

-(NSNumber *)filter:(id)args;

@end

@implementation CBLFilterBlockProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLFilterBlock)delegate
{
    if (self = [super init]) {
        _delegate = [delegate copy];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLFilterBlockProxy *)proxyWithDelegate:(CBLFilterBlock)delegate
{
    return (delegate ? [[CBLFilterBlockProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLFilterBlockProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(NSNumber *)filter:(id)args
{
    return invoke_block_on_thread(^id{
        CBLRevisionProxy * revision;
        ENSURE_ARG_OR_NIL_AT_INDEX(revision, args, 0, CBLRevisionProxy);
        NSDictionary * params;
        ENSURE_ARG_OR_NIL_AT_INDEX(params, args, 1, NSDictionary);
        
        BOOL result = _delegate(revision.delegate, params);
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


#pragma mark CBLDatabaseProxy

@implementation CBLDatabaseProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLDatabase *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change:) name:kCBLDatabaseChangeNotification object:_delegate];
    }
    
    return self;
}

+(CBLDatabaseProxy *)proxyWithDelegate:(CBLDatabase *)delegate
{
    return (delegate ? [[CBLDatabaseProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLDatabaseProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

#pragma mark - EVENTS:

#define kCBLDatabaseProxyChangeEvent @"change"

-(NSString *)CHANGE_EVENT
{
    return kCBLDatabaseProxyChangeEvent;
}

- (void)change:(NSNotification *)notification {
    TiThreadPerformOnMainThread(^{
        [self fireEvent:kCBLDatabaseProxyChangeEvent withObject:notification.userInfo propagate:YES];
    }, NO);
}

-(NSString *)name
{
    return invoke_block_on_thread(^id{
        return _delegate.name;
    }, _thread);
}

-(CBLManagerProxy *)manager
{
    return invoke_block_on_thread(^id{
        return [CBLManagerProxy proxyWithDelegate:_delegate.manager];
    }, _thread);
}

-(NSNumber *)documentCount
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInteger:_delegate.documentCount];
    }, _thread);
}

-(NSNumber *)lastSequenceNumber
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithLongLong:_delegate.lastSequenceNumber];
    }, _thread);
}

-(NSString *)internalUrl
{
    return invoke_block_on_thread(^id{
        return _delegate.internalURL.absoluteString;
    }, _thread);
}


#pragma mark - HOUSEKEEPING:

-(NSNumber *)compact:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        BOOL result = [_delegate compact:&error];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(NSNumber *)deleteDatabase:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        BOOL result = [_delegate deleteDatabase:&error];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}


#pragma mark - DOCUMENT ACCESS:

-(CBLDocumentProxy *)getDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * docID;
        ENSURE_ARG_OR_NIL_AT_INDEX(docID, args, 0, NSString);
        
        return [CBLDocumentProxy proxyWithDelegate:[_delegate documentWithID:docID]];
    }, _thread);
}

// NOT NEEDED: Same as -documentWithID:. Enables "[]" access in Xcode 4.4+
//- (CBLDocument*)objectForKeyedSubscript: (NSString*)key

-(CBLDocumentProxy *)createUntitledDocument:(id)args;
{
    return invoke_block_on_thread(^id{
        return [CBLDocumentProxy proxyWithDelegate:[_delegate untitledDocument]];
    }, _thread);
}

-(CBLDocumentProxy *)getCachedDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * docID;
        ENSURE_ARG_OR_NIL_AT_INDEX(docID, args, 0, NSString);
        
        return [CBLDocumentProxy proxyWithDelegate:[_delegate cachedDocumentWithID:docID]];
    }, _thread);
}

-(void)clearDocumentCache:(id)args;
{
    void_block_on_thread(^{
        [_delegate clearDocumentCache];
    }, _thread);
}


#pragma mark - LOCAL DOCUMENTS:

-(NSDictionary *)getLocalDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * localDocID;
        ENSURE_ARG_OR_NIL_AT_INDEX(localDocID, args, 0, NSString);
        
        return [_delegate getLocalDocumentWithID:localDocID];
    }, _thread);
}

-(NSNumber *)putLocalDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSDictionary * properties;
        ENSURE_ARG_OR_NIL_AT_INDEX(properties, args, 0, NSDictionary);
        NSString * localDocID;
        ENSURE_ARG_OR_NIL_AT_INDEX(localDocID, args, 1, NSString);
        
        NSError * error;
        BOOL result = [_delegate putLocalDocument:properties withID:localDocID error:&error];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(NSNumber *)deleteLocalDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * localDocID;
        ENSURE_ARG_OR_NIL_AT_INDEX(localDocID, args, 0, NSString);
        
        NSError * error;
        BOOL result = [_delegate deleteLocalDocumentWithID:localDocID error:&error];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}


#pragma mark - VIEWS AND OTHER CALLBACKS:

-(CBLQueryProxy *)queryAllDocuments
{
    return invoke_block_on_thread(^id{
        return [CBLQueryProxy proxyWithDelegate:_delegate.queryAllDocuments];
    }, _thread);
}

-(CBLQueryProxy *)slowQuery:(id)args
{
    return invoke_block_on_thread(^id{
        KrollCallback * mapCallback;
        ENSURE_ARG_AT_INDEX(mapCallback, args, 0, KrollCallback);
        
        CBLMapBlock mapBlock = (mapCallback ? [CBLViewProxy mapBlockForCallback:mapCallback inExecutionContext:self.executionContext] : nil);
        
        return [CBLQueryProxy proxyWithDelegate:[_delegate slowQueryWithMap:mapBlock]];
    }, _thread);
}

-(CBLViewProxy *)getView:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        return [CBLViewProxy proxyWithDelegate:[_delegate viewNamed:name]];
    }, _thread);
}

-(CBLViewProxy *)getExistingView:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * name;
        ENSURE_ARG_OR_NIL_AT_INDEX(name, args, 0, NSString);
        
        return [CBLViewProxy proxyWithDelegate:[_delegate existingViewNamed:name]];
    }, _thread);
}

-(void)defineValidation:(id)args
{
    void_block_on_thread(^{
        NSString * validationName;
        ENSURE_ARG_OR_NIL_AT_INDEX(validationName, args, 0, NSString);
        KrollCallback * validationCallback;
        ENSURE_ARG_AT_INDEX(validationCallback, args, 1, KrollCallback);
        
        CBLValidationBlock validationBlock = ^(CBLRevision* newRevision, id<CBLValidationContext> validationContext) {
            __block NSNumber * result;
            CBLRevisionProxy * newRevisionProxy = [CBLRevisionProxy proxyWithDelegate:newRevision];
            CBLValidationContextProxy * validationContextProxy = [CBLValidationContextProxy proxyWithDelegate:validationContext];
            
            [self.executionContext.krollContext invokeBlockOnThread:^{
                result = [validationCallback call:[NSArray arrayWithObjects:newRevisionProxy, validationContextProxy, nil] thisObject:nil];
            }];
            
            return result.boolValue;
        };
        
        [_delegate defineValidation:validationName asBlock:validationBlock];
    }, _thread);
}

-(CBLValidationBlockProxy *)validationNamed:(NSString*)validationName
{
    return invoke_block_on_thread(^id{
        return [CBLValidationBlockProxy proxyWithDelegate:[_delegate validationNamed:validationName]];
    }, _thread);
}

-(void)defineFilter:(id)args
{
    void_block_on_thread(^{
        NSString * filterName;
        ENSURE_ARG_OR_NIL_AT_INDEX(filterName, args, 0, NSString);
        KrollCallback * filterCallback;
        ENSURE_ARG_AT_INDEX(filterCallback, args, 1, KrollCallback);
        
        CBLFilterBlock filterBlock = ^(CBLRevision* revision, NSDictionary* params) {
            __block NSNumber * result;
            CBLRevisionProxy * revisionProxy = [CBLRevisionProxy proxyWithDelegate:revision];
            
            [self.executionContext.krollContext invokeBlockOnThread:^{
                result = [filterCallback call:[NSArray arrayWithObjects:revisionProxy, params, nil] thisObject:nil];
            }];
            
            return [result boolValue];
        };
        
        [_delegate defineFilter:filterName asBlock:filterBlock];
    }, _thread);
}

-(CBLFilterBlockProxy *)filterNamed:(NSString*)filterName
{
    return invoke_block_on_thread(^id{
        return [CBLFilterBlockProxy proxyWithDelegate:[_delegate filterNamed:filterName]];
    }, _thread);
}

// TODO: Needed?
//+ (void)setFilterCompiler:(id<CBLFilterCompiler>)compiler;

// TODO: Needed?
//+ (id<CBLFilterCompiler>)filterCompiler;

-(BOOL)runInTransaction:(id)args
{
    return invoke_block_on_thread(^id{
        KrollCallback * callback;
        ENSURE_ARG_AT_INDEX(callback, args, 0, KrollCallback);
        
        BOOL (^block)(void) = ^BOOL(void) {
            id result = [callback call:nil thisObject:nil];
            return [result boolValue];
        };
        
        return [NSNumber numberWithBool:[_delegate inTransaction:block]];
    }, _thread);
}

#pragma mark - REPLICATION:

-(NSArray *)allReplications;
{
    return invoke_block_on_thread(^id{
        return [CBLReplicationProxy proxiesWithDelegates:[_delegate allReplications]];
    }, _thread);
}

-(CBLReplicationProxy *)push:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * urlString;
        ENSURE_ARG_AT_INDEX(urlString, args, 0, NSString);
        NSURL * url = [NSURL URLWithString:urlString];
        
        return [CBLReplicationProxy proxyWithDelegate:[_delegate pushToURL:url]];
    }, _thread);
}

-(CBLReplicationProxy *)pull:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * urlString;
        ENSURE_ARG_AT_INDEX(urlString, args, 0, NSString);
        NSURL * url = [NSURL URLWithString:urlString];
        
        return [CBLReplicationProxy proxyWithDelegate:[_delegate pullFromURL:url]];
    }, _thread);
}

-(NSArray *)replicate:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * urlString;
        ENSURE_ARG_AT_INDEX(urlString, args, 0, NSString);
        NSURL * otherDbURL = [NSURL URLWithString:urlString];
        NSNumber * exclusively;
        ENSURE_ARG_AT_INDEX(exclusively, args, 1, NSNumber);
        
        return [CBLReplicationProxy proxiesWithDelegates:[_delegate replicateWithURL:otherDbURL exclusively:exclusively.boolValue]];
    }, _thread);
}

// NOTE: Create method for Replication ctor.
-(CBLReplicationProxy *)createPullReplication:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * source;
        ENSURE_ARG_OR_NIL_AT_INDEX(source, args, 0, NSString);
        
        return [CBLReplicationProxy proxyWithDelegate:[[CBLReplication alloc] initPullFromSourceURL:[NSURL URLWithString:source] toDatabase:self.delegate]];
    }, _thread);
}

// NOTE: Create method for Replication ctor.
-(CBLReplicationProxy *)createPushReplication:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * target;
        ENSURE_ARG_OR_NIL_AT_INDEX(target, args, 0, NSString);
        
        return [CBLReplicationProxy proxyWithDelegate:[[CBLReplication alloc] initPushFromDatabase:self.delegate toTargetURL:[NSURL URLWithString:target]]];
    }, _thread);
}


#pragma mark - MODEL:

-(NSArray *)unsavedModels
{
    return invoke_block_on_thread(^id{
        return [CBLModelProxy proxiesWithDelegates:_delegate.unsavedModels];
    }, _thread);
}

-(NSNumber *)saveAllModels:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        BOOL result = [_delegate saveAllModels:&error];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(NSNumber *)autosaveAllModels:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        BOOL result = [_delegate autosaveAllModels:&error];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return [NSNumber numberWithBool:result];
    }, _thread);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCBLDatabaseChangeNotification object:_delegate];
    
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end


// NOTE: Exposed as abstracted CHANGE_EVENT.
//extern NSString* const kCBLDatabaseChangeNotification;


// TODO: Add to spec.
@implementation CBLValidationContextProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(id<CBLValidationContext>)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
    }
    
    return self;
}

+(CBLValidationContextProxy *)proxyWithDelegate:(id<CBLValidationContext>)delegate
{
    return (delegate ? [[CBLValidationContextProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLValidationContextProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

-(CBLRevisionProxy *)currentRevision
{
    return invoke_block_on_thread(^id{
        return [CBLRevisionProxy proxyWithDelegate:_delegate.currentRevision];
    }, _thread);
}

-(int)errorType
{
    return invoke_block_on_thread(^id{
        return _delegate.errorType;
    }, _thread);
}

-(void)setErrorMessage:(id)args
{
    void_block_on_thread(^{
        NSString * errorMessage;
        ENSURE_ARG_OR_NIL_AT_INDEX(errorMessage, args, 0, NSString);
        
        _delegate.errorMessage = errorMessage;
    }, _thread);
}

-(NSString *)errorMessage
{
    return invoke_block_on_thread(^id{
        return _delegate.errorMessage;
    }, _thread);
}

#pragma mark - CONVENIENCE METHODS:

-(NSArray *)changedKeys
{
    return invoke_block_on_thread(^id{
        return _delegate.changedKeys;
    }, _thread);
}

-(NSNumber *)allowChangesOnlyTo:(id)args
{
    return invoke_block_on_thread(^id{
        NSArray * allowedKeys;
        ENSURE_ARG_OR_NIL_AT_INDEX(allowedKeys, args, 0, NSArray);
        
        return [NSNumber numberWithBool:[_delegate allowChangesOnlyTo:allowedKeys]];
    }, _thread);
}

-(NSNumber *)disallowChangesTo:(id)args
{
    return invoke_block_on_thread(^id{
        NSArray * disallowedKeys;
        ENSURE_ARG_OR_NIL_AT_INDEX(disallowedKeys, args, 0, NSArray);
        
        return [NSNumber numberWithBool:[_delegate disallowChangesTo:disallowedKeys]];
    }, _thread);
}

-(NSNumber *)enumerateChanges:(id)args
{
    KrollCallback * callback;
    ENSURE_ARG_OR_NIL_AT_INDEX(callback, args, 0, KrollCallback);
    
    BOOL (^block)(NSString* key, id oldValue, id newValue) = ^BOOL(NSString * key, id oldValue, id newValue) {
        NSNumber * result = [callback call:[NSArray arrayWithObjects:key, oldValue, newValue, nil] thisObject:nil];
        
        return result.boolValue;
    };
    
    return [_delegate enumerateChanges:block];
}

@end

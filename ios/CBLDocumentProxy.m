/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLDocumentProxy.h"
#import "CBLDatabaseProxy.h"
#import "CBLRevisionProxy.h"
#import "CBLModelProxy.h"

@implementation CBLDocumentProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLDocument *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change:) name:kCBLDocumentChangeNotification object:_delegate];
    }
    
    return self;
}

+(CBLDocumentProxy *)proxyWithDelegate:(CBLDocument *)delegate
{
    return (delegate ? [[CBLDocumentProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLDocumentProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

#pragma mark - EVENTS:

#define kCBLDocumentProxyChangeEvent @"change"

-(NSString *)CHANGE_EVENT
{
    return kCBLDocumentProxyChangeEvent;
}

- (void)change:(NSNotification *)notification {
    TiThreadPerformOnMainThread(^{
        [self fireEvent:kCBLDocumentProxyChangeEvent withObject:nil propagate:YES];
    }, NO);
}

-(CBLDatabaseProxy *)database
{
    return invoke_block_on_thread(^id{
        return [CBLDatabaseProxy proxyWithDelegate:_delegate.database];
    }, _thread);
}

-(NSString *)documentId
{
    return invoke_block_on_thread(^id{
        return _delegate.documentID;
    }, _thread);
}

-(NSString *)abbreviatedId
{
    return invoke_block_on_thread(^id{
        return _delegate.abbreviatedID;
    }, _thread);
}

-(NSNumber *)isDeleted
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:_delegate.isDeleted];
    }, _thread);
}

-(NSNumber *)deleteDocument:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [NSNumber numberWithBool:[_delegate deleteDocument:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(NSNumber *)purge:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [NSNumber numberWithBool:[_delegate purgeDocument:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}


#pragma mark REVISIONS:

-(NSString *)currentRevisionId
{
    return invoke_block_on_thread(^id{
        return _delegate.currentRevisionID;
    }, _thread);
}

-(CBLRevisionProxy *)currentRevision
{
    return invoke_block_on_thread(^id{
        return [CBLRevisionProxy proxyWithDelegate:_delegate.currentRevision];
    }, _thread);
}

-(CBLRevisionProxy *)getRevision:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * revisionID;
        ENSURE_ARG_OR_NIL_AT_INDEX(revisionID, args, 0, NSString);
        
        return [CBLRevisionProxy proxyWithDelegate:[_delegate revisionWithID:revisionID]];
    }, _thread);
}

-(NSArray *)getRevisionHistory:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [CBLRevisionProxy proxiesWithDelegates:[_delegate getRevisionHistory:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(NSArray *)getConflictingRevisions:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [CBLRevisionProxy proxiesWithDelegates:[_delegate getConflictingRevisions:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(NSArray *)getLeafRevisions:(id)args
{
    return invoke_block_on_thread(^id{
        NSError * error;
        id result = [CBLRevisionProxy proxiesWithDelegates:[_delegate getLeafRevisions:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(CBLNewRevisionProxy *)createNewRevision:(id)args
{
    return invoke_block_on_thread(^id{
        return [CBLNewRevisionProxy proxyWithDelegate:_delegate.newRevision];
    }, _thread);
}


#pragma mark PROPERTIES:

-(NSDictionary *)properties
{
    return invoke_block_on_thread(^id{
        return _delegate.properties;
    }, _thread);
}

-(NSDictionary *)userProperties
{
    return invoke_block_on_thread(^id{
        return _delegate.userProperties;
    }, _thread);
}

-(id)getProperty:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * key;
        ENSURE_ARG_OR_NIL_AT_INDEX(key, args, 0, NSString);
        
        return [_delegate propertyForKey:key];
    }, _thread);
}

// Same as -propertyForKey:. Enables "[]" access in Xcode 4.4+
// - (id)objectForKeyedSubscript:(NSString*)key;

-(CBLRevisionProxy *)putProperties:(id)args
{
    return invoke_block_on_thread(^id{
        NSDictionary * properties;
        ENSURE_ARG_OR_NIL_AT_INDEX(properties, args, 0, NSDictionary);
        
        NSError * error;
        id result = [CBLRevisionProxy proxyWithDelegate:[_delegate putProperties:properties error:&error]];
        
        if (!result) {
            [TitaniumUtils throwError:error withProxy:self];
        }
        
        return result;
    }, _thread);
}

-(CBLRevisionProxy *)update:(id)args
{
    KrollCallback * callback;
    ENSURE_ARG_AT_INDEX(callback, args, 0, KrollCallback);
    
    BOOL (^block)(CBLNewRevision *) = ^BOOL(CBLNewRevision * newRevision) {
        CBLNewRevisionProxy * newRevisionProxy = [CBLNewRevisionProxy proxyWithDelegate:newRevision onThread:_thread];
        NSNumber * result = [callback call:[NSArray arrayWithObject:newRevisionProxy] thisObject:nil];
        
        return result.boolValue;
    };
    
    NSError * error;
    id result = [NSNumber numberWithBool:[_delegate update:block error:&error]];
    
    if (!result) {
        [TitaniumUtils throwError:error withProxy:self];
    }
    
    return result;
}


#pragma mark MODEL:

-(CBLModelProxy *)modelObject
{
    return invoke_block_on_thread(^id{
        return [CBLModelProxy proxyWithDelegate:_delegate.modelObject];
    }, _thread);
}

-(void)setModelObject:(id)args
{
    void_block_on_thread(^{
        CBLModelProxy * modelObject;
        ENSURE_ARG_OR_NIL_AT_INDEX(modelObject, args, 0, CBLModelProxy);
        
        [_delegate setModelObject:modelObject];
    }, _thread);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCBLDocumentChangeNotification object:_delegate];
    
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end

// TODO: Needed?
//@protocol CBLDocumentModel <NSObject>
//- (void) tdDocumentChanged: (CBLDocument*)doc;
//@end

// NOTE: Defined in Module
//extern NSString* const kCBLDocumentChangeNotification;

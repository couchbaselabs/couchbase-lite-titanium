/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ThreadUtils.h"
#import "TitaniumUtils.h"
#import "CBLReplicationProxy.h"
#import "CBLDatabaseProxy.h"
#import "NSURLCredentialProxy.h"
#import "NSErrorProxy.h"

@implementation CBLReplicationProxy
{
    NSThread * _thread;
}

-(id)initWithDelegate:(CBLReplication *)delegate
{
    if (self = [super init]) {
        _delegate = [delegate retain];
        _thread = [[NSThread currentThread] retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(change:) name:kCBLReplicationChangeNotification object:_delegate];
    }
    
    return self;
}

+(CBLReplicationProxy *)proxyWithDelegate:(CBLReplication *)delegate
{
    return (delegate ? [[CBLReplicationProxy alloc] initWithDelegate:delegate] : nil);
}

+(NSArray *)proxiesWithDelegates:(NSArray *)delegates
{
    NSMutableArray * proxies = [[NSMutableArray alloc] initWithCapacity:delegates.count];
    
    for (id delegate in delegates) {
        [proxies addObject:[CBLReplicationProxy proxyWithDelegate:delegate]];
    }
    
    return proxies;
}

#pragma mark - EVENTS:

#define kCBLReplicationProxyChangeEvent @"change"

-(NSString *)CHANGE_EVENT
{
    return kCBLReplicationProxyChangeEvent;
}

- (void)change:(NSNotification *)notification {
    TiThreadPerformOnMainThread(^{
        [self fireEvent:kCBLReplicationProxyChangeEvent withObject:nil propagate:YES];
    }, NO);
}

//- (instancetype) initPullFromSourceURL: (NSURL*)source toDatabase: (CBLDatabase*)database;

//- (instancetype) initPushFromDatabase: (CBLDatabase*)database toTargetURL: (NSURL*)target;

-(CBLDatabaseProxy *)localDatabase
{
    return invoke_block_on_thread(^id{
        return [CBLDatabaseProxy proxyWithDelegate:_delegate.localDatabase];
    }, _thread);
}

-(NSString *)remoteUrl
{
    return invoke_block_on_thread(^id{
        return _delegate.remoteURL.absoluteString;
    }, _thread);
}

-(NSNumber *)isPull
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:(_delegate.pull == true)];
    }, _thread);
}


#pragma mark - OPTIONS:

-(NSNumber *)isPersistent
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:(_delegate.persistent == true)];
    }, _thread);
}

-(void)setIsPersistent:(NSNumber *)persistent
{
    void_block_on_thread(^{
        _delegate.persistent = persistent.boolValue;
    }, _thread);
}

-(NSNumber *)isCreateTarget
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:(_delegate.create_target == true)];
    }, _thread);
}

-(void)setIsCreateTarget:(NSNumber *)createTarget
{
    void_block_on_thread(^{
        _delegate.create_target = createTarget.boolValue;
    }, _thread);
}

-(NSNumber *)isContinuous
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:(_delegate.continuous == true)];
    }, _thread);
}

-(void)setIsContinuous:(NSNumber *)continuous
{
    void_block_on_thread(^{
        _delegate.continuous = continuous.boolValue;
    }, _thread);
}

-(NSString *)filter
{
    return invoke_block_on_thread(^id{
        return _delegate.filter;
    }, _thread);
}

-(void)setFilter:(NSString *)filter
{
    void_block_on_thread(^{
        _delegate.filter = filter;
    }, _thread);
}

-(NSDictionary *)queryParams
{
    return invoke_block_on_thread(^id{
        return _delegate.query_params;
    }, _thread);
}

-(void)setQueryParams:(NSDictionary *)queryParams
{
    void_block_on_thread(^{
        _delegate.query_params = queryParams;
    }, _thread);
}

-(NSArray *)docIds
{
    return invoke_block_on_thread(^id{
        return _delegate.doc_ids;
    }, _thread);
}

-(void)setDocIds:(NSArray *)docIds
{
    void_block_on_thread(^{
        _delegate.doc_ids = docIds;
    }, _thread);
}

-(NSDictionary *)headers
{
    return invoke_block_on_thread(^id{
        return _delegate.headers;
    }, _thread);
}

-(void)setHeaders:(NSDictionary *)headers
{
    void_block_on_thread(^{
        _delegate.headers = headers;
    }, _thread);
}


#pragma mark - AUTHENTICATION:

-(NSURLCredentialProxy *)credential
{
    return invoke_block_on_thread(^id{
        return [NSURLCredentialProxy proxyWithDelegate:_delegate.credential];
    }, _thread);
}

-(void)setCredential:(NSURLCredentialProxy *)credential
{
    void_block_on_thread(^{
        _delegate.credential = credential.delegate;
    }, _thread);
}

-(NSDictionary *)oAuth
{
    return invoke_block_on_thread(^id{
        return _delegate.OAuth;
    }, _thread);
}

-(void)setOAuth:(NSDictionary *)oAuth
{
    void_block_on_thread(^{
        _delegate.OAuth = oAuth;
    }, _thread);
}

-(NSString *)facebookEmailAddress
{
    return invoke_block_on_thread(^id{
        return _delegate.facebookEmailAddress;
    }, _thread);
}

-(void)setFacebookEmailAddress:(NSString *)facebookEmailAddress
{
    void_block_on_thread(^{
        _delegate.facebookEmailAddress = facebookEmailAddress;
    }, _thread);
}

-(NSNumber *)registerFacebookTokenForEmailAddress:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * token;
        ENSURE_ARG_OR_NIL_AT_INDEX(token, args, 0, NSString);
        NSString * email;
        ENSURE_ARG_OR_NIL_AT_INDEX(email, args, 1, NSString);
        
        return [NSNumber numberWithBool:([_delegate registerFacebookToken:token forEmailAddress:email] == true)];
    }, _thread);
}

-(NSString *)personaOrigin
{
    return invoke_block_on_thread(^id{
        return _delegate.personaOrigin.absoluteString;
    }, _thread);
}

-(NSString *)personaEmailAddress
{
    return invoke_block_on_thread(^id{
        return _delegate.personaEmailAddress;
    }, _thread);
}

-(void)setPersonaEmailAddress:(NSString *)personaEmailAddress
{
    void_block_on_thread(^{
        _delegate.personaEmailAddress = personaEmailAddress;
    }, _thread);
}

-(NSNumber *)registerPersonaAssertion:(id)args
{
    return invoke_block_on_thread(^id{
        NSString * assertion;
        ENSURE_ARG_OR_NIL_AT_INDEX(assertion, args, 0, NSString);
        
        return [NSNumber numberWithBool:([_delegate registerPersonaAssertion:assertion] == true)];
    }, _thread);
}

//+(void)setAnchorCerts:(id)args
-(void)setAnchorCerts:(id)args
{
    void_block_on_thread(^{
        NSArray * certs;
        ENSURE_ARG_OR_NIL_AT_INDEX(certs, args, 0, NSArray);
        NSNumber * onlyThese;
        ENSURE_ARG_OR_NIL_AT_INDEX(onlyThese, args, 1, NSNumber);
        
        [CBLReplication setAnchorCerts:certs onlyThese:onlyThese];
    }, _thread);
}


#pragma mark - STATUS:

-(void)start:(id)args
{
    void_block_on_thread(^{
        [_delegate start];
    }, _thread);
}

-(void)stop:(id)args
{
    void_block_on_thread(^{
        [_delegate stop];
    }, _thread);
}

-(void)restart:(id)args
{
    void_block_on_thread(^{
        [_delegate restart];
    }, _thread);
}

-(NSNumber *)mode
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithInt:_delegate.mode];
    }, _thread);
}

-(NSNumber *)isRunning
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithBool:(_delegate.running == true)];
    }, _thread);
}

-(NSErrorProxy *)error
{
    return invoke_block_on_thread(^id{
        return [NSErrorProxy proxyWithDelegate:_delegate.error];
    }, _thread);
}

-(NSNumber *)completed
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInt:_delegate.completed];
    }, _thread);
}

-(NSNumber *)total
{
    return invoke_block_on_thread(^id{
        return [NSNumber numberWithUnsignedInt:_delegate.total];
    }, _thread);
}


// NOTE: Defined in Module
//extern NSString* const kCBLReplicationChangeNotification;

-(void)dealloc
{
    [_delegate release];
    [_thread release];
    
    [super dealloc];
}

@end

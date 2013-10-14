//
//  ThreadUtils.m
//  CouchbaseLiteTitanium
//
//  Created by Wayne Carter on 10/1/13.
//
//

#import "ThreadUtils.h"

// Invoke args.
@interface ThreadUtilsInvokeArgs : NSObject

@property (readwrite) InvokeBlock invoke;
@property (readwrite,retain) id result;

@end
@implementation ThreadUtilsInvokeArgs

-(void)dealloc
{
    [_result release];
    
    [super dealloc];
}

@end

id invoke_block_on_thread(InvokeBlock block, NSThread * thread)
{
    if ([NSThread currentThread] != thread) {
        ThreadUtilsInvokeArgs * args = [[ThreadUtilsInvokeArgs alloc] init];
        args.invoke = block;
        [ThreadUtils.class performSelector:@selector(invokeBlock:) onThread:thread withObject:args waitUntilDone:YES];
        
        return [args.result autorelease];
    } else {
        return block();
    }
}

void void_block_on_thread(VoidBlock block, NSThread * thread)
{
    if ([NSThread currentThread] != thread) {
        [ThreadUtils.class performSelector:@selector(voidBlock:) onThread:thread withObject:block waitUntilDone:YES];
    } else {
        block();
    }
}

@implementation ThreadUtils

+(void)invokeBlock:(ThreadUtilsInvokeArgs *)args
{
    args.result = args.invoke();
}

+(void)voidBlock:(VoidBlock)block
{
    block();
}

@end

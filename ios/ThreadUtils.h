//
//  ThreadUtils.h
//  CouchbaseLiteTitanium
//
//  Created by Wayne Carter on 10/1/13.
//
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

typedef id (^InvokeBlock) (void);
typedef void (^VoidBlock) (void);

id invoke_block_on_thread(InvokeBlock block, NSThread * thread);
void void_block_on_thread(VoidBlock block, NSThread * thread);

@interface ThreadUtils : NSObject

@end

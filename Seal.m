//
//  Seal.m
//  PeevedPenguins
//
//  Created by Amy Tang on 10/14/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "Seal.h"

@interface Seal (PrivateMethods)
// declare private methods here
@end

@implementation Seal : CCSprite
@synthesize health;

-(id) init
{
	self = [super init];
	if (self)
	{
		// add init code here (note: self.parent is still nil here!)
		
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(id) initWithSealImage
{
    // This calls CCSprite's init. Basically this init method does everything CCSprite's init method does and then more
    if ((self = [super initWithFile:@"seal.png"]))
    {
        health = 2;
        //properties work internally just like normal instance variables
    }
    return self;
}

-(void) onEnter
{
	[super onEnter];

	// add init code here where you need to use the self.parent reference
	// generally recommended to run node initialization here
}

-(void) cleanup
{
	[super cleanup];

	// any cleanup code goes here
	
	// specifically release/nil any references that could cause retain cycles
	// since dealloc might not be called if this class retains another node that is
   // either a sibling or in a different branch of the node hierarchy
}

-(void) dealloc
{
	// uncomment if you're not using ARC (ahem, make that: *still* not using ARC ...)
	//[super dealloc];
	
	// if you suspect a memory leak, put a breakpoint here to see if the node gets deallocated
	NSLog(@"dealloc: %@", self);
}

// scheduled update method
-(void) update:(ccTime)delta
{
}

@end

//
//  StartMenuLayer.m
//  PeevedPenguins
//
//  Created by Amy Tang on 10/12/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "StartMenuLayer.h"
#import "GameLayer.h"

@interface StartMenuLayer (PrivateMethods)
// declare private methods here
@end

@implementation StartMenuLayer 

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	StartMenuLayer *layer = [StartMenuLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init
{
	self = [super init];
	if (self)
	{
        
        CCMenuItemImage *menuBackground = [CCMenuItemImage itemWithNormalImage:@"menu-background-hd.png" selectedImage:@"menu-background-hd.png" target:self selector:nil];
        
        CCMenuItemImage *menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"button-hd.png" selectedImage:@"button-hd.png" target:self selector:@selector(playGame:)];
        
        
        // Create a menu and add your menu items to it
        CCMenu * myMenu = [CCMenu menuWithItems:menuBackground, menuPlayButton, nil];
        
        // Arrange the menu items vertically
        //[myMenu alignItemsVertically];
        
        // add the menu to your scene
        [self addChild:myMenu];
        
		
        // uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(void) playGame:(CCMenuItem *)sender
{
        [[CCDirector sharedDirector] replaceScene: (CCScene*)[[GameLayer alloc] init]];
    NSLog(@"Play the game");
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
//
//  GameOverLayer.m
//  PeevedPenguins
//
//  Created by Amy Tang on 10/13/13.
//  Copyright 2013 UC Berkeley. All rights reserved.
//

#import "GameOverLayer.h"

#import "StartMenuLayer.h"

@interface GameOverLayer (PrivateMethods)
// declare private methods here
@end

@implementation GameOverLayer

+(id) scene{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	GameOverLayer *layer = [GameOverLayer node];
    
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
        
        CCMenuItemImage *menuPlayButton = [CCMenuItemImage itemWithNormalImage:@"button-hd.png" selectedImage:@"button-hd.png" target:self selector:@selector(showStartScreen:)];
        
        
        // Create a menu and add your menu items to it
        CCMenu * myMenu = [CCMenu menuWithItems:menuBackground, menuPlayButton, nil];
        
        // Arrange the menu items vertically
        [myMenu alignItemsVertically];
        
        // add the menu to your scene
        [self addChild:myMenu];
		// uncomment if you want the update method to be executed every frame
		//[self scheduleUpdate];
	}
	return self;
}

-(void) showStartScreen:(CCMenuItem *)sender{
        NSLog(@"Show start screen");
    
    [[CCDirector sharedDirector] replaceScene: (CCScene*)[[StartMenuLayer alloc] init]];
    
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

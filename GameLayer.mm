/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "GameLayer.h"

#import "SimpleAudioEngine.h"
#import "Seal.h"

const float PTM_RATIO = 32.0f;
#define FLOOR_HEIGHT    50.0f

CCSprite *projectile;
CCSprite *block;
CGRect firstrect;
CGRect secondrect;
NSMutableArray *blocks = [[NSMutableArray alloc] init];



@interface GameLayer (PrivateMethods)
-(void) enableBox2dDebugDrawing;
-(void) addSomeJoinedBodies:(CGPoint)pos;
-(void) addNewSpriteAt:(CGPoint)p;
-(b2Vec2) toMeters:(CGPoint)point;
-(CGPoint) toPixels:(b2Vec2)vec;
@end

@implementation GameLayer


-(id) init:(int)levelNum
{
	if ((self = [super init]))
	{
        
		CCLOG(@"%@ init", NSStringFromClass([self class]));
        
        bullets = [[NSMutableArray alloc] init];
        
        // Construct a world object, which will hold and simulate the rigid bodies.
		b2Vec2 gravity = b2Vec2(0.0f, -10.0f);
		world = new b2World(gravity);
		world->SetAllowSleeping(YES);
		//world->SetContinuousPhysics(YES);
        
        //create an object that will check for collisions
		contactListener = new ContactListener();
		world->SetContactListener(contactListener);
        
		glClearColor(0.1f, 0.0f, 0.2f, 1.0f);
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;

        
        b2Vec2 lowerLeftCorner =b2Vec2(0,0);
		b2Vec2 lowerRightCorner = b2Vec2(screenSize.width/PTM_RATIO,0);
		b2Vec2 upperLeftCorner = b2Vec2(0,screenSize.height/PTM_RATIO);
		b2Vec2 upperRightCorner = b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO);
		
		// Define the static container body, which will provide the collisions at screen borders.
		b2BodyDef screenBorderDef;
		screenBorderDef.position.Set(0, 0);
        screenBorderBody = world->CreateBody(&screenBorderDef);
		b2EdgeShape screenBorderShape;
        
        screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        screenBorderShape.Set(lowerRightCorner, upperRightCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        screenBorderShape.Set(upperRightCorner, upperLeftCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
        screenBorderBody->CreateFixture(&screenBorderShape, 0);
        
        //Load the plist which tells Kobold2D how to properly parse your spritesheet. If on a retina device Kobold2D will automatically use bearframes-hd.plist
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile: @"bearframes.plist"];
        
        //Load in the spritesheet, if retina Kobold2D will automatically use bearframes-hd.png
        
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"bearframes.png"];
        
        [self addChild:spriteSheet];
        
        //Define the frames based on the plist - note that for this to work, the original files must be in the format bear1, bear2, bear3 etc...
        
        //When it comes time to get art for your own original game, makegameswith.us will give you spritesheets that follow this convention, <spritename>1 <spritename>2 <spritename>3 etc...
        
        tauntingFrames = [NSMutableArray array];
        
        for(int i = 1; i <= 7; ++i)
        {
            [tauntingFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName: [NSString stringWithFormat:@"bear%d.png", i]]];
        }
        
        
        //Add all the sprites to the game, including blocks and the catapult. It's tedious...
        //See the storing game data tutorial to learn how to abstract all of this out to a plist file
        
        
        CCSprite *sprite = [CCSprite spriteWithFile:@"background.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:-1];
        
        sprite = [CCSprite spriteWithFile:@"catapult.png"];
        sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointMake(135.0f, FLOOR_HEIGHT);
        [self addChild:sprite z:0];
        
 
        
        /*
        sprite = [CCSprite spriteWithFile:@"bear.png"];
        sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointMake(50.0f, FLOOR_HEIGHT);
        [self addChild:sprite z:0];
         */
        
        //Initialize the bear with the first frame you loaded from your spritesheet, bear1
        
        sprite = [CCSprite spriteWithSpriteFrameName:@"bear1.png"];
        
        sprite.anchorPoint = CGPointZero;
        sprite.position = CGPointMake(50.0f, FLOOR_HEIGHT);
        
        //Create an animation from the set of frames you created earlier
        
        CCAnimation *taunting = [CCAnimation animationWithFrames: tauntingFrames delay:0.5f];
        
        //Create an action with the animation that can then be assigned to a sprite
        
        taunt = [CCRepeatForever actionWithAction: [CCAnimate actionWithAnimation:taunting restoreOriginalFrame:NO]];
        
        //tell the bear to run the taunting action
        [sprite runAction:taunt];
        
        [self addChild:sprite z:0];
        
            
        sprite = [CCSprite spriteWithFile:@"ground.png"];
        sprite.anchorPoint = CGPointZero;
        [self addChild:sprite z:10];
        
        NSLog(@"Murur!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! %d", levelNum);
        NSString *path;
        if (levelNum == 1) {
         path = [[NSBundle mainBundle] pathForResource:@"level1" ofType:@"plist"];
        } else if (levelNum == 2) {
            path = [[NSBundle mainBundle] pathForResource:@"level2" ofType:@"plist"];
        }
        path = [[NSBundle mainBundle] pathForResource:@"level1" ofType:@"plist"];

            NSLog(@"path is %@",path);    
        
  
        NSDictionary *level = [NSDictionary dictionaryWithContentsOfFile:path];

        if (level == nil){
            NSLog(@"level is nil");
        }
        
        NSArray *levelblocks = [level objectForKey:@"Blocks"];
        NSLog(@"Is null? %@", [levelblocks componentsJoinedByString: @"|"]);
        for (NSDictionary* block in levelblocks) {
            NSString* imgname =[(NSString*)[block objectForKey:@"spriteName"] stringByAppendingString: @".png"];
             sprite = [CCSprite spriteWithFile:imgname];
            float x = [[block objectForKey:@"x"] floatValue];
            float y = [[block objectForKey:@"y"] floatValue];
            sprite.position = CGPointMake(y, FLOOR_HEIGHT + x);
            [blocks addObject:sprite];
            [self addChild:sprite z:7];
            NSLog(@"BUILT A BLOCK %@",imgname);
            
        }
        
                NSLog(@"blocks content %@", [blocks componentsJoinedByString: @"|"]);
        /*
        sprite = [CCSprite spriteWithFile:@"tallblock.png"];
        sprite.position = CGPointMake(675.0f, FLOOR_HEIGHT + 28.0f);
        [blocks addObject:sprite];
        [self addChild:sprite z:7];

        sprite = [CCSprite spriteWithFile:@"longblock.png"];
        sprite.position = CGPointMake(707.0f, FLOOR_HEIGHT + 56.0f);
        [blocks addObject:sprite];
        [self addChild:sprite z:7];
        sprite = [CCSprite spriteWithFile:@"tallblock.png"];
        sprite.position = CGPointMake(741.0f, FLOOR_HEIGHT + 28.0f);
        [blocks addObject:sprite];
        [self addChild:sprite z:7];
        
        */
        
        Seal *seal = [[Seal alloc] initWithSealImage];
        seal.position = CGPointMake(680.0f, FLOOR_HEIGHT + 72.0f);
        [blocks addObject:seal];
        [self addChild:seal z:7];
        
        
        /*
        sprite = [CCSprite spriteWithFile:@"tallblock.png"];
        sprite.position = CGPointMake(854.0f, FLOOR_HEIGHT + 28.0f);
        [blocks addObject:sprite];
        [self addChild:sprite z:7];
        sprite = [CCSprite spriteWithFile:@"tallblock.png"];
        sprite.position = CGPointMake(854.0f, FLOOR_HEIGHT + 28.0f + 46.0f);
        [blocks addObject:sprite];
        [self addChild:sprite z:7];
        sprite = [CCSprite spriteWithFile:@"tallblock.png"];
        sprite.position = CGPointMake(854.0f, FLOOR_HEIGHT + 26.0f + 46.0f + 46.0f);
        [blocks addObject:sprite];
        [self addChild:sprite z:7];
        */
		
        
        CCSprite *arm = [CCSprite spriteWithFile:@"catapultarm.png"];
        arm.position = CGPointMake(230.0f, FLOOR_HEIGHT+130.0f);
        [self addChild:arm z:-1];
		
        //schedules a call to the update method every frame
		[self scheduleUpdate];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explo2.wav"];
	}
    
	return self;
}

//Create the bullets, add them to the list of bullets so they can be referred to later
- (void)createBullets
{
    CCSprite *bullet = [CCSprite spriteWithFile:@"flyingpenguin.png"];
    bullet.position = CGPointMake(250.0f, FLOOR_HEIGHT+190.0f);
    [self addChild:bullet z:9];
    [bullets addObject:bullet];
}

//Check through all the bullets and blocks and see if they intersect
-(void) detectCollisions
{
    for(int i = 0; i < [bullets count]; i++)
    {
        for(int j = 0; j < [blocks count]; j++)
        {
            if([bullets count]>0)
            {
                NSInteger first = i;
                NSInteger second = j;
                block = [blocks objectAtIndex:second];
                projectile = [bullets objectAtIndex:first];
                
                firstrect = [projectile textureRect];
                secondrect = [block textureRect];
                //check if their x coordinates match
                if(projectile.position.x == block.position.x)
                {
                    //check if their y coordinates are within the height of the block
                    if(projectile.position.y < (block.position.y + 23.0f) && projectile.position.y > block.position.y - 23.0f)
                    {
                        if([block isKindOfClass:[Seal class]]) {
                            
                            //the program doesn't know that the block is actually a Seal object; we must cast it to a seal
                            if (((Seal*)block).health==1)
                            {
                                [self removeChild:block cleanup:YES];
                                [self removeChild:projectile cleanup:YES];
                                [blocks removeObjectAtIndex:second];
                                [bullets removeObjectAtIndex:first];
                            }
                            else
                            {
                                ((Seal*)block).health--;
                                [self removeChild:projectile cleanup:YES];
                                [bullets removeObjectAtIndex:first];
                            }
                        } else {
                            [self removeChild:block cleanup:YES];
                            [self removeChild:projectile cleanup:YES];
                            [blocks removeObjectAtIndex:second];
                            [bullets removeObjectAtIndex:first];
                            
                        }
                        [[SimpleAudioEngine sharedEngine] playEffect:@"explo2.wav"];
                    }
                }
            }
            
        }
        
    }
}



-(void) dealloc
{
	delete world;
    
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}



-(void) update:(ccTime)delta
{
    //Check for inputs and create a bullet if there is a tap
    KKInput* input = [KKInput sharedInput];
    if(input.anyTouchEndedThisFrame)
    {
        [self createBullets];
    }
    //Move the projectiles to the right and down
    for(int i = 0; i < [bullets count]; i++)
    {
        NSInteger j = i;
        projectile = [bullets objectAtIndex:j];
        projectile.position = ccp(projectile.position.x + 1.0f,projectile.position.y - 0.25f);
    }
    //Move the screen if the bullets move too far right
    if([bullets count] > 0)
    {
        projectile = [bullets objectAtIndex:0];
        if(projectile.position.x > 320 && self.position.x > -480)
        {
            self.position = ccp(self.position.x - 1, self.position.y);
        }
    }
    //If there are bullets and blocks in existence, check if they are colliding
    if([bullets count] > 0 && [blocks count] > 0)
    {
        [self detectCollisions];
    }
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}


@end

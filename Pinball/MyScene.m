//
//  MyScene.m
//  Pinball
//
//  Created by Josef Hilbert on 18.01.14.
//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import "MyScene.h"
#import <QuartzCore/QuartzCore.h>
#import "YMCPhysicsDebugger.h"

@import AVFoundation;


static NSString* ballCategoryName = @"ball";
static NSString* paddleLeftCategoryName = @"paddleLeft";
static NSString* paddleRightCategoryName = @"paddleRight";
static NSString* blockCategoryName = @"block";
static NSString* blockNodeCategoryName = @"blockNode";
static NSString* starterCategoryName = @"starter";
static NSString* edgeCategoryName = @"edge";
static NSString* bumperCategoryName = @"bumper";
static NSString* bumperSideCategoryName = @"bumperSide";
static NSString* catcherCategoryName = @"catcher";

static const uint32_t ballCategory  = 0x1 << 0;         // 00000000000000000000000000000001
static const uint32_t bottomCategory = 0x1 << 1;        // 00000000000000000000000000000010
static const uint32_t blockCategory = 0x1 << 2;         // 00000000000000000000000000000100
static const uint32_t paddleLeftCategory = 0x1 << 3;    // 00000000000000000000000000001000
static const uint32_t paddleRightCategory = 0x1 << 4;   // 00000000000000000000000000010000
static const uint32_t starterCategory = 0x1 << 5;       // 00000000000000000000000000100000
static const uint32_t edgeCategory = 0x1 << 6;          // 00000000000000000000000001000000
static const uint32_t bumperCategory = 0x1 << 7;        // 00000000000000000000000010000000
static const uint32_t bumperSideCategory = 0x1 << 8;    // 00000000000000000000000100000000
static const uint32_t catcherCategory = 0x1 << 9;       // 00000000000000000000001000000000

SKSpriteNode *ball;
SKSpriteNode *score1;
SKSpriteNode *score10;
SKSpriteNode *score100;
SKSpriteNode *score1000;

SKLabelNode *myLabel;

SKLabelNode *score;
int scorePoints;
BOOL leftPaddleHot;
BOOL rightPaddleHot;
SKAction *soundBumper;
SKAction *soundSideBumper;

SKAction *soundFlipper;
SKAction *soundFlipperDown;
SKAction *soundStarter;
SKAction *soundBalllost;

CGPoint startBall;
CGPoint startLeftFlipper;
CGPoint startRightFlipper;

int numberOfBalls;
NSArray *numberOfBallsToPlay;
int highscore;

BOOL ballInTransition;
@implementation MyScene

- (void)newBall {
    ball = [SKSpriteNode spriteNodeWithImageNamed:@"Ball.png"];
    ball.position = CGPointMake(CGRectGetMidX(self.frame)+350,
                                CGRectGetMidY(self.frame)-280);;
    
    SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
    ball.name = ballCategoryName;
    [ball runAction:[SKAction repeatActionForever:action]];
    [self addChild:ball];
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    ball.physicsBody.friction = 0.0f;
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.linearDamping = 0.6f;
    ball.physicsBody.allowsRotation = NO;
    ball.physicsBody.usesPreciseCollisionDetection = YES;
    ball.physicsBody.categoryBitMask = ballCategory;
    ball.physicsBody.contactTestBitMask = bottomCategory | paddleRightCategory | paddleLeftCategory |bumperCategory | bumperSideCategory | catcherCategory;

    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"PinballFire" ofType:@"sks"];
    SKEmitterNode *myParticle = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    myParticle.particlePosition = CGPointMake(0, 0);
    myParticle.name = @"Smoke";
    myParticle.particleBirthRate = 100;
    myParticle.numParticlesToEmit = 0;
    myParticle.targetNode = self.scene;
    ball.alpha = 1.0;
    [ball addChild:myParticle];
    ballInTransition = NO;
    
    startBall = ball.position;
 
    
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        numberOfBalls = 5;
        highscore = 0;
        
        leftPaddleHot = NO;
        rightPaddleHot = NO;
        self.physicsWorld.gravity = CGVectorMake(0.0f, -9.0f);
      
        [YMCPhysicsDebugger init];
        soundBalllost = [SKAction playSoundFileNamed:@"Drain7.wav" waitForCompletion:NO];
        soundBumper = [SKAction playSoundFileNamed:@"Bumper3.wav" waitForCompletion:NO];
        soundSideBumper = [SKAction playSoundFileNamed:@"bump.wav" waitForCompletion:NO];
        soundFlipper = [SKAction playSoundFileNamed:@"FlipperUp1.wav" waitForCompletion:NO];
        soundFlipperDown = [SKAction playSoundFileNamed:@"FlipperDown3.wav" waitForCompletion:NO];
        soundStarter = [SKAction playSoundFileNamed:@"Gate1.wav" waitForCompletion:NO];
        
        SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:@"PinballBackground.png"];
        background.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addChild:background];
 
        SKAction *small = [SKAction scaleBy:0.5 duration:0];
        
        SKSpriteNode *life1 = [SKSpriteNode spriteNodeWithImageNamed:@"Ball.png"];
        life1.position = CGPointMake(CGRectGetMidX(self.frame)+280, CGRectGetMidY(self.frame)-480);
        [life1 runAction:small];
        [self addChild:life1];
        SKSpriteNode *life2 = [SKSpriteNode spriteNodeWithImageNamed:@"Ball.png"];
        life2.position = CGPointMake(CGRectGetMidX(self.frame)+250, CGRectGetMidY(self.frame)-480);
        [life2 runAction:small];
        [self addChild:life2];
        SKSpriteNode *life3 = [SKSpriteNode spriteNodeWithImageNamed:@"Ball.png"];
        life3.position = CGPointMake(CGRectGetMidX(self.frame)+220, CGRectGetMidY(self.frame)-480);
        [life3 runAction:small];
        [self addChild:life3];
        SKSpriteNode *life4 = [SKSpriteNode spriteNodeWithImageNamed:@"Ball.png"];
        life4.position = CGPointMake(CGRectGetMidX(self.frame)+190, CGRectGetMidY(self.frame)-480);
        [life4 runAction:small];
        [self addChild:life4];
        SKSpriteNode *life5 = [SKSpriteNode spriteNodeWithImageNamed:@"Ball.png"];
        life5.position = CGPointMake(CGRectGetMidX(self.frame)+160, CGRectGetMidY(self.frame)-480);
        [life5 runAction:small];
        [self addChild:life5];

        numberOfBallsToPlay = [[NSArray alloc] initWithObjects:life1,life2,life3,life4,life5, nil];
      
        
        // 1 Create an physics body that borders the screen
        SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        // 2 Set physicsBody of scene to borderBody
        self.physicsBody = borderBody;
        // 3 Set the friction of that physicsBody to 0
        self.physicsBody.friction = 0.0f;
        
 
        score1 = [SKSpriteNode spriteNodeWithImageNamed:@"0.png"];
        score1.position = CGPointMake(CGRectGetMidX(self.frame)+75,
                                      CGRectGetMidY(self.frame)-230);
        
        [self addChild:score1];
        score10 = [SKSpriteNode spriteNodeWithImageNamed:@"0.png"];
        score10.position = CGPointMake(CGRectGetMidX(self.frame)+25,
                                      CGRectGetMidY(self.frame)-230);
        
        [self addChild:score10];
        score100 = [SKSpriteNode spriteNodeWithImageNamed:@"0.png"];
        score100.position = CGPointMake(CGRectGetMidX(self.frame)-25,
                                      CGRectGetMidY(self.frame)-230);
        
        [self addChild:score100];
        score1000 = [SKSpriteNode spriteNodeWithImageNamed:@"0.png"];
        score1000.position = CGPointMake(CGRectGetMidX(self.frame)-75,
                                      CGRectGetMidY(self.frame)-230);
        
        [self addChild:score1000];
        
        
        myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        myLabel.text = @"Pinball Wizard";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame)-200);
        [self addChild:myLabel];
  

        score = 0;
        
        [self newBall];
   //     [ball.physicsBody applyImpulse:CGVectorMake(0.0f, -200.0f)];
   
        
        SKSpriteNode* paddleLeft = [[SKSpriteNode alloc] initWithImageNamed: @"PaddleL.png"];
        paddleLeft.name = paddleLeftCategoryName;
        paddleLeft.position = CGPointMake(CGRectGetMidX(self.frame)-130, paddleLeft.frame.size.height * 0.5f);
        UIBezierPath *paddleLeftPath = [UIBezierPath bezierPath];

        [paddleLeftPath moveToPoint:CGPointMake(CGRectGetMidX(paddleLeft.frame) -265.0, 20.0)];
        [paddleLeftPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleLeft.frame) -165, -40.0)];
        [paddleLeftPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleLeft.frame) -155, -50.0)];
        [paddleLeftPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleLeft.frame) -160, -60.0)];
        [paddleLeftPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleLeft.frame) -230, -40.0)];
        [paddleLeftPath closePath];
        
        [self addChild:paddleLeft];
        paddleLeft.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:paddleLeftPath.CGPath];
        paddleLeft.physicsBody.restitution = 0.1f;
        paddleLeft.physicsBody.friction = 0.4f;
        // make physicsBody static
        paddleLeft.physicsBody.dynamic = NO;
        paddleLeft.physicsBody.usesPreciseCollisionDetection = YES;
        paddleLeft.physicsBody.categoryBitMask = paddleLeftCategory;
        
        
        SKSpriteNode* paddleRight = [[SKSpriteNode alloc] initWithImageNamed: @"PaddleR.png"];
        paddleRight.name = paddleRightCategoryName;
        paddleRight.position = CGPointMake(CGRectGetMidX(self.frame)+140, paddleRight.frame.size.height * 0.5f);
        UIBezierPath *paddleRightPath = [UIBezierPath bezierPath];
        [paddleRightPath moveToPoint:CGPointMake(CGRectGetMidX(paddleRight.frame) -515, 20.0)];
        [paddleRightPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleRight.frame) -615, -40.0)];
        [paddleRightPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleRight.frame) -620, -50.0)];
        [paddleRightPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleRight.frame) -620, -60.0)];
        [paddleRightPath addLineToPoint:CGPointMake(CGRectGetMidX(paddleRight.frame) -550, -30.0)];

        [paddleRightPath closePath];
        [self addChild:paddleRight];
        paddleRight.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:paddleRightPath.CGPath];
        paddleRight.physicsBody.restitution = 0.1f;
        paddleRight.physicsBody.friction = 0.4f;
        // make physicsBody static
        paddleRight.physicsBody.dynamic = NO;
        paddleRight.physicsBody.usesPreciseCollisionDetection = YES;
        paddleRight.physicsBody.categoryBitMask = paddleRightCategory;
        
        startLeftFlipper = paddleLeft.position;
        startRightFlipper = paddleRight.position;
        
        SKSpriteNode* starter = [[SKSpriteNode alloc] initWithImageNamed: @"Starter.png"];
        starter.name = starterCategoryName;
        starter.position = CGPointMake(CGRectGetMidX(self.frame)+350, starter.frame.size.height * 0.6f);
        [self addChild:starter];
        starter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:starter.frame.size];
        starter.physicsBody.restitution = 0.1f;
        starter.physicsBody.friction = 1.0f;
        // make physicsBody static
        starter.physicsBody.dynamic = NO;
 
        SKSpriteNode* catcher = [[SKSpriteNode alloc] initWithImageNamed: @"catcher.png"];
        catcher.name = catcherCategoryName;
        catcher.position = CGPointMake(CGRectGetMidX(self.frame)-350, catcher.frame.size.height * 0.6f);
        [self addChild:catcher];
        catcher.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:catcher.frame.size.height/1.5];
        catcher.physicsBody.restitution = 0.1f;
        catcher.physicsBody.friction = 1.0f;
        // make physicsBody static
        catcher.physicsBody.dynamic = NO;
        catcher.physicsBody.categoryBitMask = catcherCategory;
   
        
        
        SKSpriteNode* bumper = [[SKSpriteNode alloc] initWithImageNamed: @"Twitter.png"];
        bumper.name = bumperCategoryName;
        bumper.position = CGPointMake(CGRectGetMidX(self.frame)-180, CGRectGetMidY(self.frame)+290);
        [self addChild:bumper];
        bumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bumper.frame.size.height/2.8];
        bumper.physicsBody.restitution = 0.1f;
        bumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        bumper.physicsBody.dynamic = NO;
        bumper.physicsBody.categoryBitMask = bumperCategory;

        
        bumper = [[SKSpriteNode alloc] initWithImageNamed: @"Twitter.png"];
        bumper.name = bumperCategoryName;
        bumper.position = CGPointMake(CGRectGetMidX(self.frame)+180, CGRectGetMidY(self.frame)+290);
        [self addChild:bumper];
        bumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bumper.frame.size.height/2.8];
        bumper.physicsBody.restitution = 0.1f;
        bumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        bumper.physicsBody.dynamic = NO;
        bumper.physicsBody.categoryBitMask = bumperCategory;
   
        SKSpriteNode* leftBumper = [[SKSpriteNode alloc] initWithImageNamed: @"elephant.png"];
        leftBumper.name = bumperSideCategoryName;
        leftBumper.position = CGPointMake(CGRectGetMidX(self.frame)-350, CGRectGetMidY(self.frame)+160);
        [self addChild:leftBumper];
        leftBumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:leftBumper.frame.size.height/2.8];
        leftBumper.physicsBody.restitution = 0.1f;
        leftBumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        leftBumper.physicsBody.dynamic = NO;
        leftBumper.physicsBody.categoryBitMask = bumperSideCategory;
    
        leftBumper = [[SKSpriteNode alloc] initWithImageNamed: @"elephant.png"];
        leftBumper.name = bumperSideCategoryName;
        leftBumper.position = CGPointMake(CGRectGetMidX(self.frame)-350, CGRectGetMidY(self.frame)+050);
        [self addChild:leftBumper];
        leftBumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:leftBumper.frame.size.height/2.8];
        leftBumper.physicsBody.restitution = 0.1f;
        leftBumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        leftBumper.physicsBody.dynamic = NO;
        leftBumper.physicsBody.categoryBitMask = bumperSideCategory;
        leftBumper = [[SKSpriteNode alloc] initWithImageNamed: @"elephant.png"];
        leftBumper.name = bumperSideCategoryName;
        leftBumper.position = CGPointMake(CGRectGetMidX(self.frame)-350, CGRectGetMidY(self.frame)-100);
        [self addChild:leftBumper];
        leftBumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:leftBumper.frame.size.height/2.8];
        leftBumper.physicsBody.restitution = 0.1f;
        leftBumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        leftBumper.physicsBody.dynamic = NO;
        leftBumper.physicsBody.categoryBitMask = bumperSideCategory;
        
        
        SKSpriteNode* rightBumper = [[SKSpriteNode alloc] initWithImageNamed: @"monkey.png"];
        rightBumper.name = bumperSideCategoryName;
        rightBumper.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame)+160);
        [self addChild:rightBumper];
        rightBumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rightBumper.frame.size.height/2.8];
        rightBumper.physicsBody.restitution = 0.1f;
        rightBumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        rightBumper.physicsBody.dynamic = NO;
        rightBumper.physicsBody.categoryBitMask = bumperSideCategory;
        
        rightBumper = [[SKSpriteNode alloc] initWithImageNamed: @"monkey.png"];
        rightBumper.name = bumperSideCategoryName;
        rightBumper.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame)+050);
        [self addChild:rightBumper];
        rightBumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rightBumper.frame.size.height/2.8];
        rightBumper.physicsBody.restitution = 0.1f;
        rightBumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        rightBumper.physicsBody.dynamic = NO;
        rightBumper.physicsBody.categoryBitMask = bumperSideCategory;
        rightBumper = [[SKSpriteNode alloc] initWithImageNamed: @"monkey.png"];
        rightBumper.name = bumperSideCategoryName;
        rightBumper.position = CGPointMake(CGRectGetMidX(self.frame)+300, CGRectGetMidY(self.frame)-100);
        [self addChild:rightBumper];
        rightBumper.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rightBumper.frame.size.height/2.8];
        rightBumper.physicsBody.restitution = 0.1f;
        rightBumper.physicsBody.friction = 0.4f;
        // make physicsBody static
        rightBumper.physicsBody.dynamic = NO;
        rightBumper.physicsBody.categoryBitMask = bumperSideCategory;
        
        
        CGRect bottomRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width-200, 1);
        SKNode* bottom = [SKNode node];
        bottom.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:bottomRect];
        bottom.physicsBody.categoryBitMask = bottomCategory;
        [self addChild:bottom];


        UIBezierPath *rightUpperPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.frame) + 135, 770)
                                                             radius:250
                                                         startAngle:0
                                                           endAngle:90 * M_PI / 180
                                                          clockwise:YES];
        
        SKNode* rightUpperCorner = [SKNode node];
        rightUpperCorner.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:rightUpperPath.CGPath];
        rightUpperCorner.physicsBody.restitution = 0.0f;
        rightUpperCorner.physicsBody.friction = 0.0f;
        rightUpperCorner.physicsBody.dynamic = NO;
        rightUpperCorner.name = edgeCategoryName;
        [self addChild:rightUpperCorner];
        rightUpperCorner.physicsBody.categoryBitMask = edgeCategory;

        UIBezierPath *leftUpperPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.frame) -135, 770)
                                                                      radius:250
                                                                  startAngle:90 * M_PI / 180
                                                                    endAngle:199 * M_PI / 180
                                                                   clockwise:YES];
        
        SKNode* leftUpperCorner = [SKNode node];
        leftUpperCorner.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:leftUpperPath.CGPath];
        leftUpperCorner.physicsBody.restitution = 0.0f;
        leftUpperCorner.physicsBody.friction = 0.0f;
        leftUpperCorner.physicsBody.dynamic = NO;
        leftUpperCorner.name = edgeCategoryName;
        [self addChild:leftUpperCorner];
        leftUpperCorner.physicsBody.categoryBitMask = edgeCategory;

        UIBezierPath *laneBorderPath = [UIBezierPath bezierPath];
        [laneBorderPath moveToPoint:CGPointMake(CGRectGetMidX(self.frame) +330, 30.0)];
        [laneBorderPath addLineToPoint:CGPointMake(CGRectGetMidX(self.frame) +330, 750.0)];
        [laneBorderPath closePath];
        
        SKNode* laneBorder = [SKNode node];
        laneBorder.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:laneBorderPath.CGPath];
        laneBorder.physicsBody.restitution = 0.0f;
        laneBorder.physicsBody.friction = 0.0f;
        laneBorder.physicsBody.dynamic = NO;
        laneBorder.name = edgeCategoryName;
        [self addChild:laneBorder];
    
        laneBorderPath = [UIBezierPath bezierPath];
        [laneBorderPath moveToPoint:CGPointMake(CGRectGetMidX(self.frame) +330, 210.0)];
        [laneBorderPath addLineToPoint:CGPointMake(CGRectGetMidX(self.frame) +150, 100.0)];
        [laneBorderPath closePath];
        
        laneBorder = [SKNode node];
        laneBorder.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:laneBorderPath.CGPath];
        laneBorder.physicsBody.restitution = 0.0f;
        laneBorder.physicsBody.friction = 0.0f;
        laneBorder.physicsBody.dynamic = NO;
        laneBorder.name = edgeCategoryName;
        [self addChild:laneBorder];
     
        laneBorderPath = [UIBezierPath bezierPath];
        [laneBorderPath moveToPoint:CGPointMake(CGRectGetMidX(self.frame) -330, 0.0)];
        [laneBorderPath addLineToPoint:CGPointMake(CGRectGetMidX(self.frame) -330, 210.0)];
        [laneBorderPath addLineToPoint:CGPointMake(CGRectGetMidX(self.frame) -150, 100.0)];
        [laneBorderPath addLineToPoint:CGPointMake(CGRectGetMidX(self.frame) -150, 0.0)];
        [laneBorderPath closePath];
        
        laneBorder = [SKNode node];
        laneBorder.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:laneBorderPath.CGPath];
        laneBorder.physicsBody.restitution = 0.0f;
        laneBorder.physicsBody.friction = 0.0f;
        laneBorder.physicsBody.dynamic = NO;
        laneBorder.name = edgeCategoryName;
        [self addChild:laneBorder];
        
      
//  SKNode* rightUpperCorner = [SKNode node];
//        SKSpriteNode* rightUpperCorner = [[SKSpriteNode alloc] initWithImageNamed: @"RightUpperCornerRed.png"];
//        rightUpperCorner.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//        rightUpperCorner.name = edgeCategoryName;
//        
//        rightUpperCorner.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:aPath.CGPath];
//        rightUpperCorner.physicsBody.restitution = 0.1f;
//        rightUpperCorner.physicsBody.friction = 0.4f;
//        rightUpperCorner.physicsBody.dynamic = NO;
//       [self addChild:rightUpperCorner];
//      
        
   
        
        
        self.physicsWorld.contactDelegate = self;
   
//      [self drawPhysicsBodies];
        
        NSLog(@"Mass of ball %f ", ball.physicsBody.mass);
        
        NSLog(@"Mass of paddle %f ", paddleRight.physicsBody.mass);
        
        
        NSLog(@"Density of ball %f ", ball.physicsBody.density);
        
        NSLog(@"Density of paddle %f ", paddleRight.physicsBody.density);

   //     paddleRight.physicsBody.density = 10000;
   //     paddleLeft.physicsBody.density = 10000;
        
    }
    return self;
}

-(void)updateScore
{
    NSLog(@"%04i", scorePoints);
    NSString *temp = [NSString stringWithFormat:@"%04i", scorePoints];
 
    NSString *score1string = [temp substringWithRange:NSMakeRange(3, 1)];
    SKAction *changeScore = [SKAction setTexture:[SKTexture textureWithImageNamed:score1string]];
    [score1 runAction:changeScore];
    
    NSString *score10string = [temp substringWithRange:NSMakeRange(2, 1)];
    changeScore = [SKAction setTexture:[SKTexture textureWithImageNamed:score10string]];
    [score10 runAction:changeScore];
    
    NSString *score100string = [temp substringWithRange:NSMakeRange(1, 1)];
    changeScore = [SKAction setTexture:[SKTexture textureWithImageNamed:score100string]];
    [score100 runAction:changeScore];
    
    NSString *score1000string = [temp substringWithRange:NSMakeRange(0, 1)];
    changeScore = [SKAction setTexture:[SKTexture textureWithImageNamed:score1000string]];
    [score1000 runAction:changeScore];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    /* Called when a touch begins */
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];

    SKNode* body = [self nodeAtPoint:touchLocation];
    if (body && [body.name isEqualToString: paddleLeftCategoryName]) {
        NSLog(@"Began touch on left paddle");
        
        SKAction *hot = [SKAction runBlock:^{
            leftPaddleHot = YES;
        }];
        SKAction *rotateUp = [SKAction rotateToAngle:+45 * M_PI / 180 duration:0.1];
        SKAction *cold = [SKAction runBlock:^{
            leftPaddleHot = NO;
        }];
        SKAction *sequence = [SKAction sequence:@[hot, rotateUp, cold]];
        SKAction *group = [SKAction group:@[soundFlipperDown, sequence]];
        [body runAction:group];
    }
    if (body && [body.name isEqualToString: paddleRightCategoryName]) {
        NSLog(@"Began touch on right paddle");
        SKAction *hot = [SKAction runBlock:^{
            rightPaddleHot = YES;
        }];
        SKAction *rotateUp = [SKAction rotateToAngle:-45 * M_PI / 180 duration:0.1];
        SKAction *cold = [SKAction runBlock:^{
            rightPaddleHot = NO;
        }];
        SKAction *sequence = [SKAction sequence:@[hot, rotateUp, cold]];
        SKAction *group = [SKAction group:@[soundFlipperDown, sequence]];
        [body runAction:group];

    }

    if (body && [body.name isEqualToString: starterCategoryName]) {
        NSLog(@"Began touch on starter");
        ballInTransition = NO;
        [ball.physicsBody applyImpulse:CGVectorMake(0.0f, -200.0f)];
        ball.physicsBody.contactTestBitMask = bottomCategory | paddleRightCategory | paddleLeftCategory |bumperCategory | bumperSideCategory | catcherCategory;
        
        
    }
    

}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    /* Called when a touch ends */
    UITouch* touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    
    SKNode* body = [self nodeAtPoint:touchLocation];
    if (body && [body.name isEqualToString: paddleLeftCategoryName]) {
        NSLog(@"Began touch on left paddle");
        SKAction *rotateDown = [SKAction rotateToAngle:0 * M_PI / 180 duration:0.1];
        SKAction *sequence = [SKAction sequence:@[rotateDown]];
        SKAction *group = [SKAction group:@[soundFlipperDown, sequence]];
        [body runAction:group];
    }
    if (body && [body.name isEqualToString: paddleRightCategoryName]) {
        NSLog(@"End touch on right paddle");
        SKAction *rotateDown = [SKAction rotateToAngle:0 * M_PI / 180 duration:0.1];
        SKAction *sequence = [SKAction sequence:@[rotateDown]];
        SKAction *group = [SKAction group:@[soundFlipperDown, sequence]];
        [body runAction:group];
        
        //       self.isFingerOnPaddle = YES;
    }
    
    if (body && [body.name isEqualToString: starterCategoryName]) {
        myLabel.text = @"Pinball Wizard";
        //       self.isFingerOnPaddle = YES;
        
    }
}

- (void)didBeginContact:(SKPhysicsContact*)contact {
    // 1 Create local variables for two physics bodies
    SKPhysicsBody* firstBody;
    SKPhysicsBody* secondBody;
    // 2 Assign the two physics bodies so that the one with the lower category is always stored in firstBody
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    // 3 react to the contact between ball and bottom
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bottomCategory) {
         NSLog(@"Ball Out");
        
        if (ballInTransition)
        {
            //
        }
        else
        {
            ballInTransition = YES;
        
        ball.physicsBody.contactTestBitMask = 0;
        SKAction *fadeOutBall = [SKAction fadeAlphaTo:0 duration:0];
        SKAction *resetBall = [SKAction moveTo:startBall duration:1.5];
        SKAction *fadeInBall = [SKAction fadeAlphaTo:1 duration:0];
        SKAction *sequence = [SKAction sequence:@[fadeOutBall, resetBall, fadeInBall]];
        SKAction *group = [SKAction group:@[soundBalllost, sequence]];
        [firstBody.node runAction:group];
        
        SKSpriteNode *ballScore =  [numberOfBallsToPlay objectAtIndex:(numberOfBalls-1)];
        ballScore.alpha = 0;
        numberOfBalls--;
        
        if (numberOfBalls == 0)
        {
            myLabel.text = [NSString stringWithFormat:@"GAME OVER - Highscore is %i", highscore];
            if (scorePoints > highscore)
            {
                myLabel.text = @"GAME OVER - NEW HIGHSCORE";
                highscore = scorePoints;
            }
            scorePoints = 0;
            numberOfBalls = 5;
            for (SKSpriteNode *ballScore in numberOfBallsToPlay)
            {
                ballScore.alpha = 1;
            }
        }
        }
        
    //    [firstBody.node removeFromParent];
    //    [self newBall];
    //    GameOverScene* gameOverScene = [[GameOverScene alloc] initWithSize:self.frame.size playerWon:NO];
    //    [self.view presentScene:gameOverScene];
    }
  
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == catcherCategory) {
        NSLog(@"Ball Catcher");
        ball.physicsBody.contactTestBitMask = 0;
        
        SKAction *bumpBigger = [SKAction scaleBy:2.0 duration:0.5];
        SKAction *wait = [SKAction waitForDuration:1.0];
        SKAction *bumpSmaller = [SKAction scaleBy:.5 duration:0.5];
        SKAction *sequenceForBump = [SKAction sequence:@[bumpSmaller, wait, bumpBigger]];
        SKAction *groupBump = [SKAction group:@[soundStarter, sequenceForBump]];
        [firstBody.node runAction:groupBump];
        ball.physicsBody.contactTestBitMask = bottomCategory | paddleRightCategory | paddleLeftCategory |bumperCategory | bumperSideCategory | catcherCategory;
        [ball.physicsBody applyImpulse:CGVectorMake(-0.0f, -100.0f)];
        scorePoints += 250;
    }
    
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleLeftCategory) {
         NSLog(@"Left Paddle hit");
        if (leftPaddleHot)
        {
        [ball.physicsBody applyImpulse:CGVectorMake(5.0f, -150.0f)];
        }
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == paddleRightCategory) {
        NSLog(@"Right Paddle hit");
        if (rightPaddleHot)
        {
             [ball.physicsBody applyImpulse:CGVectorMake(-5.0f, -150.0f)];
        }
    }

    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bumperCategory) {
        NSLog(@"Bumper hit");
        SKAction *bumpBigger = [SKAction scaleBy:0.5 duration:0.2];
        SKAction *bumpSmaller = [SKAction scaleBy:2.0 duration:0.2];
        SKAction *sequenceForBump = [SKAction sequence:@[bumpBigger, bumpSmaller]];
        SKAction *groupBump = [SKAction group:@[soundBumper, sequenceForBump]];
        [secondBody.node runAction:groupBump];
        scorePoints += 10;
        [self updateScore];
    }
    
    if (firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == bumperSideCategory) {
        NSLog(@"Bumper Side hit");
        SKAction *bumpBigger = [SKAction scaleBy:.5 duration:0.2];
        SKAction *bumpSmaller = [SKAction scaleBy:2.0 duration:0.2];
        SKAction *sequenceForBump = [SKAction sequence:@[bumpBigger, bumpSmaller]];
        SKAction *groupBump = [SKAction group:@[soundSideBumper, sequenceForBump]];
        [secondBody.node runAction:groupBump];
        scorePoints += 5;
        [self updateScore];
    }
    
  

}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end

//
//  GameScene.m
//  SpritKitDemo
//
//  Created by SQR Infotech on 22/12/14.
//  Copyright (c) 2014 SQrInfotech. All rights reserved.
//

#import "GameScene.h"

#define BOY_POSITION            CGPointMake(110,150)

#define SLING_BOMB_POSITION		CGPointMake(400,100)
#define SLING_MAX_ANGLE			34
#define SLING_MIN_ANGLE			-72
#define SLING_TOUCH_RADIUS		150
#define SLING_LAUNCH_RADIUS		150
#define BUBBLE_POSITION         CGPointMake(100,100)
#define BOMS                 10

#define PTM_RATIO 32

#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180

@implementation GameScene

-(id)initWithSize:(CGSize)size
{
    if (self=[super initWithSize:size])
    {
//
        self.physicsWorld.gravity = CGVectorMake(0.0f, -10.0f);
        SKPhysicsBody *borderBody =[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsBody= borderBody;
        
        ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
        ball.name = @"ball";
        ball.position = SLING_BOMB_POSITION;//CGPointMake(100, 100);
        [self addChild:ball];
        
        
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
//    SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//    
//    myLabel.text = @"Hello, World!";
//    myLabel.fontSize = 65;
//    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                   CGRectGetMidY(self.frame));
//    
//    [self addChild:myLabel];
    

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        
//        ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
//        ball.name = @"ball";
//        ball.position = location;
//        [self addChild:ball];
//        
//        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
//        
//        ball.physicsBody.friction = 0.0f;
//        
//        ball.physicsBody.restitution = 0.0f;
//        
//        ball.physicsBody.linearDamping = 0.0f;
        
//      [ball.physicsBody applyImpulse:CGVectorMake(10.0f,-10.0f)];
        
        
        
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint location = [touch locationInNode:self];
    
    ball.position = location;
    

    
    CGPoint pt = location;
    
//    SKSpriteNode *s = ball;

    CGPoint vector = SDiffBetweenPoints(pt, SLING_BOMB_POSITION);
    
    CGPoint normalVector = ccpNormalize(vector);
    float angleRads = ccpToAngle(normalVector);
    angleDegs = (int)CC_RADIANS_TO_DEGREES(angleRads) % 360;
    float length = ccpLength(vector);
    
    if (length > SLING_LAUNCH_RADIUS)
        length = SLING_LAUNCH_RADIUS;
    
//    CCNode *s = ar;//[self getChildByTag:111];
    
    if (length/150 > 150)
    {
        length = 150;
    }
    
//    s.xScale = length/150;
//    s.anchorPoint = CGPointMake(1, 0.5);
//    
//    s.zRotation = -angleDegs;
    
    ball.position = ccpAdd(SLING_BOMB_POSITION, ccpMult(normalVector, length));
    

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    SKSpriteNode *s = ball;
    
    speed =  SDistanceBetweenPoints(SLING_BOMB_POSITION,s.position); // pt is the current touch point
    float xp = -(s.position.x - SLING_BOMB_POSITION.x) / PTM_RATIO;
    float y = -(s.position.y - SLING_BOMB_POSITION.y) / PTM_RATIO;
    float g = 9.8;
    float v = speed-15;
    float angle2 = 0.0;
    if (v > SLING_LAUNCH_RADIUS) {
        v = SLING_LAUNCH_RADIUS;
    }
    float tmp = pow(v, 4) - g * (g * pow(xp, 2) + 2 * y * pow(v, 2));
    
    if(tmp < 0){
        printf("too slow! \n");
    }else{
        //angle1 = atan2(pow(v, 2) + sqrt(tmp), g * xp);
        angle2 = atan2(pow(v, 2) - sqrt(tmp), g * xp);
    }
    
    CGPoint direction = CGPointMake(cosf(angle2),sinf(angle2));
    CGPoint force = CGPointMake(direction.x * v, direction.y * v);
    
    float length = 100;
    length /= PTM_RATIO;

    
    CGVector _forceVector = CGVectorMake(force.x*length,force.y*length);
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.frame.size.width/2];
    
    ball.physicsBody.friction = 0.3f;
    
    ball.physicsBody.restitution = 0.0f;
    
    ball.physicsBody.linearDamping = 0.0f;
    
    ball.physicsBody.density = 0.36;
    
//    [ball.physicsBody applyForce:_forceVector];
    
    [ball.physicsBody applyImpulse:_forceVector atPoint:CGPointMake(1, 1)];

}

CGFloat SDistanceBetweenPoints(CGPoint first, CGPoint second)
{
    return hypotf(second.x - first.x, second.y - first.y);
}

CGPoint SDiffBetweenPoints(CGPoint first, CGPoint second)
{
    CGPoint p = CGPointMake(first.x - second.x, first.y - second.y);
    return p;
}

CGPoint ccpNormalize(const CGPoint v)
{
    return ccpMult(v, 1.0f/ccpLength(v));
}

static inline CGPoint ccpMult(const CGPoint v, const CGFloat s)
{
    return CGPointMake(v.x*s, v.y*s);
}

CGFloat ccpToAngle(const CGPoint v)
{
    return atan2f(v.y, v.x);
}


CGFloat ccpLength(const CGPoint v)
{
    return sqrtf(ccpLengthSQ(v));
}

static inline CGFloat
ccpLengthSQ(const CGPoint v)
{
    return ccpDot(v, v);
}

static inline CGFloat
ccpDot(const CGPoint v1, const CGPoint v2)
{
    return v1.x*v2.x + v1.y*v2.y;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    //NSLog(@"frames ball %@",NSStringFromCGPoint(ball.position));
    
    
}

static inline CGPoint ccpAdd(const CGPoint v1, const CGPoint v2)
{
    return CGPointMake(v1.x + v2.x, v1.y + v2.y);
}


@end

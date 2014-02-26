//
//  MyScene.h
//  Pinball
//

//  Copyright (c) 2014 Josef Hilbert. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
@import AVFoundation;

@interface MyScene : SKScene<SKPhysicsContactDelegate>
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@end

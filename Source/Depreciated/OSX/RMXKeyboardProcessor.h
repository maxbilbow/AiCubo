
//
//  RMXKeyboardProcessor.h
//  RattleGL3.0
//
//  Created by Max Bilbow on 09/03/2015.
//  Copyright (c) 2015 Rattle Media. All rights reserved.
//

#ifndef RattleGL3_0_RMXKeyboardProcessor_h
#define RattleGL3_0_RMXKeyboardProcessor_h


#endif


struct KeyProcessor;


void initKeys();

void RepeatedKeys();

void movement(float speed, int key);

void keyDownOperations (int key);

//template <typename Particle>
void keyUpOperations(int key);
void keySpecialDownOperations(int key);

void keySpecialUpOperations(char key);

void keySpecialOperations(void);
void RMXkeyPressed (unsigned char key, int x, int y);
void RMXkeyUp (unsigned char key, int x, int y);
void RMXkeySpecial (int key, int x, int y);
void RMXkeySpecialUp (int key, int x, int y);
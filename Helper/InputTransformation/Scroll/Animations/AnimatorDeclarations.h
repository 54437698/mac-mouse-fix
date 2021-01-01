//
// --------------------------------------------------------------------------
// Animator.h
// Created for Mac Mouse Fix (https://github.com/noah-nuebling/mac-mouse-fix)
// Created by Noah Nuebling in 2021
// Licensed under MIT
// --------------------------------------------------------------------------
//

#ifndef AnimatorDeclarations_h
#define AnimatorDeclarations_h

@import Foundation;

typedef struct {
    double value;
    double duration;
//    id curve; /// Putting an Objc type into the struct makes the struct invisible to swift
} MFAnimatorStartParams;

typedef enum {
    kMFAnimationPhaseStart = 0,
    kMFAnimationPhaseRunningStart = 1, /// Animation has been started again while it was already running
    kMFAnimationPhaseContinue = 2,
    kMFAnimationPhaseEnd = 4,
    kMFAnimationPhaseStartAndEnd = 8, /// Used when there is only one delta in the animation. So that delta is the first _and_ the last one.
    kMFAnimationPhaseNone = 16,
} MFAnimationPhase;

#endif /* Animator_h */
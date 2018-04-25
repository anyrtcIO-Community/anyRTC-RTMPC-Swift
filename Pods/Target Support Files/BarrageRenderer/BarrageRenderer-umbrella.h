#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BarrageHeader.h"
#import "BarrageCanvas.h"
#import "BarrageClock.h"
#import "BarrageDescriptor.h"
#import "BarrageDispatcher.h"
#import "BarrageRenderer.h"
#import "BarrageSpriteFactory.h"
#import "BarrageSpriteQueue.h"
#import "BarrageLoader.h"
#import "BarrageFloatImageSprite.h"
#import "BarrageFloatSprite.h"
#import "BarrageFloatTextSprite.h"
#import "BarrageSprite.h"
#import "BarrageSpriteProtocol.h"
#import "BarrageSpriteUtility.h"
#import "BarrageViewPool.h"
#import "BarrageWalkImageSprite.h"
#import "BarrageWalkSprite.h"
#import "BarrageWalkTextSprite.h"
#import "UIImageView+BarrageView.h"
#import "UILabel+BarrageView.h"
#import "UIView+BarrageView.h"

FOUNDATION_EXPORT double BarrageRendererVersionNumber;
FOUNDATION_EXPORT const unsigned char BarrageRendererVersionString[];


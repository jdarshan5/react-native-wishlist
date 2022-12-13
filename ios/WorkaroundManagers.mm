#import "WorkaroundManagers.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTBridge.h>
#import <React/RCTComponentViewFactory.h>
#import <React/RCTInitializing.h>
#import <React/RCTScheduler.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterStub.h>
#import <ReactCommon/RCTTurboModule.h>
#include <jsi/JSIDynamic.h>
#include <jsi/jsi.h>
#include <react/renderer/components/view/ViewEventEmitter.h>
#include <react/renderer/core/EventListener.h>
#import "MGWishListComponent.h"
#include "WishlistJsRuntime.h"

using EventListener = facebook::react::EventListener;
using RawEvent = facebook::react::RawEvent;
using namespace Wishlist;

@interface Workaround : NSObject <RCTBridgeModule, RCTInvalidating, RCTInitializing>

@property (nonatomic, weak) RCTBridge *bridge;

@end

@implementation Workaround {
  __weak RCTSurfacePresenter *_surfacePresenter;
  std::shared_ptr<EventListener> _eventListener;
}

RCT_EXPORT_MODULE(Workaround);

- (void)setBridge:(RCTBridge *)bridge
{
  _bridge = bridge;
  _surfacePresenter = _bridge.surfacePresenter;
  _eventListener = std::make_shared<EventListener>([](const RawEvent &event) -> bool {
    if (!RCTIsMainQueue() or event.eventTarget == nullptr) {
      // TODO Scheduler reset
      return false;
    }
    std::string type = event.type;
    int tag = event.eventTarget->getTag();
    if (tag >= 0)
      return false;

    auto &rt = WishlistJsRuntime::getInstance().getRuntime();

    try {
      jsi::Function f = rt.global().getPropertyAsObject(rt, "global").getPropertyAsFunction(rt, "handleEvent");
      f.call(rt, jsi::String::createFromUtf8(rt, type), tag, event.payloadFactory(rt));
    } catch (std::exception e) {
      // do Nothing most likly the handler funciton is not registered yet
    }
    return true;
  });
  [_surfacePresenter.scheduler addEventListener:_eventListener];

  RCTCxxBridge *cxxBridge = (RCTCxxBridge *)_bridge;
  auto callInvoker = cxxBridge.jsCallInvoker;
  facebook::jsi::Runtime *jsRuntime = (facebook::jsi::Runtime *)cxxBridge.runtime;

  WishlistJsRuntime::getInstance().initialize(
      jsRuntime,
      [=](std::function<void()> &&f) {
        __block auto retainedWork = std::move(f);
        dispatch_async(dispatch_get_main_queue(), ^{
          retainedWork();
        });
      },
      [=](std::function<void()> &&f) { callInvoker->invokeAsync(std::move(f)); });
}

- (void)initialize
{
}

// TODO()
- (void)setSurfacePresenter:(id<RCTSurfacePresenterStub>)surfacePresenter
{
  // NOOP
}

- (void)invalidate
{
  [_surfacePresenter.scheduler removeEventListener:_eventListener];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(install)
{
  // This is only used to force the native module to load and setBridge to be called.
  return @true;
}

@end

@implementation MGWishlistComponentManager

RCT_EXPORT_MODULE(MGWishlist)

RCT_CUSTOM_VIEW_PROPERTY(inflatorId, NSString *, UIView) {}
RCT_CUSTOM_VIEW_PROPERTY(initialIndex, double, UIView) {}

RCT_EXPORT_VIEW_PROPERTY(onStartReached, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onEndReached, RCTDirectEventBlock)

- (UIView *)view
{
  return [[UIView alloc] init];
}

@end

@implementation MGTemplateContainerManager

RCT_EXPORT_MODULE(MGTemplateContainer)

RCT_CUSTOM_VIEW_PROPERTY(inflatorId, NSString *, UIView) {}

RCT_CUSTOM_VIEW_PROPERTY(wishlistId, NSString *, UIView) {}

RCT_CUSTOM_VIEW_PROPERTY(names, NSArray<NSString *> *, UIView) {}

- (UIView *)view
{
  return [[UIView alloc] init];
}

@end

@implementation MGTemplateInterceptorManager

RCT_EXPORT_MODULE(MGTemplateInterceptor)

RCT_CUSTOM_VIEW_PROPERTY(inflatorId, NSString *, UIView) {}

- (UIView *)view
{
  return [[UIView alloc] init];
}

@end

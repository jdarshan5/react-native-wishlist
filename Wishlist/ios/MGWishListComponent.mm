#import "MGWishListComponent.h"
#import <React/RCTConversions.h>
#import <React/RCTImageResponseDelegate.h>
#import <React/RCTImageResponseObserverProxy.h>

#import <react/renderer/components/rncore/EventEmitters.h>
#import <react/renderer/components/rncore/Props.h>
#import "RCTFabricComponentsPlugins.h"
#import "WishlistComponentDescriptors.h"
#import "WishlistProps.h"
#import "WishlistShadowNodes.h"
#import <React/RCTBridgeModule.h>
#import <React/RCTComponentViewFactory.h>
#import "MGScrollViewOrchestrator.h"

using namespace facebook::react;

@interface RCTScrollViewComponentView (MGWishList)
   
- (void)scrollViewDidScroll:(UIScrollView*)sv;

@end

@implementation MGWishListComponent{
    WishlistShadowNode::ConcreteState::Shared _sharedState;
    bool alreadyRendered;
    std::string inflatorId;
    MGScrollViewOrchestrator * _orchestrator;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if (self = [super initWithFrame:frame]) {
      self.scrollView.delaysContentTouches = NO;
      self.scrollView.canCancelContentTouches = true;
      alreadyRendered = false;
      
      [self.scrollView removeGestureRecognizer: self.scrollView.panGestureRecognizer];
      
      UIPanGestureRecognizer * customR = [UIPanGestureRecognizer new];
      [self.scrollView addGestureRecognizer:customR];
      [customR addTarget:self action:@selector(handlePan:)];
  }
  return self;
}

-(void) setInflatorId:(std::string)nextInflatorId {
  inflatorId = nextInflatorId;
- (void)layoutSubviews
{
    
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    NSLog(@"jest");
    if (_orchestrator != nil) {
        PanEvent * panEvent = [PanEvent new];
        panEvent.state = gesture.state;
        panEvent.velocity = [gesture velocityInView:self].y;
        panEvent.translation = [gesture translationInView:self].y;
        [_orchestrator notifyAboutEvent:panEvent];
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled) {
        
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint tr = [gesture translationInView:self.scrollView];
        CGPoint offset = self.scrollView.contentOffset;
        if (offset.y - tr.y)
        float overscroll = offset.y;
        self.scrollView.contentOffset = CGPointMake(offset.x, offset.y - tr.y);
        
        [gesture setTranslation:CGPointMake(0, 0) inView:self.scrollView];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<WishlistComponentDescriptor>();
}

-(void) setTemplates:(std::vector<std::shared_ptr<facebook::react::ShadowNode const>>)templates withNames:(std::vector<std::string>)names
{
    if (!alreadyRendered && names.size() > 0 && names.size() == templates.size()) {
        alreadyRendered = true;
        CGRect frame = self.frame;
        
        self.scrollView.contentSize = CGSizeMake(frame.size.width, 10000000);
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y, frame.size.width, frame.size.height);
        
        _orchestrator = [[MGScrollViewOrchestrator alloc] initWith:self.scrollView templates:templates names:names viewportObserver: _sharedState->getData().viewportObserver inflatorId:inflatorId];
        
    } else {
        [_orchestrator notifyAboutNewTemplates:templates withNames:names];
    }
}

#pragma mark - RCTComponentViewProtocol

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<WishlistComponentDescriptor>();
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
    inflatorId = std::dynamic_pointer_cast<const WishlistProps>(props)->inflatorId;
    _eventEmitter = nil;
}

- (void)updateState:(State::Shared const &)state oldState:(State::Shared const &)oldState
{
    _eventEmitter = nil; // temporary TODO fix this
    if (state == nullptr) return;
    auto newState = std::static_pointer_cast<WishlistShadowNode::ConcreteState const>(state);
    auto &data = newState->getData();
    _sharedState = newState;

  CGSize contentSize = RCTCGSizeFromSize(data.contentBoundingRect.size);

  self.containerView.frame = CGRect{RCTCGPointFromPoint(data.contentBoundingRect.origin), contentSize};
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_sharedState == nullptr) {
        return;
    }
    //_sharedState->getData().viewportObserver->reactToOffsetChange(scrollView.contentOffset.y);

}

- (void)prepareForRecycle
{
  _sharedState.reset();
  [super prepareForRecycle];
}

-(void)setBridge:(RCTBridge *)bridge
{
    // TODO here you can intercept uiManager by registering fake surface
  //bridge.surfacePresentsr
};

@end

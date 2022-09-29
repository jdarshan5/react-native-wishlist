#include "ItemProvider.hpp"
#include <react/renderer/uimanager/UIManager.h>
#include <react/renderer/uimanager/primitives.h>

// TODO(Szymon) render for the first time on UI Thread
// return dummy children on JS

struct 

WishItem WorkletItemProvider::provide(int index) {
    WishItem wishItem;
    
    jsi::Runtime &rt = *ReanimatedRuntimeHandler::rtPtr;
    
    jsi::Function inflateItem = rt.global().getPropertyAsObject(rt, "global").getPropertyAsObject(rt, "InflatorRegistry").getPropertyAsFunction(rt, "inflateItem");
    
    jsi::Value returnedValue = inflateItem.call(
        rt,
        jsi::String::createFromUtf8(rt, tag),
        jsi::Value(index),
        cp->prepareProxy(rt)
    );
    
    if (returnedValue.isUndefined()) {
        return wishItem;
    }
    
    std::shared_ptr<ShadowNodeBinding> shadowNodeWrapper = returnedValue.asObject(rt).getHostObject<ShadowNodeBinding>(rt);
    
    std::shared_ptr<const ShadowNode> sn = shadowNodeWrapper->sn;
    
    auto affected = std::vector<const LayoutableShadowNode *>();
    this->lc.affectedNodes = &affected;
    // better use layoutTree instead of measure (will be persistant)
    std::shared_ptr<YogaLayoutableShadowNode> ysn = std::static_pointer_cast<YogaLayoutableShadowNode>(sn->clone({}));
    facebook::react::Size sz = ysn->measure(this->lc, this->lcc);
    
    wishItem.sn = std::static_pointer_cast<ShadowNode>(ysn);
    wishItem.height = sz.height;
    wishItem.index = index;
    NSLog(@"BBB index %d", index);
    return wishItem;
}


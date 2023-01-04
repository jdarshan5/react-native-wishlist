
/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @generated by codegen project: GenerateShadowNodeH.js
 */

#pragma once

#include "ModuleEventEmitters.h"
#include "ModuleProps.h"
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include "LayoutContext.h"
#include "LayoutConstraints.h"
#include "ShadowNodeCopyMachine.h"
#include <iostream>
#include <memory>
#include "ModuleState.h"
#include "ReanimatedRuntimeHandler.hpp"

namespace facebook {
namespace react {

extern const char ModuleComponentName[];

/*
 * `ShadowNode` for <Module> component.
 */

class ModuleShadowNode : public ConcreteViewShadowNode<
                                ModuleComponentName,
                                ModuleProps,
                                ModuleEventEmitter,
                                ModuleState>, std::enable_shared_from_this<ModuleShadowNode> {
public:
    ModuleShadowNode(
        ShadowNodeFragment const &fragment,
        ShadowNodeFamily::Shared const &family,
        ShadowNodeTraits traits)
        : ConcreteViewShadowNode(fragment, family, traits) {
            int x = 0;
    }

    ModuleShadowNode(
        ShadowNode const &sourceShadowNode,
        ShadowNodeFragment const &fragment)
        : ConcreteViewShadowNode(sourceShadowNode, fragment) {
        try {
            const ModuleShadowNode &msn = dynamic_cast<const ModuleShadowNode&>(sourceShadowNode);
            registeredViews = msn.registeredViews;
            
        }
        catch (std::bad_cast) {
              
        }
    }
    
    void realAppendChild(ShadowNode::Shared const &childNode) {
        ConcreteViewShadowNode::appendChild(childNode);
    }
    
    void appendChild(ShadowNode::Shared const &childNode) {
        
        //ConcreteViewShadowNode::appendChild(childNode);
        /*std::shared_ptr<const LayoutableShadowNode> lsn = std::dynamic_pointer_cast<const LayoutableShadowNode>(childNode);
        LayoutContext lc;
        LayoutConstraints lcc;
        //lsn->layoutTree(lc);
        std::cout << "sdfwefwef" << std::endl;
        for (int i = 0; i < 10000; ++i) {
            Size sz = lsn->measure(lc, lcc);
            int x = 5;
        }
        
        std::cout << "2 sdfwefwef" << std::endl;*/
        auto state = getStateData();
        if (state.initialised) {
            return;
        }
        
        registeredViews.push_back(childNode);
        auto props = std::dynamic_pointer_cast<const ModuleProps>(this->getProps());
        if (props->names.size() == registeredViews.size()) { // last Child
            
            /*state.viewportObserver.initOrUpdate(this->getSurfaceId(), 5000, 20, 5000, 10, this->clone(ShadowNodeFragment{}));*/
        }
    }
                                    
    void layout(LayoutContext layoutContext) {
      // TODO probably the best place to initialize children in the future
        auto state = getStateData();
        if (!state.initialised) {
            state.initialised = true;
            
            // remove that flushing in the future
            // I know it's not always on UI (In our case it's fine)
            ReanimatedRuntimeHandler::scheduler->triggerUI();
            
            LayoutMetrics lm = getLayoutMetrics();
        
            
            state.viewportObserver->boot(getSurfaceId(),
                                              5000,
                                              lm.frame.size.height, lm.frame.size.width, 5000, 10, sharedThis, registeredViews, layoutContext,
                                                  std::static_pointer_cast<const ModuleProps>(getProps())->names);
            
            setStateData(std::move(state));
            
            auto layoutM = this->getLayoutMetrics();
            LayoutConstraints lcc = LayoutConstraints();
            lcc.minimumSize = lcc.maximumSize = layoutM.frame.size;
            lcc.layoutDirection = layoutM.layoutDirection;
            layoutTree(layoutContext, lcc);
            return;
        }
        // TODO update viewportObserver if needed
        
        ConcreteViewShadowNode::layout(layoutContext);
        
      //updateScrollContentOffsetIfNeeded();
        updateStateIfNeeded();
    }
                                    
    void updateStateIfNeeded() {
        ensureUnsealed();
    }

    
    virtual ~ModuleShadowNode(){}
    
    std::vector<std::shared_ptr<ShadowNode const>> registeredViews;
    std::weak_ptr<ModuleShadowNode> sharedThis;
};

} // namespace react
} // namespace facebook

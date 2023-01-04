//
//  ViewportObserver.hpp
//  MGWishList
//
//  Created by Szymon on 27/11/2021.
//

#ifndef ViewportObserver_hpp
#define ViewportObserver_hpp

#include <stdio.h>
#include "ItemProvider.hpp"
#include <deque>
#include <iostream>
// Temporary solution only for PoC
#include <react/renderer/uimanager/UIManager.h>

// TODO make use of pointFactor
struct ViewportObserver {
    float offset;
    float windowHeight;
    float windowWidth;
    int surfaceId;
    static thread_local bool isPushingChildren;
    
    std::shared_ptr<ComponentsPool> componentsPool = std::make_shared<ComponentsPool>();
    std::shared_ptr<ItemProvider> itemProvider;
    std::deque<WishItem> window;
    std::shared_ptr<ShadowNode> wishListNode;
    LayoutContext lc;
    
    void setInitialValues(std::shared_ptr<ShadowNode> wishListNode, LayoutContext lc) {
        this->wishListNode = wishListNode;
        this->lc = lc;
    }
    
    void boot(float offset, float windowHeight, float windowWidth, float originItemOffset, int originItem,
        std::vector<std::shared_ptr<ShadowNode const>> registeredViews,
        std::vector<std::string> names,
        std::string inflatorId) {
        
        std::cout << "aaa boot" << std::endl;
        
        componentsPool->registeredViews = registeredViews;
        componentsPool->setNames(names);
        
        itemProvider = std::static_pointer_cast<ItemProvider>(std::make_shared<WorkletItemProvider>(windowWidth, lc, inflatorId));
        itemProvider->setComponentsPool(componentsPool);
        
        for (WishItem & item : window) {
            componentsPool->returnToPool(item.sn);
        }
        window.clear();
        
        this->surfaceId = wishListNode->getFamily().getSurfaceId();
        this->offset = offset;
        this->windowHeight = windowHeight;
        
        window.push_back(itemProvider->provide(originItem));
        window.back().offset = originItemOffset;
        updateWindow(true);
    }
    
    // TODO: fix
    void update(float offset) {
    
        this->offset = offset;
        //window.push_back(itemProvider->provide(originItem));
        //window.back().offset = originItemOffset;
        //updateWindow(false);
    }
    
    void reactToOffsetChange(float offset) {
        this->offset = offset;
        updateWindow(false);
    }
    
    void updateWindow(bool newTemplates) {
        float topEdge = offset - windowHeight;
        float bottomEdge = offset + 2 * windowHeight;
        
        assert(window.size() != 0);
        
        // Add above
        while (1) {
            WishItem item = window.front();
            float bottom = item.offset + item.height;
            
            if (item.offset > topEdge) {
                WishItem wishItem = itemProvider->provide(item.index-1);
                if (wishItem.sn.get() == nullptr) {
                    break;
                }
                wishItem.offset = item.offset - wishItem.height;
                window.push_front(wishItem);
            } else {
                break;
            }
        }
        
        // Add below
        while (1) {
            WishItem item = window.back();
            float bottom = item.offset + item.height;

            if (bottom < bottomEdge) {
                WishItem wishItem = itemProvider->provide(item.index+1);
                if (wishItem.sn.get() == nullptr) {
                    break;
                }
                wishItem.offset = bottom;
                window.push_back(wishItem);
            } else {
                break;
            }
        }
        
        std::vector<WishItem> itemsToRemove;
        
        // remove above
        while (1) {
            WishItem item = window.front();
            float bottom = item.offset + item.height;
            if (bottom <= topEdge) {
                window.pop_front();
                itemsToRemove.push_back(item);
                continue;
            } else {
                break;
            }
        }
        
        // remove below
        while (1) {
            WishItem item = window.back();
            if (item.offset >= bottomEdge) {
                window.pop_back();
                itemsToRemove.push_back(item);
                continue;
            } else {
                break;
            }
        }
        
        pushChildren();
        
        for (auto & item : itemsToRemove) {
            componentsPool->returnToPool(item.sn);
        }
    }
    
    std::shared_ptr<ShadowNode> getOffseter(float offset);
    
    void pushChildren();
};

#endif /* ViewportObserver_hpp */

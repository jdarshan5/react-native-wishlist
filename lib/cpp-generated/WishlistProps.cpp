
/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *
 * @generated by codegen project: GeneratePropsCpp.js
 */

#include "WishlistProps.h"
#include <react/renderer/core/PropsParserContext.h>
#include <react/renderer/core/propsConversions.h>

namespace facebook {
namespace react {

WishlistProps::WishlistProps(
    const PropsParserContext &context,
    const WishlistProps &sourceProps,
    const RawProps &rawProps): ViewProps(context, sourceProps, rawProps),
    kkk(convertRawProp(context, rawProps, "kkk", sourceProps.kkk, 1)),
    reanimatedRuntime(std::reinterpret_cast<jsi::Runtime *>(convertRawProp(context, rawProps, "reanimatedRuntime", 0.0, 0.0))),
    inflatorId(convertRawProp(context, rawProps, "inflatorId", sourceProps.inflatorId, "__defaultId__")),
    names(convertRawProp(context, rawProps, "names", sourceProps.names, {}))
      {
      }

} // namespace react
} // namespace facebook

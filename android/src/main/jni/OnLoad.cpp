#include <fbjni/fbjni.h>

#include "WishlistComponentsRegistry.h"

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *) {
  return facebook::jni::initialize(vm, [] {
    facebook::react::WishlistComponentsRegistry::registerNatives();
  });
}
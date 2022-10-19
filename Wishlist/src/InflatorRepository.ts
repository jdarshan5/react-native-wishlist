export type TemplateItem = {
  [key: string]: TemplateItem | undefined;
} & {
  getByWishId: (id: string) => TemplateItem | undefined;
  addProps: (props: any) => void;
  addCallback: (callback: () => void) => void;
  describe: () => string;
};

export type ComponentPool = {
  getComponent: (id: string) => TemplateItem | undefined;
};

export type InflateMethod = (
  index: number,
  pool: ComponentPool,
) => [TemplateItem, any] | undefined;

export type MappingInflateMethod = (
  value: any,
  templateItem: TemplateItem,
) => void;

export type InflatorRegistryUI = {
  inflateItem: (
    id: string,
    index: number,
    pool: ComponentPool,
  ) => TemplateItem | undefined;
  registerInflator: (id: string, inflateMethod: InflateMethod) => void;
  unregisterInflator: (id: string) => void;
  registerMapping: (
    inflatorId: string,
    nativeId: string,
    inflateMethod: MappingInflateMethod,
  ) => void;
};

const runOnUI = (...args: any[]) => {
  const f = require('react-native-reanimated').runOnUI; //delay reanimated init
  return f(...args);
};

let done = false;
const maybeInit = () => {
  if (!done) {
    done = true;
    runOnUI(() => {
      'worklet';

      const registry = new Map<string, InflateMethod>();
      const mappings = new Map<string, Map<string, MappingInflateMethod>>();

      const InflatorRegistry: InflatorRegistryUI = {
        inflateItem: (id, index, pool) => {
          const inflator = registry.get(id);
          if (inflator) {
            const result = inflator(index, pool);
            if (!result) {
              return result;
            }
            const [item, value] = result;
            const mapping = mappings.get(id);
            if (mapping) {
              for (const [nativeId, inflate] of mapping.entries()) {
                const templateItem = item.getByWishId(nativeId);
                if (templateItem) {
                  inflate(value, templateItem);
                }
              }
            }
            return item;
          } else {
            console.log('Inflator not found for id: ' + id);
            return undefined;
          }
        },
        registerInflator: (id, inflateMethod) => {
          console.log('InflatorRegistry::register', id);
          registry.set(id, inflateMethod);
        },
        unregisterInflator: id => {
          console.log('InflatorRegistry::unregister', id); // TODO(Szymon) It should be done on UI Thread as it may be still in use
          registry.delete(id);
          mappings.delete(id);
        },
        registerMapping: (
          inflatorId: string,
          nativeId: string,
          inflateMethod,
        ) => {
          console.log(
            'InflatorRegistry::registerMapping',
            inflatorId,
            nativeId,
            inflateMethod,
          );
          const mapping = mappings.get(inflatorId) ?? new Map();
          mapping.set(nativeId, inflateMethod);
          mappings.set(inflatorId, mapping);
        },
      };
      global.InflatorRegistry = InflatorRegistry;

      console.log('InflatorRegister initialized');
    })();
  }
};

export default class InflatorRepository {
  static register(id: string, inflateMethod: InflateMethod) {
    maybeInit();
    runOnUI(() => {
      'worklet';
      global.InflatorRegistry.registerInflator(id, inflateMethod);
    })();
  }

  static unregister(id: string) {
    maybeInit();
    runOnUI(() => {
      'worklet';
      global.InflatorRegistry.unregisterInflator(id);
    })();
  }

  static registerMapping(
    inflatorId: string,
    nativeId: string,
    inflateMethod: MappingInflateMethod,
  ) {
    maybeInit();
    runOnUI(() => {
      'worklet';
      global.InflatorRegistry.registerMapping(
        inflatorId,
        nativeId,
        inflateMethod,
      );
    })();
  }
}

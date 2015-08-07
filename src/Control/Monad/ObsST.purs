module Control.Monad.ObsST where

import Control.Monad.Eff

foreign import data ObsC :: * -> *
foreign import data ObsST :: * -> !
foreign import data ObsSTRef :: * -> * -> *

foreign import runObs "\
  \ function runObs(f) { \
  \   var context = { \
  \     handlers: [], \
  \     change: function () { \
  \       this.handlers.forEach(function (handler) { \
  \         handler(); \
  \       }); \
  \     } \
  \   }; \
  \   return f(context); \
  \ }" :: forall a c r. (ObsC c -> Eff (st :: ObsST c | r) a) -> Eff r a

foreign import onChange "\
  \ function onChange(context) { \
  \   return function(handler) { \
  \     return function() { \
  \       context.handlers.push(handler); \
  \     }; \
  \   }; \
  \ }" :: forall c r r2 a. ObsC c -> Eff (st :: ObsST c | r2) a -> Eff (st :: ObsST c | r) Unit

foreign import newObsSTRef "\
  \ function newObsSTRef(context) { \
  \   return function(val) { \
  \     return function() { \
  \       return { value: val, context: context }; \
  \     }; \
  \   }; \
  \ }" :: forall a c r. ObsC c -> a -> Eff (st :: ObsST c | r) (ObsSTRef c a)

foreign import readObsSTRef "\
  \ function readObsSTRef(ref) { \
  \   return function() { \
  \     return ref.value; \
  \   }; \
  \ }" :: forall a c r. ObsSTRef c a -> Eff (st :: ObsST c | r) a

foreign import modifyObsSTRef "\
  \ function modifyObsSTRef(ref) {\
  \   return function(f) { \
  \     return function() { \
  \       ref.value = f(ref.value); \
  \       ref.context.change(); \
  \       return ref.value; \
  \     }; \
  \   }; \
  \ }" :: forall a c r. ObsSTRef c a -> (a -> a) -> Eff (st :: ObsST c | r) a

foreign import writeObsSTRef "\
  \ function writeObsSTRef(ref) { \
  \   return function(a) { \
  \     return function() { \
  \       ref.value = a; \
  \       ref.context.change(); \
  \       return ref.value; \
  \     }; \
  \   }; \
  \ }" :: forall a c r. ObsSTRef c a -> a -> Eff (st :: ObsST c | r) a


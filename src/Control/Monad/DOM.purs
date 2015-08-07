module Control.Monad.DOM(
    IntervalId(),
    RequestAnimationFrameId(),
    body,
    appendChild,
    addEventListener,
    setInterval,
    clearInterval,
    requestAnimationFrame,
    cancelAnimationFrame
  ) where
    
import DOM
import Control.Monad.Eff

foreign import data IntervalId :: *
foreign import data RequestAnimationFrameId :: *

foreign import body
  "function body() {\
  \  return document.body;\
  \}" :: forall eff. Eff (dom :: DOM | eff) Node

foreign import appendChild
  "function appendChild(child) {\
  \  return function(node) {\
  \    return function() {\
  \      node.appendChild(child);\
  \      return child;\
  \    };\
  \  };\
  \}" :: forall eff. Node -> Node -> Eff (dom :: DOM | eff) Node

foreign import addEventListener
  "function addEventListener(name) {\
  \  return function(handler) {\
  \    return function(node) {\
  \      return function() {\
  \        node.addEventListener(name, function(e) {\
  \          handler();\
  \          e.preventDefault();\
  \        });\
  \      };\
  \    };\
  \  };\
  \}" :: forall eff. String -> Eff (dom :: DOM | eff) Unit -> Node -> Eff (dom :: DOM | eff) Unit 

foreign import setInterval
  "function setInterval(interval) {\
  \  return function(handler) {\
  \    return function() {\
  \      return global.setInterval(handler, interval);\
  \    };\
  \  };\
  \}" :: forall eff. Number -> Eff (dom :: DOM | eff) Unit -> Eff (dom :: DOM | eff) IntervalId

foreign import clearInterval
  "function clearInterval(interval) {\
  \  return function() {\
  \    return global.clearInterval(interval);\
  \  };\
  \}" :: forall eff. IntervalId -> Eff (dom :: DOM | eff) IntervalId

foreign import requestAnimationFrame
  "function requestAnimationFrame(handler) {\
  \  return function() {\
  \    return global.requestAnimationFrame(handler);\
  \  };\
  \}" :: forall eff. Eff (dom :: DOM | eff) Unit -> Eff (dom :: DOM | eff) RequestAnimationFrameId

foreign import cancelAnimationFrame
  "function cancelAnimationFrame(handler) {\
  \  return function() {\
  \    return global.cancelAnimationFrame(handler);\
  \  };\
  \}" :: forall eff. RequestAnimationFrameId -> Eff (dom :: DOM | eff) RequestAnimationFrameId


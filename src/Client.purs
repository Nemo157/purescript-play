module Client where

import DOM(DOM())
import Control.Monad.Eff
import Control.Monad.ObsST
import Control.Monad.DOM

import Elements.Free
import Elements.Nodes

import App(runApp)

hello :: { name :: String } -> Node
hello props = h1 do
  text "Hello, "
  text props.name

newCounter :: forall eff1 eff2 c. ObsC c -> Eff(st :: ObsST c, dom :: DOM | eff1) (Eff(st :: ObsST c | eff2) Node)
newCounter obsC = do
  state <- newObsSTRef obsC { count: 0 }
  setInterval 1000 do
    current <- modifyObsSTRef state (\state -> { count: state.count + 1 })
    return unit
  return do
    current <- readObsSTRef state
    return $ p do
      text (show current.count)
      text " Seconds"

newButton :: forall eff1 a. Eff(| eff1) a -> Node
newButton onClick = button { onclick: onClick } do
  text "Click me"

newClicker obsC = do
  state <- newObsSTRef obsC { clicked: 0 }
  let button = newButton $ modifyObsSTRef state (\s -> { clicked: s.clicked + 1 })
  return do
    current <- readObsSTRef state
    return $ div do
      button
      span do
        text "Clicked the button "
        text (show current.clicked)
        text " times"

app obsC = do
  counter <- newCounter obsC
  clicker <- newClicker obsC
  return do
    counter <- counter
    clicker <- clicker
    return $ div do
      hello { name: "World" }
      counter
      clicker

main = do
  runApp app

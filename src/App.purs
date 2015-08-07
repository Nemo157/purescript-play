module App where

import DOM(DOM())
import Control.Monad.Eff(Eff())
import Control.Monad.DOM(body, appendChild, requestAnimationFrame)
import Control.Monad.ObsST(ObsC(), ObsST(), runObs, onChange)
import VirtualDOM(patch)
import Elements.Free(Content())
import Elements.VirtualDOM(createElement, diff)

type Root eff = Eff (eff) (Content Unit)
type RunRoot eff c = Eff(st :: ObsST c | eff) (Root(st :: ObsST c | eff))
type CreateRoot eff c = ObsC c -> RunRoot eff c

runApp :: forall c.  CreateRoot(dom :: DOM) c -> Eff (dom :: DOM) Unit
runApp createRoot = do
  runObs \obsC -> (do
    root <- createRoot obsC
    tree <- root
    body <- body
    rootNode <- appendChild (createElement tree) body
    onChange obsC $ requestAnimationFrame (animate rootNode root tree)
    return unit)
  return unit
  where
    animate rootNode root oldTree = do
      newTree <- root
      rootNode <- patch (diff oldTree newTree) rootNode
      return unit


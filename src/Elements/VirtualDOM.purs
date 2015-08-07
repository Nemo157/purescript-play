module Elements.VirtualDOM where

import Elements.Free
import VirtualDOM(PatchObject())
import VirtualDOM.VTree(VTree(), vnode, vtext)

import Data.Maybe
import Data.Array (head, map)
import Data.Foldable (for_)

import Control.Monad.Free
import Control.Monad.Writer
import Control.Monad.Writer.Class

createElement :: Node -> DOM.Node
createElement node = VirtualDOM.createElement $ render node

diff :: Node -> Node -> PatchObject
diff first second = VirtualDOM.diff (render first) (render second)

render :: Node -> VTree
render (Content content) =
  case head $ execWriter $ iterM renderContentItem content of
   (Just tree) -> tree

  where
  renderElement :: Element -> VTree
  renderElement (Element e) =
    vnode e.name (unprops e.props) (execWriter $ renderContent e.content) Nothing Nothing

  renderContent :: Maybe (Node) -> Writer [VTree] Unit
  renderContent (Just (Content content)) = do
    iterM renderContentItem content

  renderContentItem :: forall a. ContentF (Writer [VTree] a) -> Writer [VTree] a
  renderContentItem (TextContent s rest) = do
    tell $ [vtext s]
    rest
  renderContentItem (ElementContent e rest) = do
    tell $ [renderElement e]
    rest


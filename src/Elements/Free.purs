module Elements.Free where

import Data.Maybe
import Data.Array (head, map)
import Data.Foldable (for_)

import Control.Monad.Free
import Control.Monad.Writer
import Control.Monad.Writer.Class

foreign import data Properties :: *

newtype Element = Element
  { name         :: String
  , props        :: Properties
  , content      :: Maybe (Node)
  }

data ContentF a
  = TextContent String a
  | ElementContent Element a

instance functorContentF :: Functor ContentF where
  (<$>) f (TextContent s a) = TextContent s (f a)
  (<$>) f (ElementContent e a) = ElementContent e (f a)

newtype Content a = Content (Free ContentF a)

runContent :: forall a. Content a -> Free ContentF a
runContent (Content x) = x

instance functorContent :: Functor Content where
  (<$>) f (Content x) = Content (f <$> x)

instance applyContent :: Apply Content where
  (<*>) (Content f) (Content x) = Content (f <*> x)

instance applicativeContent :: Applicative Content where
  pure = Content <<< pure

instance bindContent :: Bind Content where
  (>>=) (Content x) f = Content (x >>= (runContent <<< f))

instance monadContent :: Monad Content

foreign import props "function props(p) { return p; }" :: forall p. { | p } -> Properties
foreign import unprops "function unprops(p) { return p; }" :: forall p. Properties -> { | p }

element :: forall p. String -> { | p }-> Maybe (Node) -> Node
element name p content = Content $ liftF $ ElementContent (Element {
    name: name,
    props: (props p),
    content: content
  }) unit

type Node = Content Unit

text :: String -> Node
text s = Content $ liftF $ TextContent s unit

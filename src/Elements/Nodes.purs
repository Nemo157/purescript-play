module Elements.Nodes where

import Data.Maybe(Maybe(Just))
import Elements.Free(Node(), element)

button p content = element "button" p (Just content)
h1 content = element "h1" {} (Just content)
div content = element "div" {} (Just content)
span content = element "span" {} (Just content)
p content = element "p" {} (Just content)

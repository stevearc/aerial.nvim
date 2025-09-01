module HaskellTest where

data Data_1 = Foo | Bar Int

newtype NewType = NewType {newType :: Int}

type TypeAlias_1 = (Int, Bool)

func :: Int -> ()
func x = ()

func_2 = id

class MyClass where
  classFn :: () -> ()

instance MyClass Data_1 where
  classFn = id

#!/bin/bash

# https://github.com/Carthage/Carthage/issues/3003
# brew uninstall --force carthage
# brew install https://github.com/Homebrew/homebrew-core/raw/09ceff6c1de7ebbfedb42c0941a48bfdca932c0f/Formula/carthage.rb
# brew unlink carthage
# brew install https://github.com/Homebrew/homebrew-core/raw/a1222d4ca1e3b81374df2d7620f8d47503f6a8f2/Formula/carthage.rb

brew uninstall --force carthage

git clone https://github.com/Carthage/Carthage.git

cd Carthage

git checkout c7550f832f23d2c00bf0c014351719839593c641

make install

cd ..

#brew extract --version=0.34.0 carthage carthage/custom
#brew install carthage@0.34.0

carthage version

carthage bootstrap --platform iOS

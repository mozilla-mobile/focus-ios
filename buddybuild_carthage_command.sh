#!/bin/bash

# https://github.com/Carthage/Carthage/issues/3003
brew uninstall --force carthage
brew install https://github.com/Homebrew/homebrew-core/raw/09ceff6c1de7ebbfedb42c0941a48bfdca932c0f/Formula/carthage.rb

carthage version

carthage bootstrap --platform iOS

#!/bin/bash

# https://github.com/Carthage/Carthage/issues/3003
#brew uninstall --force carthage
#git clone https://github.com/Carthage/Carthage.git
#cd Carthage
#git checkout 25ad8c8ed71afe218aed9a7f7631543ce8adf858
#make install
#cd ..

# https://github.com/Carthage/Carthage/issues/3003
brew uninstall --force carthage
wget https://github.com/Carthage/Carthage/releases/download/0.34.0/Carthage.pkg
installer -pkg Carthage.pkg -target CurrentUserHomeDirectory
cd /usr/local/bin && ln -s ~/usr/local/bin/carthage .

carthage version

carthage bootstrap --platform iOS

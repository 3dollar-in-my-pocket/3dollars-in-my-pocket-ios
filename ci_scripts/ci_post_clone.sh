#!/bin/sh

#  ci_post_clone.sh
#  3dollar-in-my-pocket
#
#  Created by Hyun Sik Yoo on 2022/12/29.
#  Copyright © 2022 Macgongmon. All rights reserved.

brew update
brew install rbenv ruby-build
rbenv install -l
rbenv install 3.1.3
rbenv global 3.1.3

echo ">>> SETUP LOCAL GEM PATH"
echo 'export GEM_HOME=$HOME/gems' >>~/.bash_profile
echo 'export PATH=$HOME/gems/bin:$PATH' >>~/.bash_profile
export GEM_HOME=$HOME/gems
export PATH="$GEM_HOME/bin:$PATH"

gem install bundler:2.3.26
bundle install

# Install Tuist
../.tuist-bin/tuist fetch -p ../
../.tuist-bin/tuist generate -n -p ../

# Install dependencies you manage with CocoaPods.
bundle exec pod install

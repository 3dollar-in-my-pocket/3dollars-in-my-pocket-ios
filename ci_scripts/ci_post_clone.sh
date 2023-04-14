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
rbenv versions

gem install bundler
bundle install
brew install git-lfs

git lfs install --skip-smudge
git lfs pull
git lfs install --force

bundle exec pod cache clean NMapsMap

# Install dependencies you manage with CocoaPods.
bundle exec pod install --repo-update

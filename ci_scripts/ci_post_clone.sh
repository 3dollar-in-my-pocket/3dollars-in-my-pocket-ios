#!/bin/sh

#  ci_post_clone.sh
#  3dollar-in-my-pocket
#
#  Created by Hyun Sik Yoo on 2022/12/29.
#  Copyright © 2022 Macgongmon. All rights reserved.

# Install CocoaPods using Homebrew.
brew update
brew install cocoapods
brew install git-lfs

git lfs pull
git lfs install

# Install dependencies you manage with CocoaPods.
pod install

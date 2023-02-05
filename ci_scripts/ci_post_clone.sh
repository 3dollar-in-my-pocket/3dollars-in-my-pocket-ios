#!/bin/sh

#  ci_post_clone.sh
#  3dollar-in-my-pocket
#
#  Created by Hyun Sik Yoo on 2022/12/29.
#  Copyright © 2022 Macgongmon. All rights reserved.

# Install CocoaPods using Homebrew.
brew install git-lfs
brew install cocoapods

git lfs install

pod cache clean NMapsMap

# Install dependencies you manage with CocoaPods.
pod install --repo-update

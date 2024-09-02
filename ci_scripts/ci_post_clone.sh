#!/bin/sh

#  ci_post_clone.sh
#  3dollar-in-my-pocket
#
#  Created by Hyun Sik Yoo on 2022/12/29.
#  Copyright © 2022 Macgongmon. All rights reserved.

# Install Tuist
../.tuist-bin/tuist fetch -p ../
../.tuist-bin/tuist generate -n -p ../

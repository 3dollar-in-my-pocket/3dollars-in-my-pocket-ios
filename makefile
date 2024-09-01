install:
	bundle install

project:
	./.tuist-bin/tuist fetch
	./.tuist-bin/tuist generate -n
	open 3dollar-in-my-pocket.xcworkspace

edit:
	./.tuist-bin/tuist edit

clean:
	./.tuist-bin/tuist clean
	./.tuist-bin/tuist clean dependencies
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace
	rm -rf *.xcodeproj

install:
	bundle install

project:
	./.tuist-bin/tuist fetch
	./.tuist-bin/tuist generate -n
	bundle exec pod install
	open 3dollar-in-my-pocket.xcworkspace

edit:
	./.tuist-bin/tuist edit

clean:
	./.tuist-bin/tuist clean
	bundle exec pod cache clean --all
	bundle exec pod deintegrate App/3dollar-in-my-pocket.xcodeproj
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace
	rm -rf *.xcodeproj

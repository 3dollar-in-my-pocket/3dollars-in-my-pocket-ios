install:
	bundle install

project:
	tuist install
	tuist generate
	open 3dollar-in-my-pocket.xcworkspace

edit:
	tuist edit

clean:
	tuist clean
	tuist clean dependencies
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace
	rm -rf *.xcodeproj

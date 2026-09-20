install:
	bundle install

project:
	mise install
	mise exec -- tuist install
	mise exec -- tuist generate
	open 3dollar-in-my-pocket.xcworkspace

edit:
	mise exec -- tuist edit

clean:
	mise exec -- tuist clean
	mise exec -- tuist clean dependencies
	rm -rf **/*.xcodeproj
	rm -rf *.xcworkspace
	rm -rf *.xcodeproj

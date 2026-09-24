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

lint:
	swiftlint lint --quiet
	scripts/check-module-deps.sh

lint-fix:
	swiftlint --fix --quiet

# baseline: 키가 가리키는 파일이 없으면 SwiftLint가 먼저 실패하므로 키를 뺀 임시 설정으로 생성한다
lint-baseline:
	sed '/^baseline:/d' .swiftlint.yml > .swiftlint.tmp.yml
	swiftlint lint --quiet --config .swiftlint.tmp.yml --write-baseline .swiftlint-baseline.json || true
	rm -f .swiftlint.tmp.yml

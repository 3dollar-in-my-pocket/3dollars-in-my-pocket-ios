fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios certificates_setup

```sh
[bundle exec] fastlane ios certificates_setup
```

[관리자 전용] 인증서/프로파일을 신규 생성하여 git에 암호화 저장 (Apple ID + 2FA 필요)

### ios certificates_sync

```sh
[bundle exec] fastlane ios certificates_sync
```

[팀원용] 인증서/프로파일 동기화 (읽기 전용, Apple ID/2FA 불필요 — repo 권한 + passphrase만 필요)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

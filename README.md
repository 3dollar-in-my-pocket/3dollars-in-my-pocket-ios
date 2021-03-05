![KakaoTalk_Photo_2021-03-05-13-10-26](https://user-images.githubusercontent.com/7058293/110066182-30213500-7db4-11eb-881e-fa3ea0537b7a.png)
### 설명
🐟**가슴속 3천원**🐟은 전국 붕어빵 지도로 시작하여 전국 길거리 음식점 정복을 꿈꾸는 프로젝트입니다. **디프만**(디자이너와 프로그래머가 만났을 때) 7기 파이널 프로젝트에서 개발되었으며 이후에 지속적으로 업데이트하고있습니다.

### 인증샷🎉
![appStore](https://user-images.githubusercontent.com/7058293/110067262-b179c700-7db6-11eb-8451-223956dca69d.jpg)

### 외부 인터뷰
- [14F 인터뷰 영상](https://www.youtube.com/watch?v=KUZHQpH0M_E)
- [스파르타 코딩클럽 리개때 영상](https://youtu.be/v_uhNhJL2g8)
- [이데일리 인터뷰 기사](https://news.naver.com/main/read.nhn?mode=LSD&mid=sec&sid1=102&oid=018&aid=0004791608)
- [헤이버니 인터뷰 기사](https://heybunny.io/blog/?q=YToxOntzOjEyOiJrZXl3b3JkX3R5cGUiO3M6MzoiYWxsIjt9&bmode=view&idx=5770611&t=board)
- [jobsN 인터뷰 기사](https://post.naver.com/viewer/postView.nhn?volumeNo=30131742&memberNo=27908841&vType=VERTICAL)

### 아키텍처 및 디자인 패턴
- RxSwift + MVVM 사용
- Code base로 UI 구현 (SnapKit 사용)
- Feature별 디렉토리 구성 (실제 앱 화면 접근 플로우와 동일하게 디렉토리 구성)

### Git-flow 전략 사용
- https://danielkummer.github.io/git-flow-cheatsheet/index.ko_KR.html
- 코드 리뷰는 진행하고있지 않습니다. (iOS 개발자가 1명이라 아쉽습니다..)
- Swift Lint로 조금이나마 스스로 리뷰를 진행해볼까 합니다. 😭

### Code style guide
- StyleShare에서 정의한 [Code style guide](https://github.com/StyleShare/swift-style-guide)를 따릅니다. (너무 잘 만들어주신 것 같아요..🙇‍♂️)
- 가이드에 적혀있는대로 가이드에서 정의되지 않은 규칙은 [Swift API design guide](https://swift.org/documentation/api-design-guidelines/)를 따릅니다.

### 리소스 관리
- 문자열의 경우에는 Google spread sheet로 관리중입니다.
- 해당 시트에서 key, value에 맞게 문자열을 만들고 Xcode프로젝트에서 빌드버튼을 누르면 자동으로 문자열이 생성됩니다.
- 리소스 시스템 관련해서 [let us go 2020 fall](https://let-us-go-2020-fall.vercel.app/)에서 발표를 진행했습니다.

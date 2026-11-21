# DESIGN.md — 가슴속 3천원 iOS 디자인 시스템

AI 에이전트와 개발자가 UI 코드를 작성할 때 읽는 문서입니다. 시각 원본은 피그마이고, 이 문서는 그 내용을 코드 이름과 함께 옮긴 사본입니다.

- 피그마: [Design System](https://www.figma.com/design/DU3txoMhj2wCjW9xkkyyMP) — `Foundation`(ㄴ Color · ㄴ Typography · ㄴ Icons), `Component`, `Module` 페이지
- 코드: `Modules/Core/DesignSystem` (`Resources/Colors.xcassets`, `Resources/Icons.xcassets`, `Resources/Fonts`, `Sources/`)
- 피그마와 이 문서가 다르면 피그마가 맞습니다. 이 문서를 고치고, 코드도 피그마에 맞춥니다.

## 규칙

1. 색은 `DesignSystemAsset.Colors`, 폰트는 `DesignSystemFontFamily.Pretendard`, 아이콘은 `DesignSystemAsset.Icons`만 씁니다. 모듈 안에서는 `Environment.swift`의 별칭 `Colors` · `Fonts` · `Icons`를 씁니다.
2. hex 값이나 `UIColor(red:green:blue:)`를 새로 쓰지 않습니다. 필요한 색이 없으면 토큰을 먼저 추가하자고 제안합니다.
3. 텍스트는 아래 [타이포그래피](#타이포그래피) 표에 있는 조합만 씁니다. 표에 없는 크기·굵기가 시안에 있으면 디자이너에게 확인합니다.
4. 서버가 내려주는 화면 섹션(SDU)의 색·문구는 서버 값을 그대로 렌더링합니다. 클라이언트가 임의로 덮어쓰지 않습니다.

## 색

피그마 Paint Style과 iOS 컬러 에셋은 27개 모두 이름·값이 같습니다(2026-11-16 확인). 아직 피그마 Variables(의미 토큰)는 없습니다.

| 피그마 | iOS (`Colors.`) | 값 | 현재 코드에서 주로 쓰는 곳 |
|---|---|---|---|
| main/pink | `mainPink` | #FF8181 | 대표 색. 기본 버튼 배경(`Button` Primary), 강조 글자, 선택 테두리 |
| main/red | `mainRed` | #FF5C43 | 강조 배경·글자, `Button` Destructive 배경 |
| main/green | `mainGreen` | #00C667 | 사용 적음 (15곳) |
| system/white | `systemWhite` | #FFFFFF | 화면·카드 배경, 진한 배경 위 글자 |
| system/black | `systemBlack` | #000000 | 거의 안 씀 (`gray100` 우선) |
| gray/0 | `gray0` | #FAFAFA | 옅은 영역 배경 |
| gray/10 | `gray10` | #F4F4F4 | 입력창·칩·구분 영역 배경 |
| gray/20 | `gray20` | #E2E2E2 | 구분선·테두리 |
| gray/30 | `gray30` | #D0D0D0 | 테두리, 비활성 버튼 배경 |
| gray/40 | `gray40` | #B7B7B7 | 플레이스홀더·비활성 글자 |
| gray/50 | `gray50` | #969696 | 보조 글자 (3차) |
| gray/60 | `gray60` | #787878 | 보조 글자 (2차) |
| gray/70 | `gray70` | #5A5A5A | 보조 글자 (1차) |
| gray/80 | `gray80` | #2E2E2E | 진한 글자, 다크 영역 배경 |
| gray/90 | `gray90` | #232323 | 다크 영역 배경 |
| gray/95 | `gray95` | #181818 | 토스트 배경 |
| gray/100 | `gray100` | #0F0F0F | 기본 글자 색 |
| pink/100 ~ 500 | `pink100` ~ `pink500` | #FFEFEF · #FFD9D5 · #FFB1AD · #F57575 · #E96060 | `pink100`은 연한 강조 배경, 나머지는 사용 적음 |
| green/100 ~ 500 | `green100` ~ `green500` | #F1FFF8 · #99E8C2 · #4DD794 · #00A455 · #00753D | 거의 안 씀 |

"주로 쓰는 곳"은 디자이너가 정한 규칙이 아니라 현재 코드 사용 빈도에서 뽑은 관찰입니다. 디자이너 확인 후 "사용 규칙"으로 바꿉니다.

**토큰 밖 하드코딩 (정리 대상)**
- `TooltipView`: `UIColor(red: 35/255, green: 36/255, blue: 42/255)` = #23242A (`gray90` #232323과 거의 같음)
- `#BC4BD6`(4곳), `#FFA1AA`(2곳), `#F7E317` · `#381E1F`(카카오 브랜드 색, 유지)

## 타이포그래피

폰트는 Pretendard 4종(Regular · Medium · SemiBold · Bold)만 번들에 있습니다. 피그마 텍스트 스타일은 모두 자간 -1%입니다.

| 피그마 스타일 | iOS 호출 | 행간 | 코드 사용 수 |
|---|---|---|---|
| 30/bold | `Fonts.bold.font(size: 30)` | 42 | 11 |
| 30/regular | `Fonts.regular.font(size: 30)` | 42 | 3 |
| 24/bold | `Fonts.bold.font(size: 24)` | 32 | 20 |
| 24/regular | `Fonts.regular.font(size: 24)` | 32 | 0 |
| 20/semi-bold | `Fonts.semiBold.font(size: 20)` | 28 | 25 |
| 16/bold | `Fonts.bold.font(size: 16)` | 24 | 82 |
| 16/medium ⚠️ | `Fonts.medium.font(size: 16)` | 24 | 31 |
| 14/semi-bold | `Fonts.semiBold.font(size: 14)` | 20 | 88 |
| 14/regular | `Fonts.regular.font(size: 14)` | 20 | 85 |
| 12/bold | `Fonts.bold.font(size: 12)` | 18 | 39 |
| 12/medium | `Fonts.medium.font(size: 12)` | 18 | 138 |
| 10/medium | `Fonts.medium.font(size: 10)` | 14 | 20 |

⚠️ 피그마 `16/medium` 스타일의 실제 폰트가 Pretendard **Regular**로 지정돼 있습니다. 이름(medium)과 코드(medium)가 맞는지, 폰트 지정이 맞는지 디자이너 확인이 필요합니다.

**행간·자간**: iOS는 대부분 폰트만 지정하고 행간·자간을 적용하지 않습니다(행간 적용 파일 약 10개). 여러 줄 텍스트는 `UILabel.setLineHeight(lineHeight:)`로 위 표의 행간을 맞춥니다.

**피그마에 없는 조합 (정리 대상)**: semiBold 16(14곳), bold 14(7), regular 12(8), medium 13(6), regular 16(5), bold 18(4), medium 15(3), medium 11(3)

## 모서리 · 간격

피그마에 radius·간격 토큰이 아직 없습니다. 현재 코드의 `cornerRadius` 사용 분포는 12(75) · 16(37) · 8(35) · 20(20) · 10(17) · 4(16) · 24(5) · 18(4) · 2(4)입니다. 토큰을 정하기 전까지는 시안 값을 그대로 쓰되, 가능하면 4 · 8 · 12 · 16 · 20 · 24 중에서 고릅니다.

## 아이콘

- 피그마 원본 프레임은 30, 코드에서 쓰는 크기는 화면마다 다릅니다(버튼 안 24·16). 색은 `withRenderingMode(.alwaysTemplate)` + `tintColor`로 입힙니다.
- 원본은 피그마 `ㄴ Icons` 페이지의 `Icon` 프레임입니다.

**이름 규칙 (피그마 기준)**
- 에셋 이름 = 피그마 컴포넌트 이름. 소문자 `snake_case`, 형태 접미어는 `_line` · `_solid`. 예: 피그마 `bookmark_line` = iOS `bookmark_line.imageset` → 코드 `Icons.bookmarkLine.image`
- 상태가 있는 컴포넌트 세트는 `<세트 이름>_<값>`. 예: 피그마 `mappin_focused` (State=on/off) → iOS `mappin_focused_on` · `mappin_focused_off`
- 방향 아이콘은 모양대로 `chevron_*`(꺾쇠) · `arrow_*`(화살표), 닫기는 `close`입니다.
- 새 아이콘은 피그마에 먼저 같은 이름으로 만들고 iOS에 추가합니다.

**피그마와 아직 다른 것** (2026-11-16)
- 피그마에만: `chevron_up`, `arrow_up`, `mappin_fire`, `coupon_solid`, `check_circle`, `filter`, `edit_fill`, `Iconly/Sharp/Bold/Location`, `Iconly/Sharp/Bold/Arrow - Right 2`
- iOS에만: `badge`, `camera_colored`, `check_verified`, `delete_photo`, `image_add`
- 피그마 `category` 프레임(카테고리 아이콘·지도 핀)은 Figma 플러그인으로 관리하며 이 문서 범위 밖입니다.

**일러스트** (피그마 `ㄴ Illustrations`): 빈 화면 붕어빵은 `bungeoppang_default`(옛 `empty_02`), 우울한 얼굴은 `face_gloomy`(옛 `empty_100`)입니다.

## 컴포넌트

현재 `DesignSystem` 모듈에 있는 것:

| 컴포넌트 | 위치 | 규격 |
|---|---|---|
| `Button.Normal` | `Sources/Button.swift` | 피그마 `Button`. `size:` `.medium` 48 · `.small` 34, `style:` `.primary`(`mainPink`·흰 글자) · `.secondary`(`gray10`·`gray70` 글자) · `.destructive`(`mainRed`·흰 글자). 비활성(`isEnabled = false`)은 스타일과 관계없이 배경 `gray30`·흰 글자. medium = 모서리 12 · 좌우 여백 12 · semiBold 14 · 아이콘 24, small = 모서리 10 · 좌우 여백 10 · bold 12 · 아이콘 16. 아이콘-글자 간격 4, `icon` + `iconPlacement`(`.leading`/`.trailing`)로 한쪽에만. 너비는 medium은 화면이 정하고 small은 글자 길이에 맞춤 |
| `ToastView` / `ToastManager` | `Sources/Manager/Toast/` | 배경 `gray95`, radius 10, 글자 medium 14 흰색 |
| `TooltipView` | `Sources/TooltipView.swift` | 배경 #23242A(토큰 아님), radius 8, 제목 bold 16 · 본문 regular 14 |
| `StarBadgeView` | `Sources/StarBadgeView.swift` | 별점 배지, radius 4, 별 `mainPink`/`gray70` |
| `PaddingLabel` | `Sources/PaddingLabel.swift` | 안쪽 여백 있는 라벨 |
| `LoadingManager` · `DimManager` | `Sources/Manager/` | 로딩(Lottie) · 딤 |

피그마 `Component` 하위 페이지 16개와 iOS 현재 위치입니다. `DesignSystem` 모듈에 없는 것은 화면마다 직접 그리고 있습니다.

| 피그마 | 피그마 규격 | iOS 현재 위치 |
|---|---|---|
| Button | Style(Primary · Secondary · Destructive) × Size(Medium 48 · Small 34) × State(Enabled · Disabled). Medium 모서리 12, Small 모서리 10 | `Button.Normal`. 화면 아래 꽉 찬 버튼(높이 64)은 BottomCTA라 해당 없음 |
| Toast | 배경 gray/95, radius 10, 글자 14 흰색 | `ToastView` |
| Rating | 별 5개, 68×20 | `StarBadgeView` |
| Header | 제목 bold 24 + 서브타이틀 bold 16 gray/40 + 설명 14 gray/80 | 제보 단계 화면(`WriteDetailMenuViewController` 등)에서 직접 |
| SearchField | 높이 50 | `SearchAddressView` (모서리 9 — Android는 12, 피그마 값 확인 필요) |
| Bottom (하단 탭) | 탭 항목 규칙: 홈 · 가게 제보 · 커뮤니티 · 마이페이지, 아이콘 24 + 라벨 12 medium, 선택 `mainRed` · 미선택 `gray40`, My 탭 배경 `gray100` | 시스템 탭바(`MainTabBarViewController`)에 색·아이콘만 적용. 탭바 모양은 OS가 그림 |
| Tabs | Width 속성: Fill = 같은 폭, Hug = 글자 길이에 맞춤(넘치면 가로 스크롤). 선택 밑줄 2 | Fill: `CouponTabView` · `CommunityTabView` · `MyPageTabView` / Hug: `StoreTabCell`(가게 상세) · `MenuCategoryTabView`(가게 제보 메뉴) |
| Chip · Badge · SelectRow · TextField · HandleBar · ProgressBar · Top · BottomCTA · IconButton · FAB | 피그마 각 페이지 참고 | 화면마다 직접 |

- 홈 인디케이터(Home bar)·상태바·키보드·스위치는 시스템 요소라 디자인 시스템에 넣지 않습니다.

## 모듈

서버가 섹션 단위로 내려주는 화면 조각입니다. 피그마 `Module` 하위 페이지에 기능별로 나뉘어 있고, 이름은 서버 타입 키입니다.

| 피그마 페이지 | 모듈 |
|---|---|
| 가게 정보 | PREVIEW · INFO_V1 · INFO_V2 · APPEARANCE_DAY · EDIT · IMAGE |
| 리뷰·방문 | REVIEW · VISIT |
| 쿠폰 | COUPON |
| 소식 | POST · FEED_CARD |
| 목록·카드 | BASIC_CARD · RELATED_STORES · EMPTY_CARD · ICON_TEXT_CARD · CALLOUT_CARD |
| 지도·필터 | HOME_FILTER · HOME_MAP_CONTROL |
| 안내·유도 | CTA · CALLOUT |
| 광고 | AD_MOB |
| 화면 구성 | TAB |

- THREADS_POST · AD · AD_CARD · IMAGE_PREVIEW_CARD · HOME_BOTTOM_SHEET_TAB · CAROUSEL은 앱과 서버에는 있지만 피그마에 아직 없습니다.
- `FEED_CARD`는 피그마에서 붙인 이름입니다. 앱은 우리 동네 소식(`Feed` 모듈)에서 본문 형태(`CONTENT_ONLY` 등)로 구분해 그립니다.

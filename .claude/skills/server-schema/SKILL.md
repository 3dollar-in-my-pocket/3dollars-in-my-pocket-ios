---
name: server-schema
description: 가슴속 3천원 서버 OpenAPI 스키마를 조회/확인합니다. 서버 응답·요청 모델 구조가 궁금할 때, 특정 API의 필드(예: storeType 유무)를 확인할 때, 업데이트된 스키마가 있는지 확인할 때 사용합니다. dev OpenAPI 문서(https://dev.threedollars.co.kr/api/v3/api-docs)를 받아 필요한 스키마만 추출해 답합니다.
---

# 서버 스키마 조회 Skill

가슴속 3천원 **dev 서버의 OpenAPI 스펙**을 기준으로 API 경로/요청/응답 모델 구조를 확인합니다.

- **스키마 문서(OpenAPI v3 JSON)**: `https://dev.threedollars.co.kr/api/v3/api-docs`
- **dev API Base URL**: `https://dev.threedollars.co.kr`
- **Swagger UI**: `https://dev.threedollars.co.kr/api/swagger-ui/swagger-ui/index.html`

## 언제 사용하나

- "○○ API 응답에 △△ 필드가 있어?" — 특정 엔드포인트의 응답 모델 구조 확인
- "○○ 모델 구조 보여줘" / "이 모델에 어떤 필드가 있어?"
- "이 API 요청 파라미터 뭐 받아?"
- "두 엔드포인트 응답이 같아?" — 모델 비교 (엔드포인트 마이그레이션 검토 등)
- "스키마 업데이트됐는지 확인해줘" — 최신 스펙 재조회
- iOS 모델(`Modules/Core/Model`)과 서버 스키마 일치 여부 검증

## 핵심 원칙

1. **전체 JSON을 컨텍스트에 덤프하지 말 것.** 스펙은 ~1MB(스키마 300개+, 경로 100개+)다. 반드시 임시 파일로 받아 **python/grep으로 필요한 부분만 추출**해서 본다.
2. **curl 사용 (urllib 금지).** 로컬에 Proxyman 등 프록시 인증서가 깔려 있으면 python `urllib`은 `CERTIFICATE_VERIFY_FAILED`로 실패한다. `curl`로 받는다.
3. **스펙과 실데이터를 구분.** OpenAPI의 `extraParams`/`extraParameters`처럼 `additionalProperties`(자유형 맵)는 실제 키가 문서에 안 나온다. 또 신규 필드는 배포 전이라 스펙엔 있어도 실응답엔 없을 수 있다. 확신이 필요하면 **실제 엔드포인트를 호출해 교차 검증**한다(아래 참조).
4. **allOf/oneOf/discriminator 해석.** 스키마가 상속/합성(`allOf`)·다형성(`oneOf` + `discriminator`)을 많이 쓴다. 단순히 `properties`만 보면 빈 객체로 보일 수 있으니 raw 정의를 펼쳐 본다.

## 절차

### 1) 스펙 내려받기 (임시 파일로 캐시)

```bash
curl -s "https://dev.threedollars.co.kr/api/v3/api-docs" -o /tmp/th_apidocs.json
echo "size: $(wc -c < /tmp/th_apidocs.json) bytes"   # 정상이면 ~970KB+
```

> "업데이트 확인" 요청이면 항상 새로 받아 비교한다. 직전 파일을 `/tmp/th_apidocs_prev.json`로 백업 후 `diff <(jq -S . old) <(jq -S . new)` 또는 경로/스키마 목록을 비교한다.

### 2) 경로(엔드포인트) 찾기

```bash
python3 - <<'EOF'
import json
d=json.load(open('/tmp/th_apidocs.json'))
paths=d.get('paths',{})
print('total paths:', len(paths))
for p in sorted(paths):
    if 'screen/store' in p:                      # ← 검색어 교체
        print(p, '->', list(paths[p].keys()))
EOF
```

> 참고: 경로 prefix `/api`는 스펙엔 빠져 있을 수 있다(스펙은 `/v1/...`, 실제 호출은 `/api/v1/...`). iOS `*Api.swift`의 `path`와 대조할 때 유의.

### 3) 엔드포인트의 응답/요청 스키마 따라가기

```bash
python3 - <<'EOF'
import json
d=json.load(open('/tmp/th_apidocs.json'))
s=d['components']['schemas']

def resolve(name, depth=0, seen=None):
    """allOf/oneOf/$ref 를 펼쳐 필드 목록을 출력"""
    seen=seen or set()
    if name in seen: print('  '*depth+f'{name} (...순환)'); return
    seen.add(name)
    sc=s.get(name)
    if sc is None: print('  '*depth+f'{name} (없음)'); return
    print('  '*depth+f'=== {name} ===' + (f"  // {sc['description']}" if sc.get('description') else ''))
    for sub in sc.get('allOf',[]):
        if '$ref' in sub: resolve(sub['$ref'].split('/')[-1], depth+1, seen)
        else:
            for k,v in (sub.get('properties',{}) or {}).items():
                print('  '*(depth+1)+field(k,v))
    for k,v in (sc.get('properties',{}) or {}).items():
        print('  '*(depth+1)+field(k,v))
    for key in ('oneOf','anyOf'):
        for sub in sc.get(key,[]):
            if '$ref' in sub: print('  '*(depth+1)+f'{key} -> {sub["$ref"].split("/")[-1]}')

def field(k,v):
    ref=v.get('$ref') or (v.get('items',{}) or {}).get('$ref')
    if ref: ref=ref.split('/')[-1]+('[]' if v.get('type')=='array' else '')
    t=ref or v.get('type','?')
    enum=f" enum={v['enum']}" if v.get('enum') else ''
    nn=' (nullable)' if v.get('nullable') else ''
    # nullable allOf 패턴
    if not ref and v.get('allOf'):
        t=v['allOf'][0].get('$ref','?').split('/')[-1]
    return f'{k}: {t}{enum}{nn}'

# 1) 엔드포인트 응답 ref 찾기
p='/v1/screen/store/{storeId}/preview'   # ← 교체
op=d['paths'][p]['get']                   # get/post 교체
ref=list(op['responses']['200']['content'].values())[0]['schema'].get('$ref','')
print('200 ->', ref)
resolve(ref.split('/')[-1])               # 응답 모델 펼치기
EOF
```

### 4) 특정 필드명으로 전체 검색 (예: storeType 있는 스키마)

```bash
python3 - <<'EOF'
import json
d=json.load(open('/tmp/th_apidocs.json'))
s=d['components']['schemas']
needle='storeType'                        # ← 교체
for name,sc in s.items():
    blocks=[sc]+sc.get('allOf',[])
    for b in blocks:
        for k,v in (b.get('properties',{}) or {}).items():
            if needle.lower() in k.lower():
                print(f'{name}.{k}: {v.get("type") or v.get("$ref")} enum={v.get("enum")}')
EOF
```

### 5) 두 엔드포인트/모델 비교 (마이그레이션 검토용)

```bash
python3 - <<'EOF'
import json
d=json.load(open('/tmp/th_apidocs.json'))
s=d['components']['schemas']
def shape(n):
    sc=s.get(n,{}); out={}
    for b in [sc]+sc.get('allOf',[]):
        for k,v in (b.get('properties',{}) or {}).items():
            out[k]=v.get('$ref','').split('/')[-1] or (v.get('items',{}) or {}).get('$ref','').split('/')[-1] or v.get('type')
    return out
print('A:', shape('StoreScreen'))
print('B:', shape('StorePreviewScreen'))
EOF
```

## 실데이터 교차 검증 (선택, 확신이 필요할 때)

`screen/store` 류 일부 GET 엔드포인트는 인증 없이도 응답한다(좌표 헤더 필요). 자유형 `extraParams` 실제 키나 "신규 필드 실제 내려오는지"를 확인할 때 유용하다.

```bash
curl -s "https://dev.threedollars.co.kr/api/v1/screen/store/1000/preview" \
  -H "X-Device-Latitude: 37.5" -H "X-Device-Longitude: 127.0" \
  | python3 -c "import sys,json; print(json.dumps(json.load(sys.stdin), ensure_ascii=False, indent=1)[:1500])"
```

- `{"ok": false, ... "not_exists_store"}`면 다른 storeId로 시도.
- `/api/v4/stores/around` 등 일부는 `forbidden`(인증 필요) — 호출 불가.
- 실데이터가 스펙과 다르면, **"스펙엔 있으나 미배포" 또는 "자유형 맵이라 문서 미기재"** 가능성을 함께 보고한다.

## 보고 형식

- 질문에 답할 때 **출처를 명시**: `OpenAPI 스펙 기준` vs `dev 실응답(storeId=N) 기준`.
- 필드 확인 답변엔 **경로 → 응답 모델 → 필드(타입/enum/nullable)** 체인을 보여준다.
- iOS 모델과 비교 요청이면 `Modules/Core/Model/Sources/...`의 해당 struct와 필드 단위로 대조한다.

---
title: '렌더링 검증 자료'
date: '2026-10-14'
summary: '자동·브라우저 검사용 합성 자료이며 게시글이 아닙니다.'
tags: [test, markdown]
draft: false
updated: '2026-10-15'
---

# 제목 검증

## 본문 요소

문단과 **굵게**, _기울임_, ~~취소선~~, `inline code`를 확인합니다.

- 첫 항목
- 두 번째 항목
  - 중첩 항목

1. 순서 하나
2. 순서 둘

> 인용문 검증

```go
fmt.Println("code fixture with a deliberately very long line to check horizontal scrolling on a mobile viewport without overflowing the page")
```

| 항목 | 긴 표 검증 열                                                        | 값     |
| ---- | -------------------------------------------------------------------- | ------ |
| 확인 | very-long-table-cell-used-only-for-horizontal-scrolling-verification | result |

---

[실험 코드](https://github.com/leeeeeoy/leeeeeoy.github.io)

[Portfolio](/portfolio/)

[Lab 상대 경로](../)

![정적 이미지 검증](/brand/built-with-cloudflare.svg)

![R2 이미지 검증](https://assets.leeeeeoy.xyz/portfolio-v2/celdog.webp)

<script>alert('raw-html')</script>

<img src="invalid" onerror="alert('raw-html')">

[위험 링크](javascript:alert%281%29)

[데이터 링크](data:text/html,attack)

![위험 이미지](javascript:alert%281%29)

# Platform exceptions (iOS vs Android)

Default: identical look, motion and behavior (D-012). Each exception needs an id here and `// PLATFORM(PE-###): reason`
in `lib/app/platform`. Add new exceptions only after testing shows a real problem.

| Id | Date | Area | iOS | Android | Reason | Status |
|---|---|---|---|---|---|---|
| PE-001 | 2026-10-19 | Scroll physics / overscroll | Bounce | Stretch | Users feel it physically; changes no visual design. | approved |
| PE-002 | 2026-10-19 | System back | Edge-swipe back | System / predictive back via `PopScope` | Required by each OS. | approved |

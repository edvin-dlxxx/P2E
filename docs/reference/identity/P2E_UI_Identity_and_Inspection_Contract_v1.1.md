# P2E — UI Identity & Component Inspection Contract v1.1

**نوع سند:** قرارداد معماری Frontend / قرارداد داده Dev Inspector  
**تاریخ مبنا:** 2026-10-19  
**وضعیت:** **Adopted Engineering Contract — D-032 (2026-10-21)**; identity API adopted; design approval remains separate  
**دامنه:** تمام خانواده‌های کامپوننت فعلی و آینده P2E؛ فاز اول Button، Badge، General Text Field، Password، OTP، Radio  
**اصل تغییر:** ساختار و پیش‌فرض‌ها در ریشه خانواده؛ داده مصرف‌کننده صرفاً نقش، محتوا و هویت استفاده را مشخص می‌کند؛ **Override ظاهری موردی صفحات خارج از تصمیم‌گیری v1.1 است**.

> **هدف:** در Build توسعه بتوان هر عنصر استاندارد UI را با لمس انتخاب کرد و شناسه، نوع، مرجع طراحی، تنظیمات اعلانی (Declared)، مقادیر حل‌شده (Resolved)، ابعاد واقعی (Measured)، منشأ هر مقدار، و وضعیت تأیید آن را دید؛ در عین حال ابزار دیباگ وارد Build تولیدی نشود.

## 0. مرجع و حدود شواهد

این قرارداد **جایگزین ممیزی جامع Figma نیست**. نسخه ۱.۱ بر گزارش‌های پیشین و یک **راستی‌آزمایی مستقیم و محدود از Figma Copy** در تاریخ 2026-10-19 تکیه دارد. یافته‌های مستقیم با عبارت `api-verified (Copy, 2026-10-19)` از ادعاهای منتقل‌شده از ممیزی‌های قدیمی جدا شده‌اند. هر آنچه در این نوبت دوباره آزمایش نشده، صرفاً «شاهد ممیزی پیشین» است، نه نتیجه تأیید مجدد.

**Figma مورد راستی‌آزمایی:** `7PGTHT5CQzbTsWZQnPIQce` (Copy)؛ بررسی فقط خواندنی و بدون تغییر در فایل انجام شده است. فایل اصلیِ پیش از Duplicate در این نوبت بررسی نشده؛ بنابراین منشأ تاریخی اختلاف‌ها میان Original و Copy **اثبات نشده است**.

مبنای گزارش‌های قبلی و پوشش بازبینی این نوبت:

| خانواده / منبع | پوشش مستند | قید مهم |
|---|---|---|
| `button-system-audit-v0.2.md` + `button-system-consumer-audit-v0.3.md` + `p2e_button_structure_matrix_90.json` | ۱۸ Set / ۹۰ Variant مادر، ۶۰ مورد متن‌دار؛ نمونه‌های متصل در EN | تعارض ارتفاع و Padding عمودی متن‌دار؛ Animation فعال Button در دامنه بررسی‌شده پیدا نشد |
| `badge-system-verification-v1.1.md` و `badge-system-audit-v1.0.md` | ۶ Set / ۳۰ Variant مادر | ادعای پیشین «۱۰ Variable غایب از enumeration» **در Copy بازتولید نشد**؛ ۱۲ Variable مورد استفاده در Variantها همگی قابل‌lookup و در enumeration/collectionها حاضرند. Outlined **1 px CENTER** از گزارش قبلی؛ تأیید مجدد فونت Small برابر 8/10 |
| `text-field-system-audit-v1.0.md` + `text-field-structure-matrix-v1.0.json` | ۶ Set / ۳۴ Variant شامل **۲۶ Text/Password/OTP و ۸ Radio**؛ عدد ۳۷ مصرف EN از ممیزی پیشین، نه بازشماری این نوبت | Text عمومی: Dark+Light؛ Password و OTP: فقط Dark در Design System فعلی؛ Stateهای Success برای هر سه، Edit برای OTP؛ برای Radio، ۴ Hover Smart Animate و ۴ Click بدون Transition **مستقیماً تأیید شد** |
| `text-field-floating-label-verification-v1.1(1).md` | چهار زوج Default→Focused، هشت Endpoint | تغییر موقعیت/فونت/ابعاد معلوم؛ Transition فعال در دامنه خواندنی تأیید نشده؛ `Duration`/`Easing` واقعی مشخص نیست |
| Button page `16433:9027` / EN `16458:11` | ۱۸ Button Set در منبع؛ ۴۳ Instance Button در EN از ۵ Set متمایز | EN شاهدی از مصرف Large Button ندارد؛ Small متن‌دار r10، Small Icon و تمام Medium/Large r12، مستقیم از API |
| Icon page `14466:873` / EN `16458:11` | منابع آیکون مصرفی و نمونه‌های EN | کل رجیستری آیکون هنوز قرارداد نهایی/تأییدشده ندارد |

**پوشش این سند:** قرارداد هویت، داده و مسئولیت‌ها به‌همراه اصلاح شواهدِ Figma Copy. **خارج از دامنه:** تصمیم‌گیری کامل طراح، استخراج نهایی کل Palette/Icon Library، ساخت Flutter Widgetها، اجرای Inspector، تدوین تمام مقادیر Motion و تست دستی عملکرد Figma.

### 0.1 سازگاری نسخه‌ها

- **نسخه سند:** `v1.1`؛ اصلاح شواهد، نگاشت‌ها و آزمون‌ها، بدون تغییر قرارداد ماشین‌خوان.
- **نسخه JSON Schemaها و نمونه‌ها:** فعلاً `schemaVersion: "1.0.0"` باقی می‌ماند؛ فایل‌های همراه **عیناً حفظ شده‌اند** چون در این اصلاح، شکل داده یا الزامات JSON تغییر نکرده است. نام‌گذاری سند و Schema لازم نیست یکسان باشد؛ این تفاوت عمدی است.
- `CHANGELOG_v1.1.md` خلاصه اصلاحات و `figma_evidence_v1.1.json` ثبتِ داده‌های تأییدشده این نوبت است.

### 0.2 نظام صداقت داده

دو محور مستقل برای تمام مقادیر و گزارش‌ها داریم:

- `evidenceStatus`: `api-verified`، `cross-verified`، `derived`، `unverified`، `not-applicable` — **چه اندازه شاهدِ طراحی داریم؟**
- `decisionStatus`: `approved`، `provisional`، `designer-pending` — **چه کسی مقدار مورد استفاده را تصویب کرده؟**

این دو محور معادل یکدیگر نیستند. برای مثال، مقدار هندسی می‌تواند از Figma **API Verified** باشد، اما هنوز «تصمیم نهایی طراح» محسوب نشود. همچنین انتخاب موقت `200ms/easeOut` برای **Floating Label** می‌تواند در کد مجاز باشد، اما **شاهد Figma برای Floating Label ندارد** و به‌عنوان `provisional + unverified` ثبت می‌شود. در مقابل، برای **Radio** مقدار `300ms/EASE_OUT` و `ON_HOVER → SMART_ANIMATE` شواهد واقعی `reactions` از API دارد؛ این دو پرونده نباید با هم ادغام شوند. سیاست صریح پروژه برای همه انیمیشن‌های تعاملی: **Ease Out و Duration حداکثر 300ms** است؛ این سیاست به‌خودی‌خود شاهد اجرای Motion روی سایر کامپوننت‌ها نیست.

**الزام Traceability:** در یافته‌های Figma، دست‌کم `fileKey`، `nodeId` یا مجموعه Node IDها، روش/API خوانش، تاریخ راستی‌آزمایی و وضعیت شاهد ذخیره شود. `evidenceRefs` در Schema موجود یا Registry شواهدِ کنار قرارداد برای این کار کافی است؛ در v1.1 فیلد تازه‌ای به Snapshot تحمیل نمی‌شود.

---

## 1. اصول الزام‌آور (Normative)

**MUST**

1. برای هر **نمونه مهم و قابل انتخاب** از کامپوننت استاندارد، `elementId` معنایی و پایدار تعریف شود. این الزام با «ساخت ۹۰ ID برای ۹۰ نوع Button» متفاوت است.
2. `elementId` مستقل از `size`، `appearance`، `theme`، `icon`، `colorRole`، متن نمایشی، زبان و وضعیت تعاملی باشد.
3. شناسه عنصر، شناسه خانواده، شناسه ساختار و مرجع فیگما مستقل نگهداری شوند.
4. تمام ویژگی‌های ظاهری مشترک از **Component Specification** و **Token Registry** Resolve شوند؛ خود صفحه نباید نسخه محلی Style پایه را بازسازی کند.
5. در Dev Inspector تفکیک `declared`، `resolved` و `measured` رعایت شود و برای هر Property قابل توضیح، **Source/Origin** و وضعیت تصمیم مشخص باشد.
6. ابزار Dev Inspector وابستگی ورودی Production نباشد. فقط یک «قرارداد سبک هویت/توصیف‌گر» مشترک با Production بماند.
7. اسنپ‌شات‌ها Password، OTP، رمز، توکن، متن تایپ‌شده محرمانه، شناسه شخصی و اطلاعات هویتی کاربر را ثبت نکنند؛ سیاست پیش‌فرض برای **تمام مقدارهای تایپ‌شده** حذف است.
8. تغییر پیش‌فرض عمومی فقط در Component Spec یا Token اصلی رخ دهد؛ Inspector ابزار **تشخیص و تولید درخواست اصلاح** است، نه موتور تغییر کد در Runtime.
9. هیچ وضعیت بصری Figma بدون شاهد به رفتار تأییدشده Runtime تبدیل نشود.
10. هر اصلاح قابلیت ردیابی Version، Precondition و اثر تغییر مرکزی بر تمام مصرف‌کنندگان داشته باشد.

**SHOULD**

- نام‌های Component و Token با مدل‌های تایپ‌شده/Registry مرکزی تعریف شوند، نه رشته‌های آزاد در ده‌ها صفحه.
- Dev Inspector با لمس انتخاب کند، بخش انتخابی را Highlight کند و JSON قابل‌کپی تولید کند.
- در بخش‌های تکرارشونده، شناسه موجودیت از کلید پایدار دامنه حاصل شود، نه Index نمایش.
- Slotهای داخلی با مسیر محلی قابل انتخاب باشند بدون اجبار به ID سراسری مستقل.
- ساختار و Schema نسخه‌پذیر، افزایشی و تست‌پذیر باشد.

---

## 2. چهار شناسه مستقل — و یک Locator اجرایی

| Field | مثال | معنا / تغییرپذیری |
|---|---|---|
| `elementId` | `login.email.input` | هویت منطقی نمونه در صفحه؛ با تغییر طراحی ثابت |
| `componentId` | `text-field.general` | نوع اجرایی استاندارد؛ مشترک بین نمونه‌ها |
| `structureRef` | `text-field.general.base` | الگوی ساختاری/قرارداد پایه؛ مستقل از محتوا/رنگ؛ **کلید قراردادی یکسان با Snapshot example** |
| `designRef` | `{fileKey, nodeId}` | ارجاع اختیاری به Figma؛ **فقط اگر تطبیق واقعی داریم** |
| `runtimeLocator` | `{routeName, routeInstanceId, entityKey?, slotPath?}` | مشخص‌کننده **یک نمونه mounted** هنگام بازرسی؛ `routeName` و `routeInstanceId` الزامی‌اند. `elementId` در `identity` است، **نه** در `runtimeLocator` |

**قانون Schema:** محل فیلدها مطابق `p2e-ui-inspector-snapshot.schema.json` است: `identity.elementId`، `identity.componentId`، `identity.structureRef`، `identity.designRef?` و `identity.runtimeLocator`. درون `runtimeLocator` فقط `routeName` و `routeInstanceId` لازم‌اند؛ `entityKey` و `slotPath` اختیاری‌اند. از افزودن `elementId` به Locator جلوگیری شود چون با `additionalProperties:false` رد می‌شود.

### 2.1 قواعد `elementId`

- ساختار پیشنهادی: `<screen>.<section>[.<entity-kind>:<safe-stable-key>].<role>`؛ مثال‌ها: `login.email.input`، `login.submit.button`، `home.featured.game:g-42.play-button`، `wallet.balance.status-badge`.
- بخش‌های اسمی: حروف کوچک ASCII، اعداد و `-`، شروع با حرف؛ جداکننده سلسله‌مراتبی `.`.
- جزء `kind:key` **فقط** برای موجودیت‌های تکراری با کلید پایدار؛ از کاراکترهای امن `a-z0-9_-` برای key استفاده شود. اگر کلید خام این شکل نیست، در لایه هویت آن را با نگاشت/کدگذاری **پایدار و غیرقابل شناسایی شخصی** تبدیل کن؛ ایمیل، شماره تلفن، نام کاربر یا سایر داده‌های شخصی نباید ID شوند.
- ID **هیچ‌وقت** از عدد Index، عنوان ترجمه‌شده، Text Label، رنگ، Icon یا زمان ساخته نشود.
- `elementId` در محدوده منطقی Route و موجودیت یکتا است. برای دو نسخه هم‌زمان از یک Route (مثلاً دو صفحه مشابه در Navigation stack)، `routeInstanceId` فقط برای تفکیک نمونه زنده مصرف می‌شود و بخشی از ID پایدار نیست.
- تغییر ساختار مسیر صفحه فقط وقتی به تغییر ID نیاز دارد که **هویت منطقی عنصر** واقعاً عوض شود. تغییر نام قراردادی ID با Alias/مهاجرت Registry انجام شود تا اسکریپت‌های تست و گزارش‌های قدیمی ناگهان نشکنند.

### 2.2 ID کامپوننت و ساختار

Adopted Type Registry (D-032) (اسم‌ها قرارداد مهندسی هستند، **نام خام Figma نیستند**؛ کلید canonical نمونه برای General Text Field در v1.1 برابر `text-field.general.base` است):

| `componentId` | محدوده |
|---|---|
| `button.base` | Button متنی، Fill-width و Icon-only با Profileهای جدا |
| `badge.base` | Badge اصلی؛ Badgeهای عددی/Reward/Rating فقط اگر بعداً اشتراک معنایی تأیید شود به آن نگاشت شوند |
| `text-field.general` | Text Field عمومی |
| `text-field.password` | قابلیت/Wrapper مبتنی بر منطق ورودی امن |
| `text-field.otp` | OTP سلولی |
| `radio.base` | Radio مستقل از Text Field |
| `card.base` / `slider.base` / `navigation.*` | خانواده‌های آینده، بدون نیاز به تغییر قرارداد ID |

`structureRef` به شناسه **نسخه‌دارِ پروفایل ساختاری** اشاره می‌کند؛ از Node ID فیگما به‌عنوان کلید اجرایی استفاده نشود. سازگاری مرجع با Figma از طریق Catalog برقرار می‌شود. Variantهای Figma را به تعداد کلاس‌های Flutter تبدیل نکنیم. در نسخه حاضر `text-field.general.base` را کلید نمونه/Schema سازگار نگه می‌داریم؛ اگر Registry آینده `default` را انتخاب کند، باید **به‌صورت مهاجرت صریح و هماهنگ** در سند، نمونه‌ها و Registry تغییر کند، نه با دو نام موازی.

### 2.3 Slot / sub-element

`label`، `leadingIcon`، `trailingIcon`، `supportingText`، `container`، `errorText`، `indicator` نمونه‌هایی از `slotPath` هستند. انتخاب یک Slot در Inspector همان `elementId` والد را حفظ می‌کند و `slotPath` را کنار آن اضافه می‌کند. اجزای داخلی فقط در صورت داشتن هویت/تعامل مستقل (مانند دکمه اختصاصی Clear) `elementId` جدا خواهند داشت.

---

## 3. مرز مسئولیت‌های معماری

```text
Features / Screens
    ├── Stable Element Identity
    ├── Content / Usage Config (label, icon key, semantic role)
    └── Components from Design System
            ├── UI Contract (shared interface, identifiers, descriptors)
            ├── Component Specs (layout/state/defaults)
            ├── Typography + Color + Icon + Motion registries
            └── Flutter rendering + interactions

main_dev.dart ──> dev_inspector package ──> UI Contract + Dev Adapter
main.dart     ────────────────────────> UI Contract + No-op Adapter

Dependency rule: dev_inspector -> ui_contract, design_system
                 design_system -> ui_contract
                 ui_contract -X-> dev_inspector
                 production entry -X-> dev_inspector
```

### 3.1 منبع هر نوع مقدار

| Owner | چه چیزی نگهداری می‌کند؟ | چه چیزی نگهداری **نمی‌کند**؟ |
|---|---|---|
| `UI Identity` | نام/شناسه/موقعیت منطقی | رنگ، فونت، اندازه، State |
| `Component Spec` | الگوی هندسی، Slotها، State Resolver، قواعد نمایش، پیش‌فرض خانواده | آیکون ثابت تمام نمونه‌ها، نقش رنگ ثابت تمام Screenها |
| `Typography Registry` | نام **دقیق** Style، family/weight/size/line-height/tracking، زبان/RTL زمانی که مشخص شد | شناسه عنصر |
| `Color Registry` | Semantic Tokens و رزولوشن Theme به Paint | خانواده واریانت هندسی |
| `Icon Registry` | `iconId`، `style=filled/outlined`، منبع Asset، اندازه منبع و نام معتبر | جایگاه اجباری هر آیکون در تمام Buttonها |
| `Motion Registry` | Duration/Curve و policyهای عمومی و Motion پایه خانواده؛ برای Radio شاهد مستقیم Hover دارد | تعمیم Hover به موبایل یا Floating Label یا تصویب رفتار کلیک Radio بدون تصمیم طراحی |
| `State Resolver` | تمرکز، پرشدن، خطا، disable، visibility، با اولویت‌های مرکزی | جایگزینی Input Logic فیگما با قرارداد اجرایی اثبات‌نشده |
| `Dev Inspector` | مشاهده و گزارش؛ Diff و تولید Fix Request | منطق کسب‌وکار، Runtime Editing، تغییر Source Code |

**قانون سیاست عمومی:** مقادیر مرکزی به شکل `Tokens → Component Defaults/Rules → Resolved Component → Render` جریان دارند. صفحات تنها مقادیر مصرفی مانند `label`، `iconId`، `colorRole` و مقصد عملیات را تعیین می‌کنند. برای **حالات عمومی فعلی**، Override ظاهری موردی یک Feature هدف نیست و نباید طراحی معماری را بر مبنای آن پیچیده کنیم.

### 3.2 Provisional Defaults

هر تصمیمِ موقت باید **مرکزی، با کلید مشخص و قابل حذف/تغییر** باشد. ثبت لازم:

`propertyPath | value | unit | evidenceStatus | decisionStatus | source | justification | reviewOwner | lastReviewed`

نمونه illustrative: `text-field.floating-label.duration = 200ms`، `provisional`، `unverified`، `engineering-default`. مقدار ۲۰۰ms تصمیم طراح یا نتیجه Figma برای Floating Label نیست؛ هنگام تنظیم اولیه می‌تواند جایگزین مقدار مجهول باشد به شرط پایبندی به سیاست Ease Out و ≤۳۰۰ms. این ابهام **به Radio تعمیم داده نمی‌شود**؛ داده `reactions` برای Hover رادیو از API تأیید شده است.

وقتی طراح مقدار جدید را تصویب کرد، تغییر فقط در **مرجع اصلی مشخصات آن خانواده** انجام شود. مقدارهای پراکنده در صفحات ممنوع؛ استثناهای محلی در قرارداد دیگری و فاز بعدی تعریف خواهند شد.

---

## 4. Component Descriptor — قرارداد عمومی Inspection

مقدارهای داخل `declared`، `resolved` و `measured` باید از **سه منبع واقعی** بیایند، نه حدس Inspector:

1. **Declared:** پارامترهای اعلام‌شده در مرز کامپوننت. مثال: `iconId=play-arrow`، `colorRole=action.primary`، `componentId=button.base`.
2. **Resolved:** نتیجه اعمال Theme، Tokens، State و Component Spec. مثال: `backgroundColor=#...`، `typographyStyleId=...`، `iconAssetRef=...`، `radius=...`.
3. **Measured:** مشاهده بعد از Flutter Layout/Render. مثال: `widthLogicalPx=...`، `heightLogicalPx=...`، `globalBounds`، و Slot Bounds در صورت فعال بودن ابزار.

هر Property گزارش‌شدنی می‌تواند `origin` و `decisionStatus` و `evidenceStatus` و `evidenceRefs` داشته باشد. اگر منشأ برای یک مقدار در دسترس نیست، `unknown` یا وضعیت Unverified برگردد؛ منشأ ساختگی نده.

### 4.1 ساختار Snapshot v1

فایل ماشین‌خوان `p2e-ui-inspector-snapshot.schema.json` این قرارداد را Validation می‌کند. **نسخه سند ۱.۱ است، اما `schemaVersion` این پیام عمداً `1.0.0` مانده است.** فیلدهای اصلی:

```json
{
  "schemaVersion": "1.0.0",
  "identity": {
    "elementId": "login.email.input",
    "componentId": "text-field.general",
    "structureRef": "text-field.general.base",
    "designRef": {"fileKey": "7PGTHT5CQzbTsWZQnPIQce", "nodeId": "18563:6170"},
    "runtimeLocator": {"routeName": "login", "routeInstanceId": "route-1", "slotPath": "label"}
  },
  "state": {"enabled": true, "focused": true, "hasValue": false, "validation": "none"},
  "declared": {
    "labelRole": {"value": "email", "origin": "usage", "decisionStatus": "approved"}
  },
  "resolved": {
    "typographyRole": {"value": "English/Variant/Label-Small", "origin": "typography-registry", "evidenceStatus": "cross-verified", "decisionStatus": "provisional"}
  },
  "measured": {"widthLogicalPx": 330, "heightLogicalPx": 64},
  "warnings": []
}
```

**این نمونه یک قرارداد داده فرضی است، نه خروجی واقعی Flutter و نه اثبات اندازه 330 برای این نمونه.** `designRef` در حالت‌هایی که ربط مستقیم به یک Variant تأییدشده ندارند حذف می‌شود. منبع مقدارهای رنگی واقعی فقط Registry/Build بعدی است.

### 4.2 Type-specific descriptors

`ui_contract` به جای یک Dictionary بی‌قاعده، یک Descriptor عمومی با **Property Key Registry** و Extensionهای تایپ‌شده تعریف می‌کند:

| Component | داده ویژه‌ای که Inspector باید بتواند بخواند |
|---|---|
| `button.base` | family، size، width policy، appearance، iconId، iconStyle، Color Role، labelRole، enabled، typographyRole، padding، gap، radius، iconSlot، border، measured bounds؛ **radius متنی Small برابر 10 و Small Icon برابر 12** |
| `badge.base` | size، content kind (text/count/status)، status/intention **در صورت تعریف**، iconId/style، theme role، hug dimensions، radius، stroke، visibility و slotها؛ نگاشت Figma `Button=...` به property مهندسی `appearance`؛ تست دسترس‌پذیری Small 8px/10px |
| `text-field.general` | labelStyle resting/floating، placeholder role، supporting text visibility/style، required/optional، focus/hasValue، validation، leading/trailing icon، border، state geometry، motion ref |
| `text-field.password` | همان General + obscure flag، visibility toggle، trailing action؛ **بدون متن رمز**؛ **فقط Dark در Figma Copy فعلی تأیید شده** |
| `text-field.otp` | تعداد خانه/طول **از قرارداد محصول**، index focus/filled count، geometry، status؛ **بدون OTP digits**؛ **فقط Dark در Figma Copy فعلی تأیید شده**؛ `Edit` یک Variant بصری مستقل است |
| `radio.base` | selected/hovered/enabled، indicator size، labelRole، motion provenance؛ `ON_HOVER` Smart Animate 300ms Ease Out در چهار Variant، Click بدون Transition در چهار Variant دیگر |

**محدودیت:** در v1.0 ممیزی Text Field، «Required/Optional» دو Boolean همزمان پیش‌فرض true دارد و ممکن است متن نمایش داده‌شده متناقض باشد؛ State منطقی در Flutter **نباید** صرفاً از Figma Booleanها کپی شود. همچنین محور `Disable` در Button و Badge کنار Appearance آمده و قرارداد استاندارد وضعیت تعاملی نیست.

### 4.2.1 تفاوت Figma State و Runtime Semantics (شواهد Copy)

| خانواده | مجموعه‌ها / حالت‌های تأییدشده | الزام نگاشت در Flutter |
|---|---|---|
| General Text Field | Dark و Light، هرکدام `Default / Focused / Written / Success / Error` | Success نباید از تست/Schema حذف شود؛ Floating Label Motion هنوز جداگانه نامعلوم است |
| Password | فقط Dark، پنج State فوق × Visibility On/Off = ۱۰ Variant | Theme روشن **طراحی تأییدشده ندارد**؛ تولید رفتار روشن نیازمند تصمیم و تست مستقل است |
| OTP | فقط Dark، `Default / Focused / Written / Edit / Success / Error` | `Edit` باید در State mapping و تست پوشش داده شود؛ Theme روشن هنوز شاهد ندارد |
| Radio | Dark و Light، `Not Selected / Not Selected Hover / Selected / Selected Hover` | Hover فقط روی دستگاه‌های Hover-capable؛ رفتار Clickِ prototype که Selected را خاموش می‌کند نیازمند تصمیم Product/Designer است |

**دقت در اصطلاحات:** این جدول موجودی کامپوننت‌های صفحه `18563:6534` است، نه اثبات ناقص‌بودن تمام صفحات Figma یا ممنوعیت طراحی Light در آینده. `validation: "success"` همین حالا در Snapshot Schema پشتیبانی می‌شود؛ `Edit` برای OTP در صورت نیاز در Descriptor/State Resolver نوع‌ویژه ثبت می‌شود و لزوماً به معنای افزودن enum عمومی جدید به `state.validation` نیست.

### 4.3 پارامترگذاری بدون انفجار Variant

- Button: Base structural profile × `appearance` × `theme` × `iconId` × `iconStyle` × `colorRole` × state؛ **نه تکثیر Widget برای هر ترکیب**.
- Badge: Base size/geometry × content و semantic role × icon/color؛ محور خام Variant در Figma به نام `Button` است و در Catalog به `appearance` نگاشت می‌شود (`Filled / Tonal / Outlined / Text / Disable`)؛ *Badge-like Frame*های موجود در صفحات لزوماً instance Badge Base نیستند.
- Text Field: `focus`، `hasValue`، `validation`، `required`، `supportingText`, `obscured` مستقل باشند؛ قواعد اولویت State در Spec خانواده تعریف می‌شوند، نه با enum واحدِ تمام حاصل‌ضرب حالت‌ها.
- OTP و Radio با مدل Interaction مستقل، ولی **همان قرارداد Identity و Inspection**؛ رفتار Radio Click در Prototype معادل سیاست قطعی انتخاب گروهی نیست.

---

## 5. تجربه و چرخه عمر Dev Inspector

1. `main_dev.dart` اپ را با Adapter توسعه و `InspectorOverlay` اجرا می‌کند. `main.dart` فقط قرارداد و No-op Adapter دارد.
2. **Select Mode خاموش:** اپ کاملاً عادی کار می‌کند و Gestureها تغییر نمی‌کنند.
3. **Select Mode روشن:** Tap/Pointer در محدوده ابزار انتخاب به `Element Anchor` منطبق تبدیل می‌شود؛ رفتار اصلی در این حالت تعلیق/مسدود می‌شود. ابزار باید Layered Hit Testing، Scrollables، nested Gestureها و انتخاب Slot را مدیریت کند؛ روشی مبتنی بر Overlay/Widget tree است، نه گرفتن اسکرین‌شات و OCR.
4. Anchor انتخاب‌شده `runtimeLocator` + `component descriptor` می‌دهد. Inspector در همان Build از Token Resolver، State Resolver و Render Object خوانش می‌کند.
5. پنل Properties: تب‌های `Identity`، `Declared`، `Resolved`، `Measured`، `Provenance & Decisions`، `Issues`. تفاوت Expected-vs-Actual وقتی قابل محاسبه است نشان داده شود.
6. `Copy Snapshot` خروجی نسخه‌دار قابل اعتبارسنجی می‌سازد؛ `Create Fix Request` **فقط پیشنهاد تغییر سورس** می‌دهد، نه اعمال آن.
7. هنگام Unmount/Dispose Anchor از Registry حذف شود؛ تغییر Theme/Locale/State باعث به‌روزرسانی descriptor شود، نه خلق یک هویت منطقی جدید.
8. برای فهرست‌های virtualized، عنصر فقط هنگام mounted بودن قابل انتخاب است؛ گم‌شدن از محدوده viewport به معنی حذف هویت منطقی آن نیست.

### 5.1 تداخل لمس و Runtime

- انتخاب کامپوننت نباید در حالت عادی باعث سوءرفتار Tap، Keyboard Focus، Scroll یا Back Navigation شود.
- در Select Mode، کلیک روی Password/OTP/دکمه خرید نباید متن حساس یا عمل واقعی را فعال کند.
- انتخاب Slotهای متداخل باید به‌صورت سلسله‌مراتبی قابل گردش باشد: root، `label`، `trailingIcon`، ... .
- `Measured` به **logical pixels (dp در Flutter UI)** و با تمایز Bounds نسبی/سراسری گزارش شود؛ `physicalPixels` اگر گزارش می‌شود، باید با DPR مشخص و جدا باشد. اندازه Figma px به‌صورت خودکار با اندازه اجرایی Flutter برابر فرض نشود.

### 5.2 Observability و origin

برای یک مقدار مثال: `iconColor` باید هر سه سطح را نشان دهد:

- Declared: `colorRole=action.primary`
- Resolved: `iconColor=#...`, token `actions.primary.on-surface`, origin=`color-registry`
- Measured/Rendered: **در صورت امکان و زیرساخت** Paint/Resolved Color گزارش شود؛ Flutter برای همه Widgetها یک API عمومی برای استخراج همه رنگ‌های واقعی پیکسل‌های نهایی ندارد. اگر قابل دستیابی نیست، «resolved style» گزارش شود، نه «measured pixel color».

برای `size/radius/padding` نیز ثبت `expected` و `actual` باید معلوم کند مقدار واقعاً از Render Object خوانده شده یا از Spec Resolve شده است.

---

## 6. تولید Build و استقلال Inspector

```text
lib/main.dart              -> P2EApp + design_system + ui_contract
lib/main_dev.dart          -> P2EApp + dev_inspector + dev adapter
packages/ui_contract/     -> immutable IDs + base descriptor + port interface
packages/design_system/   -> components/specs/tokens; NO import of dev_inspector
packages/dev_inspector/   -> overlay/selector/registry/export; dev entry only
```

- `ui_contract` سبک و Production-safe باشد. حضور `elementId` و هویت معنایی در Production مجاز است؛ ذخیره Snapshot، Hit-Test Overlay، Export و Reflection گسترده متعلق به Dev Mode هستند.
- Interface کوچک `InspectionPort` با No-op default یا Dependency Injection؛ تولید Descriptorهای سنگین و Registryهای Anchor فقط هنگامی که Port فعال است.
- Build Production **همیشه** از Entry Point اصلی انجام شود؛ Dev entry به Debug Mode محدود گردد. تکیه صرف بر `assert` یا `kDebugMode` برای حذف Importهای Inspector **کافی نیست**؛ جداسازی Import graph و بررسی CI الزامی است.
- هیچ Dependency از `design_system` به `dev_inspector` وجود نداشته باشد. Scanner نباید Sessionهای پروژه، توکن‌ها یا محتوای حساس را به سرویس خارجی ارسال کند.
- Crash/logging Inspector نباید فرآیند اصلی اپ را مختل کند؛ در حالت توسعه نیز Fail-safe و Disposal لازم است.

**پیشنهاد روش مرحله‌ای:** ابتدا یک Overlay محلی روی Android/iOS/Desktop برای انتخاب و Property Panel. در آینده با همین Snapshot Schema می‌توان یک DevTools Extension ساخت؛ تغییر قرارداد شناسایی لازم نیست.

---

## 7. Fix Request Contract — تغییرات عمومی فقط در منبع مرکزی

فایل `p2e-ui-fix-request.schema.json` با `schemaVersion: "1.0.0"` برای درخواست اصلاح **Specification/Token مرکزی** است. `elementId` فقط محل مشاهده مشکل را نشان می‌دهد؛ **Target و Scope واقعی** یک Property مرکزی است.

Scopeهای v1.0:

| `scope` | مجاز؟ | نتیجه |
|---|---|---|
| `component-default` | بله | تغییر مقدار پیش‌فرض همان خانواده و همه مصرف‌کنندگان مربوط |
| `design-token` | بله | تغییر Token مرکزی و همه مصرف‌کنندگانش؛ نیازمند Impact Review |
| `component-implementation` | بله، با Review ویژه | تغییر ساختار/Behavior همان خانواده؛ نیازمند تست |
| `instance-override` | **خیر؛ خارج از قرارداد فعلی** | فقط در فاز بعدیِ استثناهای خاص تعریف خواهد شد |

نمونه:

```json
{
  "schemaVersion": "1.0.0",
  "requestId": "P2E-UI-0001",
  "observedAt": "login.email.input",
  "target": {"scope": "component-default", "componentId": "text-field.general", "propertyPath": "floatingLabel.motion.durationMs"},
  "precondition": {"expectedCurrentValue": 200, "sourceVersion": "1.0.0"},
  "change": {"newValue": 180, "unit": "ms", "reason": "Designer-approved general motion change"},
  "preserve": ["element-identity", "content", "semantic-roles", "validation-behavior"]
}
```

**مثال عددی است؛ هیچ مقدار 200 یا 180ms را به Figma یا Designer نسبت نمی‌دهد.** هیچ Agent نباید براساس Request بدون Precondition، تشخیص گستره تغییر، تست و Review مستقیماً فایل‌ها را ویرایش کند.

### 7.1 الزامات درخواست اصلاح

1. `observedAt` = هویت نمونه‌ای که مشکل در آن دیده شده؛ Target واقعی در منبع مرکزی تعریف می‌شود.
2. `precondition` باید مقدار فعلی و نسخه مرجع را بازبینی کند؛ اگر تغییر کرده، Stop/Conflict.
3. قبل از اجرای تغییر `design-token`، فهرست مصرف‌کنندگان و اثر جانبی بررسی شود.
4. در اصلاح Component، تمام Stateهای اصلی و Golden/Widget Tests مرتبط مجدداً بررسی شوند.
5. گزارش نتیجه شامل فایل‌های تغییرکرده، موارد بازمحاسبه‌شده و تست‌های گذرانده/ناموفق باشد.
6. تغییر داده Sensitive یا عملکرد خرید/پرداخت هرگز صرفاً از یک Snapshot تصویری استنتاج نشود.

---

## 8. ثبت تصمیم و ابهام (Decision Registry)

| ID | موضوع | شواهد موجود / مشکل | جایگاه پیش‌فرض یا تصمیم بعدی |
|---|---|---|---|
| `DEC-001` | Floating Label Motion | Endpointهای 16→14 و Y20→11 طبق ممیزی قبلی؛ Transition فعال برای Floating Label در بررسی قبلی یافت نشد؛ **از Radio قابل استنتاج نیست** | Motion مرکزی `provisional` / `unverified` برای Floating Label، policy Ease Out و ≤300ms؛ تعیین نهایی با طراح |
| `DEC-002` | Button Padding/Height | ۶۰ دکمه متنی: مجموع Padding/محتوا از Height فعلی بیشتر (گزارش پیشین) | قاعده استخراج اندازه بصری در Button Spec؛ تست Golden، تصمیم نهایی اولویت ابعاد |
| `DEC-003` | Badge Light/Disable | گزارش پیشین: رنگ Label/Icon و زمینه #D4D4D4 در ۳ Variant و کنتراست 1:1؛ در این نوبت مجدداً سنجش کنتراست انجام نشده | بدون بررسی دسترس‌پذیری و تأیید Designer همان رنگ به Runtime منتقل نشود |
| `DEC-004` | Badge Color Export Integrity — **NOT REPRODUCED** | ادعای پیشین ۱۰ Variable مفقود؛ در Copy تاریخ 2026-10-19، **۱۲/۱۲ Variable متصل به Variantهای Badge** با `getVariableByIdAsync` یافت شد، در `getLocalVariablesAsync` (۲۸۲ Variable) بود و در `collection.variableIds` نیز وجود داشت. با لحاظ Fillهای Container خود Setها، ۱۴ ID در کل صفحه دیده شد | ادعای نقص جاری Figma **پس گرفته می‌شود**؛ منشأ تاریخی باز است (Original/Copy یا روش استخراج). فقط تست سلامت Registry در Export حفظ شود؛ از برچسب «خرابی فعلی» استفاده نشود |
| `DEC-005` | Text Field Required/Optional | دو Boolean مستقل با default true، رفتار منطقی مشخص نشده (گزارش پیشین) | قرارداد دامنه مستقل `required` و Label Annotation؛ تصمیم Designer/Product |
| `DEC-006` | Text Field Helper/Error | یک Supporting Text property؛ replacement خودکار ثابت نشده (گزارش پیشین) | قاعده Provisional مرکزی با Error Priority تا زمان تصویب |
| `DEC-007` | Password Focus/Visibility + Theme Coverage | ۱۰ Variant Password فقط در **Dark** در Copy؛ تغییر Visibility عملی و رفتار Focus در Flutter از داده Static اثبات نمی‌شود | Flutter Interaction Spec مرکزی؛ امنیت، Focus و Obscure با تست؛ **Light نیازمند Design Review** |
| `DEC-008` | Icon Fill/Outline | دو nested instance مستقل، معادل‌سازی هویت تضمین نشده (گزارش پیشین) | `iconId` و `iconStyle` در Registry جدا؛ اعتبارسنجی نام و Asset |
| `DEC-009` | Semantic Color Catalog | مصرف واقعی و منبع Figma کامل یکپارچه نشده | مرحله استخراج Color Registry و mapping approved/provisional |
| `DEC-010` | Typography Registry | نام/Style IDهای متفاوت حتی با نام شبیه Button-Medium (گزارش پیشین) | حفظ شناسه کامل Style، بدون ادغام نامی یا حدسی |
| `DEC-011` | RTL/Text Scaling | از داده صرفاً انگلیسی رفتار Runtime قابل اثبات نیست | تست‌های اجرای Flutter + Spec بعدی |
| `DEC-012` | Radio Family / Motion & Semantics | در Copy **۸ Variant / ۸ Reaction**: چهار `ON_HOVER → CHANGE_TO` با `SMART_ANIMATE`, `EASE_OUT`, `0.3s` و چهار `ON_CLICK → CHANGE_TO` با `transition:null`؛ سه Instance در EN دارای Hover Reaction هستند. Click از `Selected Hover` به `Not Selected` برمی‌گردد | Motion Hover **api-verified** در Motion Registry با قید دستگاه Hover-capable ثبت شود؛ بدون تعمیم به موبایل. رفتار Toggle-off از Prototype وارد Runtime Radio نشود مگر با تأیید Product/Designer |
| `DEC-013` | Text Field / OTP State Coverage | General Text Field در Dark/Light شامل Success؛ Password Dark شامل Success On/Off؛ OTP Dark شامل Success و `Edit` است | Test Matrix، State Resolver و نگاشت خاص OTP همه این Stateها را پوشش دهند؛ Schema اکنون `validation: success` دارد |
| `DEC-014` | Theme Coverage (Password / OTP) | در صفحه Text Field Copy هیچ Set روشن برای Password یا OTP وجود ندارد | طراحی Light را `unverified` / `designer-pending` ثبت کن؛ Light را از General Text Field حدس نزن |
| `DEC-015` | Badge Appearance & Typography | محور Variant نام `Button` دارد؛ Small Badge متن **8px / line-height 10px**، هر دو API-verified | `Button → appearance` صرفاً در Catalog معنایی نگاشت شود؛ A11y خوانایی/contrast/scale بررسی گردد، بدون ادعای شکست خودکار WCAG |
| `DEC-016` | Button Radius & Consumer Coverage | Small متن‌دار r10؛ Small Icon و تمام Medium/Large r12. EN فقط **۴۳ Instance از ۵/۱۸ Button Set** دارد و **هیچ Large** ندارد | Geometry Spec را برحسب Profile تفکیک کن؛ EN فقط Consumer Evidence محدود است، نه تأیید همه Variantها |
| `DEC-017` | Documentation ↔ Schema Conformance | `runtimeLocator` نمونه جدول قدیمی حاوی `elementId` اشتباه بود؛ `routeName` اجباری حذف شده بود؛ `structureRef` بین `default` و `base` متفاوت بود | مرجع canonical این نسخه Schema + Example است: Locator فقط `routeName,routeInstanceId,entityKey?,slotPath?` و `structureRef=text-field.general.base` |

**این جدول تصمیمات باز را «پنهان» نمی‌کند و پروژه را هم متوقف نمی‌کند.** پذیرش یک پیش‌فرض موقت باید به‌صورت Decision Registry قابل مشاهده و قابل تغییر باشد.

### 8.1 Evidence Ledger — راستی‌آزمایی مستقیم Figma Copy (2026-10-19)

| Ref | محل / Node ID | API / روش | نتیجه / مرز |
|---|---|---|---|
| `FG-20261019-VAR` | Badge page `16433:9139`، ۶ Set | `boundVariables` روی زیر‌درخت Variantها؛ `getVariableByIdAsync`; `getLocalVariablesAsync`; `getLocalVariableCollectionsAsync` + `variableIds` | ۱۲ شناسه متمایز مورد استفاده در Variantها؛ ۱۲/۱۲ موجود در هر سه سازوکار lookup/enumeration/collection؛ ۲۸۲ Local Variable در ۵ Collection. کل صفحه شامل ۲ Variable پس‌زمینه Set اضافه نیز هست (۱۴ ID) |
| `FG-20261019-RAD` | Text Field page `18563:6534`؛ Radio Dark `16481:4815` و Light `16481:5017` | خواندن مستقیم `reactions` از ۸ Variant | چهار Hover Smart Animate با duration≈0.300000012 و EASE_OUT؛ چهار Click بدون Transition؛ بازگشت از Selected Hover به Not Selected |
| `FG-20261019-STATE` | General Text `18562:5887`, `18563:6565`؛ Password `18675:14621`؛ OTP `16481:3382` | `COMPONENT_SET.children[].name` | Success در General/Password/OTP؛ OTP Edit؛ Password/OTP فقط Dark در صفحه ممیزی‌شده |
| `FG-20261019-BADGE` | Badge `16433:9139` / Small Dark `16448:1663` / Small Light `16448:1712` | `variantGroupProperties`, متن `fontSize`, `lineHeight` | Variant axis خام `Button`؛ Small text 8px و line-height 10px؛ در Catalog به `appearance` نگاشت شود |
| `FG-20261019-BUTTON` | Button page `16433:9027` | خواندن `cornerRadius` از Variantهای نمونه ۱۸ Set | Small Fill/Text r10؛ Small Icon r12؛ Medium و Large r12 |
| `FG-20261019-EN` | EN page `16458:11` | `findAllWithCriteria({types:['INSTANCE']})`؛ شمارش نمونه‌های نام‌گذاری‌شده Button و Radio | ۴۳ Button Instance از ۵ Set؛ صفر Large؛ ۳ Radio Instance با Hover Reaction |

**سطح قطعیت:** همه موارد جدول بالا `api-verified (Copy)` هستند، نه `designer-approved`. فایل قدیمی Original و تاریخچه snapshot قبلی بررسی نشده‌اند؛ نسبت‌دادن علت `DEC-004` به اختلاف Original/Copy، تا زمان مقایسه دو فایل، صرفاً **فرضیه** است. شناسه‌های فنی قابل استفاده برای رسیدگی و رگرسیون در `figma_evidence_v1.1.json` نیز ثبت شده‌اند.

---

## 9. تست‌ها و شرایط پذیرش

### 9.1 تست Identity و Registry

- [ ] دو نمونه زنده در یک `runtimeLocator` یکسان نباشند؛ Collision در Dev Mode اخطار روشن تولید کند.
- [ ] شناسه Logical با تغییر Theme/Locale/State/Icon ثابت بماند.
- [ ] نمونه‌های تکرارشونده از کلید پایدار و امن استفاده کنند، نه `index`.
- [ ] `componentId`، `structureRef`، `iconId` و `colorRole` (در صورت وجود) با Registry مرجع Resolve شوند؛ مورد نامعتبر Error قابل تشخیص ایجاد کند.
- [ ] `identity.runtimeLocator` حداقل `routeName` و `routeInstanceId` داشته باشد؛ `elementId` فقط در `identity` باشد و اضافه‌کردن آن به Locator با Schema رد شود.
- [ ] `text-field.general.base` با Example و Structure Registry سازگار باشد؛ `default` نباید بدون مهاجرت صریح به عنوان Alias ناخواسته وارد شود.
- [ ] ریشه و Slotهای داخلی انتخاب‌شدنی باشند، بدون داشتن ID سراسری اضافی برای هر Text/Icon.

### 9.2 تست Inspector و استقلال محیط

- [ ] Select Mode خاموش = رفتار عادی Gesture/Focus/Scroll/Navigation.
- [ ] Select Mode روشن = نمایش Identity، declared/resolved/measured و origin، بدون Trigger عملیات اصلی.
- [ ] Snapshotها طبق JSON Schema معتبر باشند و هرگز مقدار Password/OTP/Input محرمانه نداشته باشند؛ نسخه Schema فعلی `1.0.0` مستقل از نسخه سند `v1.1` است.
- [ ] هر دو فایل `*.example.json` با Schema متناظر اعتبارسنجی شوند و نمونه‌های ناسازگار یا جدول‌های سند متناقض در CI شناسایی شوند.
- [ ] هنگام Dispose/Scroll recycling، Anchor قدیمی از Registry حذف شود.
- [ ] Build Release اصلی هیچ Import/Initialization از `dev_inspector` نداشته باشد؛ CI ساخت را با `main.dart` کنترل کند.
- [ ] برای مقادیر `provisional` منشأ Engineering و دلیل قابل‌ردیابی باشد؛ بدون برچسب به Approved تبدیل نشوند.

### 9.3 تست Design/Component

- [ ] Button profileهای Small/Medium/Large، Text/Icon/Fill را با Expected Geometry و Golden Test مقایسه کن؛ **Small متن‌دار/Fill r10، Small Icon r12، Medium/Large r12**؛ تعارض Padding عمودی را مستقل ثبت کن.
- [ ] برای Button، محدودیت Consumer Evidence رعایت شود: EN فقط ۵/۱۸ Set و ۴۳ Instance دارد؛ هیچ Large در EN نیست؛ پوشش اصلی باید از Component Setها و Golden Test باشد.
- [ ] Badge HUG dimensions، Outlined stroke 1/CENTER و Light Disable را با شواهد و تصمیم Designer مدیریت کن؛ محور خام `Button` به `appearance` نگاشت شود؛ متن Small 8/10 تحت بررسی خوانایی، بزرگ‌نمایی و کنتراست باشد.
- [ ] Integrity Test برای Variableهای Badge: هر ID متصل به Variant در `getVariableByIdAsync`، `getLocalVariablesAsync` و `collection.variableIds` حاضر باشد؛ در Copy بررسی‌شده **۱۲/۱۲ موفق** بوده است، نه ۱۰ مورد مفقود.
- [ ] Text Field در Dark/Light پنج State **Default/Focused/Written/Success/Error** را تست کند؛ Required/Supporting جدا بررسی شوند.
- [ ] Password Dark هر پنج State را با هر دو Visibility On/Off (۱۰ Variant) پوشش دهد؛ **Light را بدون Design Review تأییدشده حساب نکن**؛ هیچ مقدار حساس ثبت نشود.
- [ ] OTP Dark تمام شش State **Default/Focused/Written/Edit/Success/Error** را تست کند؛ Light بی‌شاهد است؛ `Edit` را با `validation` یکی نگیر.
- [ ] Radio، Hover و Click و Focus/A11y را جداگانه تست کند؛ ۴ Smart Animate با Ease Out 300ms ثبت شده‌اند؛ Click بدون Transition است؛ toggle-off از Selected Hover در Production منتظر تصمیم Product/Designer بماند.
- [ ] Hover فقط در محیط دارای Hover فعال شود؛ روی Touch/موبایل State/Feedback جایگزین نیازمند قرارداد است. Reduced Motion در Runtime تعریف شود.
- [ ] برای Floating Label، Motion `unverified`/`provisional` جدا از Motion تأییدشده Radio ثبت شود؛ سیاست کلی **Ease Out و ≤300ms** تنها محدودیت است، نه اثبات مقدار.
- [ ] تغییر یک Component Default فقط با تغییر مرجع مرکزی روی چند مصرف آزمایش و تأیید شود.

---

## 10. برنامه اجرایی پس از تأیید این قرارداد

**گام A — Completed by D-032 (2026-10-21):** قواعد ID، RuntimeLocator، Property Metadata، Statusها، Shape خروجی و Scope تغییر مرکزی را تأیید کنیم. فهرست ID برای تمام صفحات **اکنون لازم نیست**.

**گام B — استخراج رجیستری‌های مشترک:** `Typography Catalog` با نام و Style ID واقعی، `Icon Registry` با Fill/Outline و منابع، `Color Token Catalog` با Variableهای موجود؛ **تست انطباق lookup/enumeration/collection** برای همه IDهای مورد استفاده (Badge در Copy: ۱۲/۱۲ تأیید) اجرا شود. ۱۰ ID تاریخی دیگر به عنوان «Missing در Copy» گزارش نشوند. برچسب Evidence، fileKey، Node ID و تاریخ از ممیزی به Registry منتقل شود.

**گام C — Specification پایه خانواده‌ها:** Button/Badge/Text Field/Password/OTP/Radio؛ مقادیر مرکزی `verified` یا `provisional`، قواعد State، Motion و Slot تعریف شوند. برای Radio، Hover 300ms تأییدشده از Floating Label Motion تأییدنشده تفکیک شود. Password/OTP Light با برچسب `designer-pending`، Success و Edit با coverage کامل ثبت شوند. برای هر Variant Figma یک رکورد Catalog داریم، نه یک کلاس Flutter.

**گام D — Pilot Implementation:** یک Button، یک Badge و یک Text Field واقعی، با یک Identity Contract مشترک و Dev Inspector انتخاب‌پذیر. عملکرد آن‌ها و عدم حضور ابزار Dev در Release سنجیده شود.

**گام E — توسعه به صفحات:** در هر Feature، `elementId`های مصرف واقعی در کنار Widgetها/Registry ثبت شود؛ اسکن خودکار IDهای تکراری و Patch Requestها از ابتدا فعال باشند.

---

## 11. خط قرمزهای قرارداد و سؤالاتی که هنوز باید تصویب شوند

- نام `elementId`، `componentId` و شکل `runtimeLocator` **Adopted v1.1 (D-032)** هستند و تغییر بعدی نیازمند تصمیم ثبت‌شده است؛ باید با Schema 1.0.0 کنونی سازگار باشند و نباید بدون Review آن‌ها را API غیرقابل تغییر معرفی کرد.
- آیا IDهای مربوط به لیست‌های با داده محرمانه مجاز به کلید pseudonymous هستند یا نیاز به شناسه غیرقابل بازگشت دارند؟ انتخاب باید متناسب با امنیت محصول باشد؛ در هر حالت PII در Snapshot ممنوع است.
- `StructureRef` یک کلید معنایی نسخه‌دار است؛ جدول نگاشت به Variant Figma باید در Catalog جدا نگهداری شود. یک Figma Variant لزوماً با یک StructureRef برابر نیست.
- Root Spec، Icon Registry و Token Resolver مالک مشخصات عمومی‌اند. آزادی کامل Override فردی **در این مرحله مطرح نیست**.
- طراحی Motion همه کامپوننت‌ها کامل نیست. **Radio Hover در Copy با 300ms/EASE_OUT تأیید شده است**؛ اما این شاهد برای Floating Label، Mobile Hover یا رفتار کلیک Runtime تعمیم نمی‌یابد.
- ابزار قابلیت توضیح وضعیت واقعی را دارد، نه تضمین کشف همه ویژگی‌های بصری از پیکسل؛ برخی Metadataها باید از کامپوننت و Registry داده شوند.

### نتیجه اجرایی

**در v1.1 قرارداد را روی «هویت پایدار + خوانش دقیق ساختار/توکن/وضعیت + منشأ مقدار + استقلال ابزار توسعه» تثبیت می‌کنیم، و خطاهای ممیزی پیشین را با شاهد Copy از واقعیت فعلی تفکیک می‌کنیم.** این قرارداد با افزایش تعداد Variant، Theme، Icon، Text Field State یا Component Family تغییر بنیادی نمی‌خواهد و بازبینی Designer باید در Spec و Token مرکزی متمرکز بماند.


## Adopted implementation addendum — D-032 / D-033 / D-034 / D-035

Identity naming and the v1.1 API are adopted on 2026-10-21. The no-product-screen migration is immediate with no runtime aliases. Historical design/motion proposals in this document remain proposals; identity adoption does not approve those designs.

The effective occurrence key is (routeName, routeInstanceId, elementId, entityKey?, slotPath?). Definition/source IDs remain shared. UiIdentityScope allocates an instance ID once in initState (or uses a caller instanceKey). A missing scope asserts in debug/tests. Release rendering continues with unavailable metadata; serialization of an unscoped descriptor is explicitly unavailable and no scope is fabricated. An explicit locator override is optional.

Password visibilityAction and OTP cells.cell1 ... cells.cellN keep the owner's elementId and use slotPath. OTP positions are fixed roles. OTP group is text-field.otp-group / text-field.otp-group.base, source-unlinked; cells use text-field.otp. App Bar uses app-bar.container / app-bar.<category> and app-bar.action / app-bar.action.<role>, in lowercase hyphen syntax. Radio component and structure both use radio.base.

D-035 explicitly amends schema safeValue to allow bounded recursive JSON objects/arrays for existing structured source/configuration metadata; property envelopes and origin enums remain mandatory. Secret/input field names remain prohibited, and capturing entered input remains forbidden. Unknown engineering origin annotations are preserved in note with origin runtime-resolver. No slash route-name exception is needed. designRef is omitted for source-unlinked occurrences. Schema version remains 1.0.0 because there are no persisted consumers; this is an additive adoption-time amendment.

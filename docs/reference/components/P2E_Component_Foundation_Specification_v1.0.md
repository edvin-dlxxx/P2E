# P2E — Component Foundation Specification v1.0

**سند:** قرارداد پایه و عمومی کامپوننت‌های Flutter  
**تاریخ:** 2026-10-19  
**وضعیت:** `PROPOSED / ENGINEERING-BASELINE` — برای پیاده‌سازی آزمایشی قابل استفاده، **نه** طراحی نهایی تأییدشده  
**منبع:** گزارش‌های ممیزی قبلی + Registryهای Typography/Icon/Color + خوانش مستقیم فقط-خواندنی سه صفحه App Bar، Navigator Bar و Games در Figma  
**فایل:** `7PGTHT5CQzbTsWZQnPIQce`  
**دامنه:** قواعد عمومی خانواده‌ها؛ نه Overrideهای موردی صفحه، نه منطق Back-end، نه تولید کد اجرایی.

> **تصمیم دامنه:** Figma ناقص است. ما ویژگی‌های مشاهده‌شده را حفظ می‌کنیم؛ برای رفتارهای لازمِ بدون Specification، پیش‌فرض‌های *مرکزی و تغییرپذیر* تعیین می‌کنیم. این کار به معنای تأیید طراحی توسط Designer نیست. تغییر عمومی باید در ریشه خانواده یا Registry مرکزی اعمال شود؛ تغییرات خاص Instance خارج از دامنه این سند است.

## 0. تقدم اسناد و روش استفاده

| اولویت | مرجع | جایگاه |
|---|---|---|
| 1 | `P2E_UI_Identity_and_Inspection_Contract_v1.0.md` + JSON Schemas مربوط | منبع قرارداد شناسه‌ها، Descriptorها، Dev Inspector، Fix Request و مرز Production/Dev؛ **این سند آن را جایگزین نمی‌کند** |
| 2 | `button-system-audit-v0.2.md`، `button-system-consumer-audit-v0.3.md`، `p2e_button_structure_matrix_90.json` | مرجع دقیق Button، وضعیت Padding conflict و شواهد مصرف |
| 3 | `badge-system-audit-v1.0.md`، `badge-system-verification-v1.1.md` | مرجع Badge؛ در تعارض گزارش‌های Badge، اصلاح‌های v1.1 معتبرترند |
| 4 | `text-field-system-audit-v1.0.md`، `text-field-structure-matrix-v1.0.json`، `text-field-floating-label-verification-v1.1(1).md` | مرجع Text/Password/OTP/Radio و وضعیت Floating Label |
| 5 | `p2e-typography-registry-v1.0.json`، `p2e-typography-contract-v1.0.md` | 63 Text Style محلی و قرارداد مصرف؛ رجیستری بر پایه مشاهده است |
| 6 | `p2e-icon-registry-v1.0.json`، `p2e-icon-audit-v1.0.md` | 104 هویت/208 نسخه Filled و Outlined؛ تطبیق قطعی با گلیف‌های Material Symbols **نیست** |
| 7 | `p2e-color-variable-registry-v1.0.json`، `p2e-color-variable-audit-v1.0.md` | 282 متغیر رنگ مشاهده‌شده؛ **Semantic Mapping و تأیید نهایی Color Pending** |
| 8 | `p2e-three-additional-families-audit-v1.0.md` | شاهد تکمیلی از سه صفحه تازه Figma، در حد ممیزی هدفمند ساختاری/بصری |

**مرز اعتبار:** همه مقادیر Figma مربوط به snapshot روز فوق‌اند؛ Revision دقیق فایل pin نشده است. هیچ داده موردی یا اسم نمونه Figma نباید جای قرارداد محصول را بگیرد. سندهای ممیزی بر این سند برای ادعا درباره «آنچه مشاهده شده» تقدم دارند؛ تصمیمات اجرایی این سند فقط برای **پیش‌فرض پیشنهادی مهندسی** معتبرند.

### 0.1 دو محور مستقل وضعیت هر ویژگی

- `evidenceStatus`: `api-verified` / `cross-verified` / `visual-verified` / `derived` / `unverified` / `not-applicable`.
- `decisionStatus`: `approved` / `provisional` / `designer-pending`.
- `origin`: `figma-variable` / `figma-text-style` / `figma-component` / `engineering-default` / `component-spec` / `product-requirement` / `unknown`.

**قانون:** `api-verified` به معنی `approved` نیست. وضعیت عمومی **Color Mapping = designer-pending** است، حتی اگر hex متغیر موجود و verified باشد. سیاست تعیین‌شده پروژه برای Motion تعاملی: **Ease Out و Duration حداکثر 300ms**. این سقف تأیید یک مقدار خاص از Figma نیست.

## 1. معماری قواعد عمومی

```text
[Figma Evidence]       ┌── Typography Registry (verified style IDs)
                       ├── Icon Registry (identity × visual style)
[Central Registries]───┤
                       ├── Color Primitive + Theme Variables (observed; mapping pending)
                       └── Motion Registry (policy + engineering defaults)
                                     ↓
                         [Component Foundation Specs]
                  Button / Badge / TextField / Password / OTP / Radio
                  AppBar / BottomNav / NavItem / GameCards / Comment
                                     ↓
                          [Shared Flutter Widgets]
                                     ↓
                      [Screens: identity + content + actions]

Dev Inspector (only dev entry): reads declared + resolved + measured + provenance.
Production entry: no dev_inspector dependency; ui_contract stays lightweight.
```

**MUST:** هیچ پیاده‌سازی اختصاصی برای حاصل‌ضرب Variantهای Figma ساخته نشود؛ ساختارها با Parameter و State Resolver مشترک ایجاد شوند. `componentId` و `structureRef` کلیدهای مهندسی‌اند، نه `Figma Node ID`. API و قرارداد Snapshot باید با Schemaهای سند Identity موجود سازگار بمانند.

**MUST NOT:** ۱) قرار دادن رنگ نهایی تاییدنشده در تمام صفحات؛ ۲) تعیین نقش `Primary` براساس اسم یک variable بدون تصویب طراح؛ ۳) تبدیل نام Variant اشتباه یا موردی به نام API عمومی؛ ۴) یکی دانستن Badge-like frame با Badge System Base؛ ۵) ایجاد Runtime behavior براساس یک تصویر ثابت بدون برچسب Provisional.

### 1.1 چه چیزی Param است و چه چیزی Component Default؟

| گونه | نمونه | مالک |
|---|---|---|
| هویت و مسیر | `elementId`, `runtimeLocator`, `componentId` | UI Identity Contract |
| مقدار محتوا و عمل | label, iconId, game entity, destination, callback, points/reward data | Consumer Feature / domain adapter |
| پارامتر عمومی کامپوننت | button size/family/appearance، badge size، text-field kind، nav selection، card presentation | Component API |
| هندسه/تایپوگرافی پیش‌فرض | radius، spacing، component typography styles، field baseline geometry | Component Spec |
| رنگ/آیکون/حرکت نهایی | semantic role→paint، icon identity/style→glyph، motion policy | Central Registry / Resolver |
| اندازه نهایی اجرا | bounds، text overflow، material tap target | Flutter Runtime + Inspector |

بحث Overrideهای استثنایی Instance عمداً وارد این قرارداد نشده است.

## 2. خانواده‌های پایه فعلی — Verified و قرارداد پیشنهادی

### 2.1 `button.base` (۹۰ Figma Variant، نه ۹۰ Widget)

**سند مرجع:** `button-system-audit-v0.2.md` و consumer audit v0.3.

- محورهای Figma: `size` Small/Medium/Large × `family` Fill Button (عرض FILL) / Button (HUG) / Icon Button (square FIXED) × `theme` Dark/Light × `appearance` Filled/Tonal/Outlined/Text/Disable؛ ۹ پروفایل ساختاری و ۹۰ Variant. `Disable` در محور Appearance است؛ در Flutter `enabled` رفتار مستقل دارد و «Disable» نباید به‌طور خودکار یک style state برای هر appearance قلمداد شود.
- Height مشاهده‌شده Small/Medium/Large: **36/46/56**؛ Radius Small Textual **10**، Small Icon **12**، Medium/Large **12**؛ root Gap متنی **8** و Icon-only Gap **0**.
- Width: Fill Width با محدودیت والد (**۳۳۰ فقط نمونه ۳۷۰px والد با padding20 است**)، Text Button HUG، Icon Button square FIXED (36/46/56).
- Text buttons: Padding افقی Small/Medium/Large = **12/16/18**. **هشدار مهم:** مقدار ثبت‌شده Padding عمودی همان 12/16/18 است، ولی همراه ارتفاع محتوای 20/20/24 از root height بیشتر می‌شود (به‌ترتیب 8/6/4 px). این اعداد را مستقیم در Flutter جمع نکنیم؛ در نسخه اولیه priority با ارتفاع مشاهده‌شده و مرکزچینی محتواست. این **provisional resolution** است؛ شاهد Figma از تعارض همچنان حفظ شود.
- Typography: `English/Baseline/Button-Small|Medium|Large`، Outfit 600، به‌ترتیب 14/18، 16/20، 20/24، Tracking −4%.
- Icon sizes: دکمه متنی 20؛ Icon-only Fill = **20/24/28** و Outline = **24 در هر سه اندازه** (رفتار observed ولی قصد Designer pending). هر دو Fill/Outline ممکن است exposed در لایه‌های داخلی وجود داشته باشند؛ هر دو را کورکورانه visible نکنیم.
- Border Outlined = **1.5 INSIDE**. Motion فعال در دامنه مادر پیدا نشد؛ تعامل Tap و disabled runtime باید در Flutter طبق contract اجرایی تعریف/آزمایش شود.
- `AppButton` پیشنهادی با چند profile داخلی؛ `label`, `iconId`, `iconStyle`, `appearance`, `size`, `widthPolicy`, `colorRole`, `enabled`, `onPressed` پارامترهای عمومی‌اند؛ color mapping هنوز Pending.

**Gate:** Color Roles، Disabled vs Appearance، Padding conflict و RTL/long text قبل از production pixel-perfect لازم است؛ اما مانع طراحی root API و smoke test نیست.

### 2.2 `badge.base` (۳۰ Figma Variant)

- سه Size × دو Theme × پنج Appearance؛ ابعاد کنونی مادر Small **65×18**، Medium **73×20**، Large **82×22** با copy نمونه، ولی **Width/Height policy = HUG**؛ **نباید** 65/73/82 را مقدار ثابت عمومی کنیم.
- Padding `top/right/bottom/left = 4/8/4/8`؛ Gap **4**؛ Radius **6**؛ Icon Fill **10×10** ثابت.
- Typography: `English/Baseline/Status-Small|Medium|Large`، Outfit 600، 8/10، 10/12، 12/14، Tracking −4%.
- Outlined Stroke: **1 CENTER**؛ مقدار `1.5 INSIDE` از متن اولیه خطا بوده و در v1.1 تصحیح شده است.
- مصرف مستقیم Instance مادر Badge در صفحات EN ممیزی‌شده صفر است؛ Badgeهای Reward/Rating و Nav ممکن است ساختار خودشان را داشته باشند. **از شباهت تصویری، معنای اشتراک یا تعویض مستقیم Widget نتیجه‌گیری نکنیم.**
- Light Disabled (label و container هر دو `#D4D4D4`) برای کنتراست مناسب نیست؛ در آزمون Accessibility جدا بررسی شود. Motion فعال Badge baseline مشاهده نشده است.
- پیشنهاد API: `AppBadge(content, size, appearance, iconId?, iconStyle?, semanticRole?)` با امکان مدل‌های *محتوایی مستقل* که فقط در صورت تصمیم آگاهانه بر همین visual foundation سوار شوند.

### 2.3 `text-field.general` و `text-field.password`

- Text Field عمومی: Dark و Light هرکدام ۵ وضعیت (Default/Focused/Written/Success/Error). Password: فقط Dark، ۱۰ Variant (۵ وضعیت × Visibility On/Off). **Light Password مادر ندارد**؛ بنابراین Light Password در Flutter ترکیب از foundation + theme پیش‌فرض مهندسی است، نه Verified Design.
- Default Label `English/Variant/Button-Medium` Outfit500 16/20؛ Focused Label `English/Variant/Label-Small` Outfit500 14/18. در هر چهار جفت بررسی‌شده جایگاه Label TEXT نسبت به Container از `(16,20)` به `(16,11)` و Input height از **60→64** تغییر می‌کند. Root با Supporting visible نمونه **102→106**، نه ارتفاع همه نمونه‌های اجرا. Input radius **16**، padding افقی **16**، top/bottom Default **8** و سایر Stateها **10**.
- Floating Label: endpoint ثابت verified است؛ Transition واقعی Figma **NOT VERIFIED**. تصمیم مهندسیِ ابتدایی در صورت نیاز به Motion: `easeOut / 200ms` به‌عنوان **Provisional** و نه «مقدار استخراج‌شده». تغییر فقط در `textField.motion.floatingLabel` مرکزی. Trigger semantics باید از FocusNode و content model runtime پیاده شود.
- Supporting Text بیرون Container ورودی است؛ slot مستقل با `padding 8 vertical / 10 horizontal`، radius12 و نمونه ارتفاع34، root gap8. Required و Optional در Figma دو Boolean مستقل حتی همزمان true هستند؛ این را معادل `isRequired` منطقی نگیریم.
- `focus`, `hasValue`, `validation`, `enabled`, `obscured`, `supportingMessage` ابعاد مفهومی مستقل هستند. **Provisional interaction:** Label با focus یا non-empty value بالا، روی blur empty برگردد، helper با error message جایگزین شود، error state بر focus precedence متن پیام داشته باشد؛ این تصمیم‌ها باید در Decision Register ثبت بمانند و نباید به Figma منتسب شوند.
- Password trailing icon در نمونه 24px Outline و slot44px دارد؛ Tap reaction به Figma متصل نشده. Runtime secure handling باید اصول محرمانگی را رعایت کند؛ الگوی نمایشی ۱۶ دایره ثابت را به طول واقعی رمز یا Specification امنیتی تعمیم نده.
- `English/Muted/Title-Small` 18/24 در placeholder مبدأ، با Font Styleهای مستقل؛ Error red و Success semantic role تصمیم نهایی نیستند.

### 2.4 `text-field.otp`

- فقط Dark مادر؛ شش وضعیت Default/Focused/Written/Edit/Success/Error.
- **هر خانه** fixed `48×62`، Radius16، Stroke2 INSIDE؛ Typography ارزش/رقم `English/Baseline/Headline-Small` Outfit600 24/30. Success variant جای مقدار، آیکون Verified دارد. Motion فعال ثبت نشده است.
- **طول گروه OTP و تعداد خانه‌ها از نیاز محصول می‌آید**؛ ۲۴ instance خوانده‌شده در اسکرین‌ها، تعداد ثابت برای تمام فرایندها را ثابت نمی‌کند.
- OTP value هرگز در Inspector snapshot، log و Fix Request کپی نشود. صفحه‌های Placeholder یا کد نمونه را API data-contract حساب نکنیم.
- Light OTP/Focus traversal/keyboard paste/autofill/error presentation از نظر Figma تأیید نشده؛ Provisional fallback و QA لازم است.

### 2.5 `radio.base`

- Radio از نظر معنا خانواده مجزاست حتی اگر در صفحه Text Field قرار گرفته: Dark و Light × چهار وضعیت Selected/NotSelected/SelectedHover/NotSelectedHover؛ هشت Variant؛ root نمونه `370×36` FILL.
- Slot تصویری 36×36 و Graphic داخلی ~20. Hover Smart Animate **Ease Out / 300ms** در ۴ تعریف مادر Verified؛ ON_CLICK variant change بدون animation transition ثبت شده است.
- Selected و Hovered دو state مستقل runtime؛ اگر محیط Touch Hover ندارد رفتار مناسب لمس را جدا تعریف کنیم. پیشنهاد آموزشی: حداقل hit area مطابق accessibility runtime و RTL semantics؛ **ابعاد این سیاست از Figma استخراج نشده**.

## 3. خانواده‌های جدید از سه صفحه Figma (ممیزی هدفمند)

> جزئیات شواهد در `p2e-three-additional-families-audit-v1.0.md` آمده. این ۳ صفحه **ناقص و WIP** هستند. زیرساخت را آماده می‌کنیم، اما از مشاهده پنج حالت App Bar یا ده حالت Games، پوشش تمام سناریوهای محصول نتیجه نمی‌گیریم.

### 3.1 `navigation.app-bar` — App Bar Container

- Source Page `18422:12211`؛ Set `18422:12447`؛ **۵ Variant** روی محور خام اشتباه‌املای `Therme`:
  `Home - Dark`, `Home- Light`, `Downloadable Game - Dark`, `Downloadable Game - Light`, `Back - Dark`.
- **ثابت مشاهده‌شده:** تمام Variant rootها **402×64**، Horizontal Layout، Padding افقی **16**، Vertical0، Clip=true. این عرض **نمونه دستگاه طراحی** است، نه fixed screen width Flutter.
- Substructure: Home = avatar48 + wallet212 + trailing icon48 با spacing/remainder؛ Downloadable Game = back/action48 + two accessory icon slots48 + avatar48؛ Back Dark = back48 + remaining space + help icon48. اصل طراحی **slots متغیر برحسب context** است؛ نبود Back Light نباید به Default Light ناموجود تبدیل شود.
- Typography Points = `English/Baseline/Number-Large` 16/20/600 Tracking0؛ suffix `pts` = `English/Muted/Label-Small` 14/18/400 −4%. Avatar initials 16/20/600 Tracking−5% اما **Text Style ID ندارد**.
- پیشنهاد: یک root `AppTopBar` با `layoutKind ∈ {home,gameDetail,back}`، Theme Resolver مستقل، typed Slotهای `leadingAction`, `profile`, `wallet`, `secondaryActions`, `title?`; هیچ الزامی به حضور همزمان همه slotها نیست.
- `wallet` صرفاً display/value slot نیست مگر محصول بگوید؛ رفتار tap/refresh/credit/currency مربوط به domain است و در Figma تأیید نشده. `back` باید از navigation delegate تأمین شود.
- **Pending:** app bar برای سایر contextها، Back Light، empty loading, truncation, safe area, dynamic width, accessibility, tap mapping, motion, semantic colors.

### 3.2 `navigation.bottom-bar` + `navigation.item`

- Page `18422:11091`؛ Sets: `Vertical Navigation Item - Dark` (`18422:11155`, دو Variant)، Light (`18422:11443`, دو)، `Navigator Bar Container` (`18422:11475`, دو). جمع **۶ Variant**.
- Item mother: **80×68**؛ nested Active Indicator **64×32 radius16**، padding عمودی8، gap4، label12/15 Outfit600، badge count10/10 Outfit700؛ تمام **۲۸ Text Node صفحه بدون Text Style ID** هستند. این مورد را به Style رسمی 63تاییِ شبیه شواهد *بدون تصویب* مپ نکنیم.
- Container mother: **402×68**، Horizontal، Padding چپ/راست6. پنج Instance داخلی هر یک **78×68** در نمونه؛ مقدار80 mother را با width78 مصرف‌کننده خلط نکنیم. نتیجهٔ Responsiveِ لازم هنوز تصمیم آینده است.
- پنج مقصد مشاهده‌شده: Home، Mission، Games، Leaderboard، Shop. Active indicator و Filled Icon برای Active، Outline Icon برای Default در نمونه دیده شد؛ theme-specific color roles هنوز approved نیست.
- Badge count یک Text/Frame با exposed Boolean است و **Instance از `badge.base` نیست**؛ در Flutter می‌توان visual primitive مشترک پیشنهاد داد اما mapping به Badge Foundation نیازمند بررسی semantics/a11y مستقل است.
- پیشنهاد API: `BottomNavigation(items: List<NavItemSpec>, selectedDestinationId, onSelect)` و `NavItemSpec(id, label, iconId, badgeCount?)`؛ تعداد Items از config؛ **همه سیاست‌های >5 یا <5 آیتم و Breakpoint هنوز Pending**.
- **Pending:** navigation state و back stack، active selection behavior، overflow labelها، safe area و gesture system، indicator motion، hit targets، RTL mirroring، semantic badge display.

### 3.3 `game.card.compact`

- Page `18448:10024`، Set `18457:14096` با چهار Variant `Detailed Dark`, `Detailed Light`, `Dark`, `Light`. **دو Presentation مجزا** (detailed/minimal)، نه چهار کامپوننت مستقل.
- Root مشاهده‌شده **120×204 detailed** و **120×178 minimal**؛ image **120×120** با radius16، فاصله با information block **8**؛ این اندازه‌ها نمونه‌اند، نه مجوز hardcode روی تمام دستگاه‌ها.
- Slotها: thumbnail/art, optional reward overlay, gameName, creator (در Detailed), rating. محتوا و assetها باید از entity/data adapter بیایند؛ متن‌های نمونه/تصویرهای فعلی Figma قرارداد محتوا نیستند.
- `Game Name` = `English/Baseline/Title-Small` 18/24/600؛ Creator `English/Baseline/Label-Small` 14/18/600؛ Rate `English/Baseline/Number-Medium` 14/18/600.

### 3.4 `game.card.expanded`

- Set `18457:14486`: **دو Theme**، root نمونه **370×226**؛ inner Game Frame radius16 clipped، background bound to theme source. contains hero image, reward overlay, icon/name/creator/rating, one small linked Button and in-app purchase hint.
- Button واقعی از Button System داخل کارت Instance شده است؛ **نه پیاده‌سازی دوم دکمه**. Reward/Rating Frameها لزوماً از `badge.base` نیستند.
- Button label/action/purchase note از domain/UI action config؛ `in-app purchases` باید معنای درست داده و accessibility داشته باشد.
- **Pending:** image fit/height responsive, card action Tap vs button action, alignment on long game names, permission to hide rating/reward, density variants.

### 3.5 `game.card.event-offer`

- Set `18526:11872`: دو Variant `Default` و `Light`؛ root **370×270**، radius16، clipped، banner **370×160** + details **370×110** با padding14 و gap4. `Default` در Figma حالت Dark نمایشی است، **نه Contract جدید theme سوم**.
- Title `English/Baseline/Title-Small` 18/24/600؛ Description `English/Muted/Body-Medium` 14/18/400. Reward عددی در دو Theme **Style یکسان ندارد** (Default Number-Medium 14/18؛ Light Number-Small 12/14): این ناسازگاری را Confirmed Mapping فرض نکنیم؛ centralized provisional typography role تا Designer تصمیم بگیرد.
- `title`, `description`, `banner`, `reward` محتوایی‌اند؛ تصویر، کپی sample و عدد reward تنظیم ثابت Foundation نیستند.
- **Pending:** truncate/expand، کارت بلندتر در Dynamic Type، CTA/navigation، alt image semantics و تغییر متنی اسکرین‌ها.

### 3.6 `game.comment`

- Set `18526:11914`: دو Theme، root **338×190** (نمونه)، Header **48**، Rating/Date **34**، Comment Body **108**؛ avatar + author، پنج Star نمونه، تاریخ، متن و منوی More.
- Author `English/Baseline/Label-Medium` 16/20/600؛ Date `English/Baseline/Number-Medium` 14/18/600؛ Body `English/Muted/Body-Medium` 14/18/400. Avatar initial 16/20/600 Tracking −5% **unstyled**.
- Content بسیار طولانی در نمونه وجود دارد؛ **ارتفاع 190 نمونه را به محدودیت ثابت تمام Commentها تبدیل نکنیم**. برای accessibility و text scaling ترجیح مهندسی `height: content-driven` و محدودسازی خط با سیاست جداست.
- Rating در نمونه از Star glyphهای مستقل تشکیل شده؛ نیم‌ستاره دیده می‌شود، ولی نتیجهٔ ارزیابی واقعی rating و rounding spec از Figma ثابت نشده. وجود ۵ Star تصویری تعداد ثابت glyph را نشان می‌دهد نه منطق rating backend.
- **Pending:** menu actions/moderation, author privacy, rating precision, date localization, accessibility ordering, max lines, interaction behavior.

## 4. قواعد یکپارچه Foundation

### 4.1 Component Registry v1.0

| `componentId` | `structureRef` پیشنهاد | نمونه class هدف (نام قطعی نیست) |
|---|---|---|
| `button.base` | `button.text-fill`, `button.text-hug`, `button.icon-square` | `AppButton` |
| `badge.base` | `badge.inline-hug` | `AppBadge` |
| `text-field.general` | `field.floating-label` | `AppTextField` |
| `text-field.password` | `field.password` | `AppPasswordField` (ترجیحاً wrapper foundation) |
| `text-field.otp` | `field.otp-cell` | `AppOtpField` |
| `radio.base` | `radio.item` | `AppRadio` |
| `navigation.app-bar` | `navigation.app-bar.contextual` | `AppTopBar` |
| `navigation.bottom-bar` | `navigation.bottom-bar` | `AppBottomBar` |
| `navigation.item` | `navigation.destination-item` | `AppNavigationItem` |
| `game.card.compact` | `game.card.compact` | `GameCompactCard` |
| `game.card.expanded` | `game.card.expanded` | `GameExpandedCard` |
| `game.card.event-offer` | `game.card.event-offer` | `EventOfferCard` |
| `game.comment` | `game.comment` | `GameComment` |

نسخه `structureRef` در Catalog کنار پروفایل نگهداری می‌شود؛ نام پیشنهادی بالا «خام Figma» نیست. هنگام توسعه بسته به نیاز واقعی می‌توان nesting منطقی انجام داد؛ **هویت Inspector باید از نظر معنایی مستقل بماند**.

### 4.2 Composition و reuse — مرزِ ثابت و فرضی

- **اثبات‌شده:** `Game Expanded Card` در Figma یک Button Instance متصل دارد؛ Nav bar از پنج `Navigation Item` Instance تشکیل شده؛ Iconهای این مجموعه‌ها به Icon Library متصل‌اند.
- **تأییدنشده:** Reward/Rating chipها یا Nav badge همان `Badge System` موجودند؛ نباید قبل از تایید structural/semantic equivalence عوض شوند.
- **پیشنهاد:** primitiveهای مشترک `AppIcon`, `AppText`, `AppAvatar`, `AppRatingVisual`, `AppRewardChip` فقط زمانی به public foundation ارتقا یابند که از دو یا چند خانواده با قرارداد بصری واقعاً یکسان استفاده کنند. **از اسم مشابه، اشتراک اجباری استنتاج نشود**.
- `navigator`, `cards`, `app-bar` کامپوننت ترکیبی‌اند؛ `elementId` root + `slotPath`های `avatar`, `wallet`, `reward`, `rating`, `label`, `activeIndicator`, `actionButton` کافی است؛ رفتار تعاملی مستقل در زمان موردنیاز `elementId` خودش را می‌گیرد.

### 4.3 Typography

- **63 Style رسمی انگلیسی**، همگی Outfit در Muted 400، Variant 500 و Baseline 600؛ متن‌های Number tracking 0 و سایر Styleها معمولاً −4%؛ از **Style ID** و اسم کامل registry استفاده شود.
- Style Id خالی در Navigator، Avatar و In-app hint را به زور Style رسمی با اندازه نزدیک نگاشت نکنیم. برایشان `provisional component typography` با Figma metrics و `noStyleBinding` ثبت شود تا اصلاح مرکزی بعدی ممکن بماند.
- `tracking(PERCENT −4)` به مقدار نسبت به اندازه قلم در Flutter تبدیل شود (`fontSize * −0.04`). مثلاً 16px→−0.64 logical px؛ در فونت فارسی/RTL هنوز فهرست/Specification مصوب نداریم.
- Font availability و License/font embedding موضوع فاز Flutter Blueprint است؛ از فایل فونت خصوصی یا داده حساس در خروجی قراردادی استفاده نمی‌شود.

### 4.4 Icon

- 104 هویت جفت‌شده Fill/Outline؛ source frame تمامشان 24×24. **فاصله بصری و اندازه مصرف را Component تعیین می‌کند** (برای Button/Badge 10/20/24/28 هم وجود دارد). `iconId` از `style` مستقل است؛ Figma Node ID صرفاً design reference.
- در 39 جفت Filled/Outline Vector Paths یکسان است؛ پس «تفاوت الزامی» در پشتیبانی دو سبک ادعا نمی‌شود.
- *هنوز glyph matching Material Symbols و تولید SVG/asset تأیید نشده است*. صرف `IconId` رجیستری یعنی قرارداد metadata، نه asset آماده production.

### 4.5 Color و Theme — عمداً **Designer Pending**

- Registry فعلی: 282 COLOR Variables: 242 primitive، Dark14، Light14، Base2، Supporting10. مجموعه Dark و Light دو Collection مستقل و دارای تک Mode هستند، نه دو Mode در یک collection. هیچ Variable Alias در 282 مقدار مشاهده نشده است. **هشدار پوشش:** گزارش‌های Button و Badge شناسه‌های بعضی رنگ/Alphaهای مصرف‌شده را ثبت کرده‌اند که با `lookup` معتبرند اما در enumeration عمومی حضور ندارند؛ بنابراین Registry شامل 282 مقدار enumerable را با «تمام رنگ‌های مصرف‌شده در Componentها» یکی نگیریم. این استثناها باید در Token Resolution و QA با provenance و fallback تشخیص داده شوند.
- **قطعیِ فنی**: VariableIDها و مقدارهای فعلی/Bindings و بعضی semantic role nameها قابل‌خواندن‌اند. **غیرقطعی طراحی**: Primary/Success/Danger global نقش نهایی ندارند، Contrast correction و semantic mappings تصویب نشده‌اند.
- قرارداد اجرایی: `component color role` → `theme semantic token` → `current raw Figma var or provisional value`؛ هیچ نقش نهایی را صرفاً از hex یا نام Supporting/Pink حدس نزنیم.
- Snapshot Inspector باید Figma raw token + resolved paint + decisionStatus را نمایش دهد. `ThemeMode` Flutter به معنای تغییر Collection ساختاری Figma نیست.
- برای نمونه Prototype اگر نمایش بدون رنگ امکان‌پذیر نیست از **Provisional role mapping مرکزی** استفاده شود و آن را در Decision Register به نام Figma Verified معرفی نکنیم.

### 4.6 Motion

- سیاست الزام‌آور تمامی تعاملات: `curve = EaseOut` و `duration <= 300ms`.
- Radio Hover 300ms/EaseOut verified؛ Floating Label فقط Endpoint verified؛ Button/Badge و خانواده‌های جدید Transition مصوب عمومی ندارند. خانواده‌های جدید از حیث Motion ممیزی جامع نشده‌اند؛ **وضعیت آن‌ها UNVERIFIED است، نه No Animation**.
- Motion Parameters مرکزی‌اند و per screen تعریف نمی‌شوند. Reduced-motion و OS setting یک الزام محصول/Accessibility مهندسی است و باید مسیر خاموش‌سازی/کاهش داشته باشد؛ جزئیات پیشنهادی تا تصمیم QA ثبت بماند.

### 4.7 State Resolution و Constraints

- State runtime نباید حاصل رشته‌هایی مثل `Focused - Visibility Off` یا `Disable` از Figma باشد. داده‌های مستقل: `enabled`, `focused`, `hasValue`, `validation`, `obscured`, `selected`, `hovered`, `loading` در خانواده‌های مربوط.
- **پیشنهاد precedence اولیه** برای Text: Disabled interaction > Error message > Success message > Focus presentation > Filled > Empty. «بالاتر بودن پیام» الزاماً به معنای پنهان‌شدن focus ring یا تغییر همه نقش‌ها نیست؛ قواعد رنگ Pending.
- برای Game card/Navigation داده‌های دامنه (`gameId`, `destinationId`, reward count, rating) از Widget foundation جدا باشند؛ در UI data bindings به display format تبدیل شوند؛ نه اینکه از Figma sample text ثابت خوانده شوند.
- تمام Widthهای 330/370/402 نمونه‌محورند؛ Flutter باید Constraints parent و screen safe area را رعایت کند. برای text scaling و RTL، اثر reflow نباید باعث clipping پنهان شود. جاهایی که Figma `clipsContent=true` دارد، الزام به clip تمام متن بلند RTL در اپ نیست.

## 5. Identity و Dev Inspector — افزونه سازگار با v1.0 موجود

از سند Identity قبلی پیروی می‌کنیم. `elementId` به تغییر theme، size، icon یا data format وابسته نیست. مثال‌های مفهومی (نام‌های پیشنهادی):

```yaml
identity:
  elementId: home.navigation.bottom
  componentId: navigation.bottom-bar
  structureRef: navigation.bottom-bar
  designRef: {fileKey: 7PGTHT5CQzbTsWZQnPIQce, nodeId: '18422:11474'}
slots:
  - destinations.home
  - destinations.mission
  - activeIndicator
state:
  selectedDestinationId: home
```

```yaml
identity:
  elementId: home.games.game:g-42.card
  componentId: game.card.compact
  structureRef: game.card.compact
slots:
  - thumbnail
  - reward
  - rating
  - title
runtime:
  entityKey: g-42
```

**مهم:** مثال‌ها تعریف `elementId` واقعی صفحه نیستند و ارجاع DesignRef فقط وقتی مجاز است که پروفایل واقعاً با Node منتخب مطابق باشد. ساختارهای `slots` بالا **illustrative**اند، نه Inspector Snapshot معتبر مطابق JSON Schema؛ قرارداد واقعی Snapshot در `p2e-ui-inspector-snapshot.schema.json` حفظ می‌شود. `elementId` داده شخصی مانند ایمیل، شماره تماس، نام کاربر یا متن نظر را حمل نمی‌کند. محتوای TextField/Password/OTP در inspector باید redacted باشد.

Inspector برای هر خانواده به شکل توسعه‌پذیر `declared/resolved/measured` را جدا نمایش می‌دهد. در ترکیبی‌ها Slot path و origin توکن‌ها مهم است. مثلاً Nav badge باید بتواند بگوید `custom visual/unstyled`, نه اینکه به دروغ `badge.base` گزارش کند. رنگ و Typography که از طراحی خام نگاشت شده‌اند باید وضعیت pending/provisional خود را منتقل کنند.

## 6. فهرست Decisionهای باز و Defaultهای مرکزی

**سیاست تغییر:** هر `provisional` یک کلید واحد در `Component Specs`/`Motion Registry`/`Theme Resolver` دارد؛ پس از موافقت طراح فقط مقدار و `decisionStatus` همان کلید تغییر می‌کند. هیچ صفحه نباید خودش Base Radius, Motion, Typography یا Color را کپی کند.

| ID | موضوع | وضعیت فعلی | پیشنهاد/اقدام مهندسی اولیه | Gate |
|---|---|---|---|---|
| F01 | Button vertical padding conflict | observed conflict | ارتفاع root + center-content مرجع اولیه؛ padding حقیقی در تست Layout اصلاح شود | قبل pixel-perfect |
| F02 | Button `Disable` و allowed icon combinations | designer-pending | Runtime `enabled` مستقل؛ appearanceهای اصلی محدود به چهار مورد، disabled visual موقت مرکزی | قبل production |
| F03 | Semantic color mapping | designer-pending | فقط raw variable & central placeholder role؛ **نه تصویب رنگ** | قبل color approval |
| F04 | Floating Label transition | provisional | در صورت نیاز: EaseOut/200ms؛ endpoints Figma verified | قبل motion sign-off |
| F05 | Required/Optional & helper/error | provisional | semantics مستقل؛ در error، پیام غالب بر helper؛ label با focus یا value شناور | قبل forms QA |
| F06 | Password/OTP/Radio behavior | provisional | secure text input / autofill / selected semantics و hit testing مستقل از نمونه static | قبل release QA |
| F07 | AppBar missing contexts & Back Light | designer-pending | ساختار slot-based با fallback theme مرکزی بدون ادعای شواهد | قبل appbar parity |
| F08 | BottomNav typography unstyled | designer-pending | ثبت Outfit600 12/15، Count700 10/10 تحت token provisional، بدون ادغام خودکار | قبل typography sync |
| F09 | Nav layout five items / 402px | provisional | ۵ نمونه مبنا، responsive item sizing برحسب constraints؛ موارد خارج از پنج آزمون جدا | قبل responsive QA |
| F10 | Game card fixed sizes vs content | provisional | aspect/density از profile، text/content constrained, permit height growth when necessary | قبل long-text QA |
| F11 | Event Offer reward typography mismatch | designer-pending | separate evidence by theme؛ در Flutter role موقت با value مرکزی و review | قبل card parity |
| F12 | Reward/Rating/Nav badge relation to base Badge | designer-pending (evidence: unverified) | استقلال ساختاری حفظ؛ reuse فقط پس از semantic validation | قبل visual deduplication |
| F13 | Avatar/In-app hint manual fonts | provisional | component-local token with provenance; no false official Text Style ID | قبل typography approval |
| F14 | Icon glyph match & export | designer-pending (evidence: unverified) | verify Flutter Material Symbols mapping or export approved SVG assets | قبل icon rollout |
| F15 | Accessibility/RTL/font Persian | designer-pending | runtime safe fallbacks & acceptance tests؛ not in Figma audit | قبل production |
| F16 | New family motion and onTap | designer-pending (evidence: unverified) | instrument callbacks by product behavior; do not infer motion from screenshots | قبل navigation QA |
| F17 | Game data model and comment privacy | product-dependent | typed view models; redaction/no username in ElementId; no backend assumed | قبل domain integration |

فهرست CSV جداگانه (`p2e-component-foundation-decision-register-v1.0.csv`) مالکیت و منشأ را در سطح پیشنهاد مستند می‌کند؛ `approved` جعلی ثبت نشده است.

## 7. Implementation Readiness Gates — نه سند اجرای Flutter

### Gate A — Contract & data (همین مرحله)

- [ ] `componentId`های پایه و خانواده‌های جدید با Identity Contract و Snapshot Schema بدون تغییر ناسازگار باشند.
- [ ] Core configuration از `component spec`/Registry مرکزی resolve شود؛ dependency به Dev Inspector در Production صفر.
- [ ] فایل‌های Registry واقعی Typography/Icon/Color در project version control و source provenance محفوظ باشند؛ بایگانی raw values جدا از runtime semantic role map.
- [ ] همه Provisionalها و Designer Pendingها در Decision Register دارای کلید و owner باشند.

### Gate B — Foundation smoke test (فاز Flutter)

- [ ] یک exemplar از Button (هر سه Size)، Badge (سه Size)، Text Field (focus/blur/error)، Radio، OTP، App Bar، Bottom Navigation، Compact/Expanded/Event Card و Comment روی دو Theme نمایش داده شود.
- [ ] در Dev Inspector، `declared`, `resolved`, `measured`, `origin`, `decisionStatus` با مقدار واقعی و بدون دروغ دربارهٔ مقادیر Figma نمایش یابد.
- [ ] جابه‌جایی screen width و تغییر font scaling موجب overflow/pixel clipping پنهان در متن مهم نشود؛ especially 330/370/402 نمونه‌ها.
- [ ] رفتار Flutter interactive زیر 300ms/EaseOut، keyboard focus, hover/touch, safe area, semantics, RTL، reduced motion و password/OTP redaction تست شود.
- [ ] تست snapshot / visual comparison برای مادری‌های verified و runtime smoke screens جدا، بدون فرض یکسانی px و dp.

### Gate C — Designer alignment (بعداً)

- [ ] Color semantic map رسمی تصویب شود، تغییر مستقیم داخل AppButton/Badge/Nav/GameCard ممنوع.
- [ ] typographyهای unstyled Nav/Avatar/Hint و English-only limitation تعیین تکلیف شوند.
- [ ] Motion، Icon rendering source، light password/OTP و دیگر contextهای گمشده بررسی شوند.
- [ ] Shared badge visuals در صورت تمایل طراح با constraints واقعی مرتبط شوند.

## 8. جمع‌بندی و Stop Rule

**قابل تثبیت اکنون:** هویت و قرارداد Inspection، مرزهای Production/Dev، پارامترگذاری و خانواده‌های ساختاری، 63 Typography Style رسمی، 104 Icon Identity، 282 Color Variable به‌عنوان *مشاهده*، و ساختارهای خوانده‌شده از سه خانواده جدید.

**عمداً باز:** تأیید نهایی Palette/Semantic Color، گلیف دقیق آیکون‌ها، Motion نگفته‌شده، متن‌های unstyled و تصمیمات محصول/طراح درباره موارد ناقص Figma.

**Stop rule این مرحله:** دیگر برای «کامل شدن سند» ممیزی سراسری Figma انجام نمی‌دهیم. پس از بازبینی قرارداد فعلی، مرحله بعد **`P2E Flutter Foundation Implementation Blueprint v1.0`** شامل file/folder map، public typed API، token resolver interfaces، state machines، dev-only wiring و QA sequence است. این سند خود کد Flutter نیست و نباید جای سند معماری frontend موجود را بگیرد.

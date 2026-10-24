# App Bar family

DEVELOPMENT, 2026-10-20. Live Figma access was read-only. Scope is set
`18422:12447` in `7PGTHT5CQzbTsWZQnPIQce`, page `18422:12211`.
Machine-readable spec: generated `docs/snapshots/2026-10-20_development-app-bars/app_bars.json`.
Its five rows retain raw `Therme` values, every source ID, normalized anatomy,
bindings, component typography and exact local icon registry links. Run
`node tool/tokens/generate_app_bars.cjs [--check]`; do not edit generated data.

## API and valid combinations

`AppBarCategory {home, downloadableGame, back}` is independent of the ambient
theme. `AppBarSpec.lookup(category, brightness)` returns null for Back Light.
`AppBarConfiguration` is sealed: `HomeAppBar`, `DownloadableGameAppBar` and
`BackAppBar` require only their category's display data and actions. Each
`AppBarAction` requires a nonblank consumer-localized label; a null callback
means disabled/unavailable. Balances are supplied strings, never reformatted.
`AppBarAvatar` accepts display text or consumer artwork. `AppBarWallet` supplies
points/unit/coins, complete accessible labels and optional `CompactAppBarWallet`.
No title, search, menu, automatic bookmark state or navigation is supplied.

All five source variants ship: Home Dark/Light, Downloadable Game Dark/Light,
Back Dark. Back Light deliberately throws an informative unsupported error;
callers can check availability first. No theme parameter on the widget.

## Anatomy and source layout

Content is 64 high, root transparent, directional horizontal padding 16.
Home: profile envelope48, flexible spacer, wallet, help48. Wallet is two
distinct 32-high pills separated by4; points has padding4/4/8/4, gap6,
24 currency background and16 artwork; text number16/20/600 + unit14/18/400
with gap4. Coins has padding4, gap6, a minimum36-wide amount slot and
24 add surface with14 artwork. Source sample wallet is212 wide, never a
universal width. Text width follows Figma HUG rounding; coin slot grows with data.
Pills use source height32 as a minimum; at1.3 scaling they grow to34 to preserve
the26-high number line and source vertical padding, within64 content height.
Game: back48 (32 surface, radius10, artwork24), flexible spacer, downloads48,
bookmark48, profile48. Dot6 is centered in a24 overlay at start24/top0;
it ignores pointers/semantics. Back: back48, flexible spacer, help48.
Avatar32/radius16, component-specific Outfit600 16/20 tracking−5%, unlinked
source text style. Number and unit retain their official full style names/IDs.
Persian uses the already bundled provisional Vazirmatn fallback (R-003).

## Behavior and host integration (D-030)

`AppBarContent` owns no SafeArea. `AppBarScaffoldAdapter` implements
PreferredSizeWidget: preferred height64 excludes top inset; Scaffold allocates
its normal MediaQuery top inset and the adapter consumes that allocation with
exactly one top SafeArea. Use with Scaffold(primary:true), without another
outer SafeArea; `extendBodyBehindAppBar`/Scaffold(primary:false) are outside
this adapter contract. Standalone content can be put inside a host-owned SafeArea.
No Material elevation, background, surface tint or fake system icons.

Home minimum width depends on actual font, strings and scale. At source data,
1.0× English:340 (wallet212 + two48 actions + padding32). Game minimum224;
Back minimum128. First collapse spacer, then use caller-provided compact values
and optionally suppress the secondary unit visually. Full semantic labels remain.
If still too narrow, preserve the minimum canvas behind a visible horizontal
scrollbar. Essential actions stay reachable; this is explicitly a scroll fallback,
not a claim of fitting arbitrary strings in64 high. `AppBarLayout.resolve`
exposes widths/compact/overflow to the Viewer. No automatic numeric abbreviation.

Runtime rows use semantic leading/trailing order; source previews force English
LTR. Only the registry mirrors the back arrow, exactly once. Numeric value
runs use LTR isolation; stored strings are never reversed. Unit uses host direction.
Action hit regions48 do not overlap. Add Coins owns the last48 of the coins
envelope; decorative value content is not a second action. Native TextButton
provides keyboard/focus/semantics; shared PressAction paints action-only motion
using existing ButtonMotion. Focus outline/hover overlay are explicit engineering
fallbacks, source reactions remain empty. Disabled callbacks retain source paint
and expose disabled semantics. All engineering defaults are generated centrally.

Parent and children use stable consumer ID + action-role suffixes. Child source
IDs refer to their actual source envelopes; source count remains five. Development
identity status stays provisional, never claims designer approval. Viewer reads
runtime descriptors, resolver and measured RenderBox bounds; it does not retype
source metadata. No new golden baselines are authorized.

## D-044 text scaling and caller-owned number formatting

All fixed-chrome text roles (avatar, points value/unit, coins value and future textual roles in every category) inherit the single chromeTextScaleCap=1.3. The app content cap is 2.0. Full pointsSemanticLabel/coinsSemanticLabel must include the complete value and unit regardless of visual scaling. Six-digit en/fa values with units are tested at 402 in both brightness modes; existing visible horizontal overflow handles longer content without shrinking or ellipsizing. Any compact number/count notation belongs to the product caller, exactly as for Badge labels. App Bar does not silently abbreviate values. No title slot is fabricated.


Readiness measurement (D-044): at a 402 host and 1.3 chrome scale, unformatted
six-digit values plus units require 489 logical pixels in en and 474 in fa,
identically in Light/Dark. They **do not fit the visible 402 viewport**; the
existing horizontal canvas scrolls. The test confirms complete semantics and no
internal paragraph clipping, not simultaneous visibility. No further shrinking
or silent ellipsis is applied. A caller-supplied compact representation is needed
for simultaneous visibility; this task does not invent product formatting.
D-047 authorizes initial Windows source-variant goldens, pending review.

## Avatar content contract (delegated review, 2026-10-22)

Caller-provided text is initials of1–2 graphemes, never a full name. Existing ClipOval/FittedBox bounds text and custom content to the circle at all supported chrome scales; anti-alias clipping is explicit. Regression tests include oversized text paint in the actual component. Fixtures use CM / سم. This does not add a runtime length exception or change avatar geometry.

# AppIcon — full development library

Authorized by D-023. Source: `docs/snapshots/2026-10-20_development-icons`.
The complete read-only page inventory has 104 concepts and 208 definitions in
Fill/Outline. No standalone definitions, nested instances or additional sets were
found on this page. All source names and node links are retained. Version ID,
named designer delivery, approval, attribution and license are unavailable.

## API and identity

Use the existing `AppIcon` input and concrete `AssetAppIcon(AppIconId.crown,
style: AppIconStyle.outline, size: 24, semanticLabel: localizedLabel)` through
`design_system.dart`. `AppIconRegistry.byKey('icon.crown')` resolves a stable
logical identity; the old `crown` alias and existing `editSquare` enum survive.
No translated label or ordinal is an identity. Source identities belong to each
`IconArtwork`; consuming controls retain their own `ElementIdentity` and runtime
locator. The pure artwork does not invent a second interactive control identity.
Registry entries are its generated source/spec metadata.

The owner explicitly authorizes size, color and semantic/decorative parameters
for this icon API. `size` is a bounding square; `BoxFit.contain` retains the source
viewBox and aspect ratio, without optical padding. A semantic label makes the
artwork labelled unless `decorative` is explicitly true. Default artwork is
decorative, with no technical identifier announced. Buttons exclude child
semantics and own their accessible label.

Original paint is the default. `color` requests an explicit tint;
`useThemeColor` requests the current `IconTheme` color. Tint is applied only when
the generated source classification is monochrome. Multicolor/gradient/image/
pattern/filter/text/use artwork is conservatively preserved. A color request
does not rewrite assets or bindings. All actual source exports in this snapshot
contain only SVG/path elements and one white paint; there are no complex SVG
feature cases or multicolor source exports. The non-monochrome guard is tested
separately and is not evidence that such artwork exists in this source.

Unknown keys and absent style versions throw `MissingIconArtwork`; no style,
glyph, Material or network fallback exists. The registry contains explicit
styles and can represent missing counterparts. Source SVGs and runtime copies
are byte-identical. The maintained, already-installed flutter_svg 2.3.0 renderer
is reused; no dependency upgrade or custom parser is introduced.

## Button links

The 90 source master variants are followed via their nested instances.
Text-bearing Fill/Hug uses Edit Square in both styles. Icon-only Fill uses
Crown; its hidden Outline child uses Edit Square (E-012). The Viewer follows
these explicit links and exposes the selected key/style/source metadata.
The caller can independently supply Crown Outline to a shared AppButton;
the Viewer never silently changes the source's hidden child to that glyph.
Icon-only with mode none is a localized invalid preview, not a blank control.
Text-only product reference examples remain without artwork. Button appearance,
90 source identities, disabled behavior and engineering press motion are retained.

## Viewer and validation

The existing physical-left Inspector is reused. The Icons tab searches logical
keys, raw names and generated FA/EN labels; filters actual versions; reports
logical/version counts separately; supports original/theme/accent tint, two
surfaces and 16/24/32/48/64 previews. Selection decoration belongs to the Viewer.
Metadata and render-validation status come from the registry, never tile literals.

`validation.json` records all original assets decoded, painted to nonempty
pixels and exercised through the shared widget. SHA-256 checks reconcile page
inventory, every export, source asset, runtime copy and registry. Representative
source screenshots and native previews are visually inspected; successful
parsing/painting does not imply pixel-perfect equivalence or designer approval.
No golden baselines are created.

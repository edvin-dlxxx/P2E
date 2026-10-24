# Bundled fonts

Outfit Latin and provisional Persian Vazirmatn. No runtime download. Verified TrueType signatures, internal version names and Git blob SHA-1 against official GitHub metadata over HTTPS. SHA-256 below records the bytes bundled locally; it is not a publisher-signed checksum. License files were verified with the same procedure.

Local filenames omit brackets because Flutter FontManifest percent-encoded bracketed asset paths and FontLoader could not load them. Font bytes are unchanged. Outfit weight 600 is declared for the three generated Button styles; the source is a variable font. Vazirmatn is the approved provisional Persian fallback.

## assets/fonts/outfit/Outfit-Variable.ttf

- Version: 1.100 (Google Fonts commit 8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5)
- Official source: https://raw.githubusercontent.com/google/fonts/8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/outfit/Outfit%5Bwght%5D.ttf
- Git blob SHA-1: 466d6245f9582df39bf73da91a8b3c938fd061cd
- SHA-256: fc7287273e66929776e2ba54f144fe699080bec29f61bf649d70d871468aeade

## assets/fonts/outfit/OFL.txt

- Version: 1.100 (Google Fonts commit 8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5)
- Official source: https://raw.githubusercontent.com/google/fonts/8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/outfit/OFL.txt
- Git blob SHA-1: 723cd447edee83ed3bb07c3343f478d352aa7440
- SHA-256: c676351bf8576b9aba743cd5eaa8c0e7ee0d51f805d720447b4df4ddb6a2e416

## assets/fonts/vazirmatn/Vazirmatn-Variable.ttf

- Version: 33.003 (release v33.003; commit 83629f877e8f084cc07b47030b5d3a0ff06c76ec)
- Official source: https://raw.githubusercontent.com/rastikerdar/vazirmatn/83629f877e8f084cc07b47030b5d3a0ff06c76ec/fonts/variable/Vazirmatn%5Bwght%5D.ttf
- Git blob SHA-1: b02ceb054d5f1f9ac563e79248ce1bf8e35d60ca
- SHA-256: 696249a2c74b39ffdef55de4df2809c5b639d3ff80d618d8160a095d2fd49dca

## assets/fonts/vazirmatn/OFL.txt

- Version: 33.003 (release v33.003; commit 83629f877e8f084cc07b47030b5d3a0ff06c76ec)
- Official source: https://raw.githubusercontent.com/rastikerdar/vazirmatn/83629f877e8f084cc07b47030b5d3a0ff06c76ec/OFL.txt
- Git blob SHA-1: be66b3824e9772e75141e631695c5256f105fb57
- SHA-256: 17e355067c8284f47743a1ee3b1ef7ff684ff0601eda357f9353b10b3016ab31

Widget measurements load both families via test/flutter_test_config.dart and FontLoader before tests run. No golden baselines are created.


## D-048 runtime family resolution

Family resolution is centralized in `BundledTypography`. A resolved family is
qualified once (`packages/p2e_design_system/...`) with **no retained TextStyle
package argument**. Raw generated token declarations still use unqualified
Outfit + package; `FigmaTextToken.style` resolves them at the consumption boundary,
without changing generated source, rawTypography, sizes, weights, line heights,
tracking, colors, feature/variation settings or source IDs. Reconstruction is
necessary because Flutter TextStyle.copyWith retains private package metadata;
merging a qualified fallback into that style otherwise prefixes it twice.

The existing typography contract is retained, rather than inventing Persian
styles: token-styled headings/Button retain Outfit primary plus bundled
Vazirmatn fallback (including Persian digits). Existing locale-aware Badge,
Field/Password/Radio, App Bar and Navigator retain Vazirmatn primary for Persian.
OTP's cell, native input and snapshot now use the same existing directional
Persian selection. Inherited PageScaffold/Material text and Viewer shell keep
their previous primary styles plus bundled fallback; no Latin family is changed.
R-003 stays open; no Persian scale, weight, height or tracking is designer-approved
by this engineering fix. Generated typography files remain byte-identical.

An attempted blanket fallback on Latin Field styles changed supporting-text
rasterization in one English2.0 golden. The controlled previous Latin resolver
passed; it was preserved, using the expressly allowed existing locale-aware
path instead. All38 English golden sheets subsequently passed without updates,
and all20 English product contact sheets stayed byte-identical.

Structural tests enumerate exported tokens, ThemeData text/primaryText themes,
Button extensions/specs and Badge/Field (including derived Light)/App Bar/
Navigator Persian style paths in both brightness modes and both skins. Actual
mounted paragraphs are also inspected. Render tests compare pure Persian runs
and Persian digits to bundled Vazirmatn reference advances and baseline-aligned
exact glyph rasters, and reject square-glyph rasters. AppIcon has no text. This
is a bounded representative check, not an engine font-selection API or proof
for every Unicode character, mixed-script shaping, IME state or device rasterizer.
Mixed Latin runs keep Outfit, so whole mixed-string metrics need not equal an
all-Vazirmatn paragraph. No system font is used for the tested Persian runs.

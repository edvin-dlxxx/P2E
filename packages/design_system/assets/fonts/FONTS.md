# Bundled fonts

Recorded 2026-10-23. License: SIL Open Font License1.1; each family includes OFL.txt. No runtime downloading.

## Outfit

Official Google Fonts release: https://github.com/google/fonts/tree/8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5/ofl/outfit
Original: Outfit[wght].ttf; Version1.100;gftools[0.9.27]; SHA-256 fc7287273e66929776e2ba54f144fe699080bec29f61bf649d70d871468aeade. The former bundled variable file was byte-identical to this upstream release, but its default axis/OS2 weight was100 while pubspec declared600 only. The incorrect manifest mapping is replaced.

Static400/500/600/700 instances below were generated with the recorded toolchain from that pinned official variable file using fontTools.varLib.instancer, updateFontNames=True. These are all weights referenced by current DS styles. Each has real interpolated outlines, matching OS/2.usWeightClass and a dedicated pubspec face. No variable wght request is retained for Outfit. Regenerate using tool/fonts/prepare_outfit.py; never fabricate bold through stroke/paint.

## Vazirmatn

Version33.003; provisional Persian typography R-003. Source https://raw.githubusercontent.com/google/fonts/main/ofl/vazirmatn/Vazirmatn%5Bwght%5D.ttf. Existing bytes match the official Google Fonts file. Variable wght100..900, default400; existing variable-axis selection is retained. License is bundled in vazirmatn/OFL.txt.

| File | Type/weight | Version | SHA-256 |
|---|---|---|---|
| outfit/Outfit-400.ttf | static400 | Version 1.100;gftools[0.9.27] | `cdf4b4254aa5adf964bf22b1495da27a59347e122c1f17cbf6ce1641576ace84` |
| outfit/Outfit-500.ttf | static500 | Version 1.100;gftools[0.9.27] | `37f0fce3eb6058d065467a990eea9daf58961e9a23b8ac4efda3804d38c64ce3` |
| outfit/Outfit-600.ttf | static600 | Version 1.100;gftools[0.9.27] | `9e237cbd892e94ea2727809f21d4067c24e88735d13c3c01a17f0ec1ae723b9e` |
| vazirmatn/Vazirmatn-Variable.ttf | variable100..900 | Version 33.003 | `696249a2c74b39ffdef55de4df2809c5b639d3ff80d618d8160a095d2fd49dca` |

| outfit/Outfit-700.ttf | static700 | Version 1.100;gftools[0.9.27] | `8325636982b8a45ce21fe02389cc2b82cef4fb141d8b36cdd0b0b1d563489c75` |

Generation tooling: fontTools4.60.1. Static outlines are instantiated, not faux-bolded. Independent-reference raster tests cover each registered weight; this is representative glyph evidence, not an engine trace for every Unicode code point.

License hashes:
- packages/design_system/assets/fonts/outfit/OFL.txt: SHA-256 `c676351bf8576b9aba743cd5eaa8c0e7ee0d51f805d720447b4df4ddb6a2e416`
- packages/design_system/assets/fonts/vazirmatn/OFL.txt: SHA-256 `17e355067c8284f47743a1ee3b1ef7ff684ff0601eda357f9353b10b3016ab31`

Additional real700 face is required by numeric fontWeight entries in navigation_data.g.dart (not a FontWeight.w700 literal). Outfit-700.ttf: Version 1.100;gftools[0.9.27]; OS/2=700; SHA-256 `8325636982b8a45ce21fe02389cc2b82cef4fb141d8b36cdd0b0b1d563489c75`.

## Bold consumers (acceptance clarification)

Outfit700 is used by NavigationItemSpec.textStyle('badgeLabel') in all four item source rows: Dark inactive18422:11156, Dark active18422:11154, Light inactive18422:11444, Light active18422:11462. Each is Outfit Bold10/10, tracking0, with an empty source textStyleId (component-local style, not a named English typography token). The Navigator badge renderer requests this style. Named exported English typography tokens use400/500/600; they do not use700. This real700 face remains bundled to avoid synthetic bold for the component-local Navigator badge style.

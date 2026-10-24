# PageScaffold and SizeClass — provisional engineering contract

Authorized by the Entry foundation request (D-039); no Figma source or appearance approval.
Public library: `package:p2e_design_system/design_system.dart`. Plain Flutter, no Riverpod.

- SizeClass uses available window width only: compact <600, medium <840, expanded otherwise.
- PageScaffold accepts child, required elementId, optional runtimeLocator. UiIdentityScope is required in debug fixtures.
- Identity: `layout.page-scaffold`, provisional, no fabricated designRef; resolved sizeClass is inspectable.
- Scaffold resizes for keyboard; one SafeArea handles system insets, including edge-to-edge.
- A SingleChildScrollView participates in native EditableText focused-field reveal.
- Medium/expanded content is centered and capped at the compact boundary (600), an engineering Entry default, not a tablet design.
- No navigation chrome, extra padding or breakpoint-dependent typography. Text scaling is inherited unchanged, tested at 1.0/2.0; product D-015 still caps at 1.3.
- Generated engineering values: `design/engineering/adaptive.json`, generator `tool/tokens/generate_adaptive.cjs`.
- Geometry and keyboard tests use actual bundled fonts. No golden baseline is authorized.
- The existing Viewer Components catalog includes three simulated window widths (390/700/1000). Horizontal catalog scrolling preserves the actual preview width; PageScaffold's own content scrolls vertically. These engineering examples use the Viewer's locale/theme, distinct identity scopes and existing controls; they add no product screen or Inspector capability.

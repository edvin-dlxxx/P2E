# Text Field System — D-024 development contract

Source: immutable development-text-fields snapshot, six live sets / 34 variants.
Base TextField 10, Password 10 Dark, OTP cell 6 Dark, Radio 8. Raw Written/Edit
states remain distinct. Version/designer approval is unavailable.

Public controls: AppTextField, AppPasswordField, AppOtpCell, AppOtpField,
AppRadio and AppRadioGroup. Both consumers use the same package implementations.
Shared presentation primitives support a read-only source catalog; dev reference
overrides do not claim simultaneous native focus or manufacture runtime source IDs.

Interaction: error > success > focused > written > default. Nonempty focused
editing keeps the floating label and Written input typography; it is not success.
OTP maps empty active to Focused, populated active to Edit, populated inactive
to Written. Validation is caller-controlled. FieldFeedback.error requires a
nonblank message in release too. Supporting content and its gap are absent when
empty; errors cannot be hidden. One requirement enum selects required OR optional,
with separate indicator visibility and caller-localized indicator copy.

Controllers/focus nodes are externally owned when supplied and otherwise disposed
internally. Rebuilds keep native editing objects. Password begins obscured and
changes obscureText immediately, without crossfading text, normalizing its value
or exposing it in metadata. Localized show/hide labels come from the caller.

OTP uses one native editor, not disconnected cell editors, for paste/autofill,
selection, replacement and formatters. Code length and accepted characters are
caller configuration; completion fires only on a distinct newly completed value.
Logical cell order is explicitly LTR inside either surrounding UI direction.
The six-cell reference consumer has 8 padding, 8 gaps and a real 10-unit divider
after the FIRST cell, not merely six evenly spaced cells. Runtime uniform layout
and source-reference divider layout are explicit configurations. Group feedback
is outside source cells. Values survive success artwork and are never inspected.

Radio is a rounded 20-unit square (radius 8), inside a 36-unit hover surface,
with the actual 4-unit inset effect when selected. Native RadioGroup keyboard
registry is reused with custom source rendering. Group selection is controlled;
deselection is opt-in, never implied by requirement. No Error variant is invented.
Runtime targets may grow to 48 while source visual bounds are measured separately.

Motion: actual Radio hover SMART_ANIMATE / EASE_OUT / ~300 ms. Inspected click
reactions have no explicit transition. Engineering label 160 ms, color 120 ms,
support expansion 150 ms, easeOut, generated from field_motion.json. Reduced
motion uses an immediate target-size layout for body/support expansion rather than a zero-duration AnimatedSize controller. A stable keyed subtree preserves native editor state when the OS motion policy changes. Other reduced-motion transitions use zero duration; normal size animation durations/curves stay unchanged. No claim is made about every possible Figma motion API.

Light Password/OTP are engineering extensions only when all Dark semantic paints
resolve to verified matching Light names; shared supporting paints are retained.
They have null source variant/set IDs and retain an explicit Dark basis reference.
Disabled/read-only/focus-only extensions likewise do not invent source variants.
Persian uses bundled Vazirmatn as the existing provisional typography fallback.

Source supporting error backgrounds include unbound but recorded source paints;
these remain in generated source data, never hand-authored widget constants.
All geometry/paint/text roles resolve from generated data; no default Material
input decoration or generic green/red policy substitutes for the source.

The engineering OTP group helper reuses Base TextField supportText typography (14/18), rather than the OTP cell Headline Small (24/30).

D-026 supersedes the same-name-only derived Light rule above. Per-part variable bindings are generated from the actual Base TextField Dark/Light twins: body and helper use different Light surface roles; label/input/icon roles follow their matching anatomy. Existing source geometry, shared error paints and null dedicated source IDs remain.

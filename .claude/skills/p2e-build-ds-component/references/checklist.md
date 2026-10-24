# Done checklist — Design System component

- [ ] API matches the contract; no Color / TextStyle / EdgeInsets / size parameters
- [ ] Invalid combinations assert in debug
- [ ] Light and Dark both come from the theme; no theme parameter
- [ ] No raw values (or each has `OVERRIDE(O-###)` + register entry)
- [ ] Directional layout only; RTL screenshot looks right; directional icons mirror
- [ ] Min touch target 48 dp; semantics label for icon-only
- [ ] All states: enabled, pressed, hovered, focused, disabled, loading (+ error for fields)
- [ ] 2.0× content scale: no clipping/overflow; named chrome cap1.3
- [ ] `ElementIdentity` with Figma node id and status
- [ ] Gallery entries for every valid combination × theme × direction × size class
- [ ] Golden tests added and reviewed
- [ ] Inspector shows match for every measurable property (or the mismatch is explained)
- [ ] `flutter analyze`, tests, `check_architecture`, sync `--check` pass
- [ ] Registers updated; Persian report sent

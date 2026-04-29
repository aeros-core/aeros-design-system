# Configurable MTO — design-system reference

The configurable-MTO (`MTO_CONFIG`) listing mode lets buyers self-configure a
made-to-order product (size, GSM, colour, print, artwork) with live price
preview and instant checkout. The backend shipped in April 2026 across five
PRs ([#92–#96](https://github.com/aeros-core/aeros-backend)). This page
documents the Flutter components that consumers (`aeros-mobile-marketplace-app`,
`aeros-admin`) use to render the buyer-facing and seller-facing surfaces.

## Component map

```
AerosAttributeSelector  ─┬─→ AerosEnumDropdown        ENUM, > 6 options
                         ├─→ AerosEnumChips           ENUM, ≤ 6 options
                         ├─→ AerosRangeSlider         MEASUREMENT + RANGE
                         ├─→ AerosMeasurementInput    MEASUREMENT + free numeric
                         ├─→ AerosSwitch              BOOLEAN
                         └─→ AerosFileUploadButton    FILE source

AerosVariantPicker            (size / colour swatches + in-stock badges)
AerosPriceBreakdown           (collapsible breakdown of BreakdownStep[])
AerosRoutingSignalBadge       (requires_rfq, requires_credit_check, …)
AerosConstraintErrorAlert     (locale-aware constraint violations)
```

## Decision matrix — when to use which input

`AerosAttributeSelector` picks automatically. Use this matrix when designing
new attributes or overriding the default with `forceVariant`.

| Datatype | Option source | Default input | When to override |
|---|---|---|---|
| ENUM | enum, ≤ 6 options | **`AerosEnumChips`** | Force `dropdown` if labels are very long |
| ENUM | enum, > 6 options | **`AerosEnumDropdown`** | Force `chips` if you want all options visible at once and labels are short |
| ENUM | file | **`AerosFileUploadButton`** | — |
| MEASUREMENT | enum (discrete numeric chips, e.g. 150, 200, 250 gsm) | **`AerosEnumChips`** with `unitSuffix` | Force `slider` if continuous values feel more natural for the buyer |
| MEASUREMENT | range (continuous, e.g. 150–350 gsm step 25) | **`AerosRangeSlider`** | Force `measurement` if buyers usually type the value (large ranges, e.g. quantity 100–500,000) |
| MEASUREMENT | file | **`AerosFileUploadButton`** | — |
| BOOLEAN | enum | **`AerosSwitch`** in a labelled row | — |

### Heuristics

- **Chips beat dropdowns under 6 options**, especially on mobile — the buyer can scan all choices without a second tap.
- **Sliders beat number fields for narrow ranges with steps** (e.g. 150 ↔ 350 gsm step 25). For ranges spanning several orders of magnitude (quantity 100 ↔ 500,000), the slider becomes useless — switch to the measurement input.
- **Use `AerosEnumChips.swatchColor`** for colour pickers. The chip renders a colour dot before the label.
- **Use `AerosVariantPicker.style = swatch`** when the variant is primarily visual (colour, fabric); use `chip` when it's primarily textual (size labels, fabric names).
- **Don't double-up labels.** `AerosEnumDropdown`, `AerosEnumChips`, `AerosRangeSlider`, `AerosMeasurementInput`, and `AerosFileUploadButton` all render their own label and required marker. Don't wrap them in `AerosFormField`.

## Backend → component data flow

| Backend output | Component input |
|---|---|
| `AttributeDefinition` row + `CategoryAttributeOption` policy | `AerosAttributeSpec` |
| `cart.preview.line.customization_json` value | `AerosAttributeValue` |
| `MeasurementUnit` row | `AerosMeasurementUnit` |
| `CatalogVariant` row | `AerosVariantOption` |
| Pricing engine `BreakdownStep[]` + subtotal buckets | `AerosPriceBreakdownData` |
| `cart.preview.routing_signals[]` entry | `AerosRoutingSignal` |
| Constraint violation `message` JSONB locale map | `AerosConstraintErrorAlert.messageByLocale` |
| Asset upload result (id + name + size) | `AerosFileRef` |

The components have **no API client dependency**. The host app (mobile or
admin) translates API responses into these types.

## Tokens

Three new token classes back the configurable-MTO surfaces. They live in
`packages/flutter/lib/src/tokens/states.dart` and are exported from the
top-level package.

### AerosSelectionState (theme-aware)

| State | Background | Border | Foreground | Used for |
|---|---|---|---|---|
| `unselected` | `bgSurface` | `borderDefault` (1) | `fgPrimary` | Default chip / variant |
| `selected` | `brandPrimaryMuted` | `fgPrimary` (2) | `fgPrimary` | Picked option |
| `disabled` | `bgSubtle` | `borderDefault` (1) | `fgMuted` | Out of stock, disabled by upstream choice |
| `lockedByAdmin` | `bgSubtle` | `borderStrong` (1) | `fgSecondary` | Seller has locked this attribute on the listing |
| `requiredButMissing` | `dangerBg` | `dangerBorder` (1) | `dangerText` | Submit attempted with the field empty |

Resolve with `AerosSelectionPalette.resolve(state, AerosAliasColors.light)`.

### AerosSeverity (fixed semantics)

`info` / `warn` / `error` map to the existing `royal` / `warning` / `danger`
ramps. Used by `AerosRoutingSignalBadge` and `AerosConstraintErrorAlert`.

### AerosPriceTone

| Tone | Foreground | Inline label | Used for |
|---|---|---|---|
| `discountable` | `fgPrimary` | — | Per-unit lines that respond to bulk discounts |
| `nonDiscountable` | `slate600` | "fixed" | Setup fees, plate fees, shipping |
| `discount` | `success` | "discount" | Negative breakdown lines |

## Integration recipes

### Build the configure form from `/products/:id`

```dart
final spec = response.attributeSpecs;
final value = state.draftConfiguration; // Map<String, AerosAttributeValue>

Column(
  children: [
    for (final s in spec)
      Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: AerosAttributeSelector(
          spec: s,
          value: value[s.key] ?? const AerosAttributeValue(),
          onChanged: (v) => state.setAttribute(s.key, v),
        ),
      ),
  ],
)
```

### Render the cart preview

```dart
final preview = await api.cartPreview(productId, state.draftConfiguration);

Column(
  children: [
    if (preview.routingSignals.isNotEmpty)
      Wrap(
        spacing: 8,
        children: [
          for (final sig in preview.routingSignals)
            AerosRoutingSignalBadge(signal: sig),
        ],
      ),
    for (final v in preview.constraintViolations)
      AerosConstraintErrorAlert(
        messageByLocale: v.message,
        locale: app.locale,
      ),
    AerosPriceBreakdown(data: preview.breakdown),
  ],
)
```

### Wire artwork upload

`AerosFileUploadButton.onPickFile` is `Future<AerosFileRef?> Function()`. The
host app opens its file picker, uploads the bytes via the backend `Asset`
API, and returns the resolved reference:

```dart
AerosFileUploadButton(
  value: state.artwork,
  onPickFile: () async {
    final picked = await filePicker.pickFile();
    if (picked == null) return null;
    final asset = await api.uploadAsset(picked.bytes, picked.name);
    final ref = AerosFileRef(
      id: asset.id,
      name: asset.name,
      sizeBytes: asset.sizeBytes,
      mimeType: asset.mimeType,
      previewUrl: asset.previewUrl,
    );
    state.setArtwork(ref);
    return ref;
  },
  onRemove: () => state.setArtwork(null),
)
```

## Out of scope for v1

- **React parity** — the storefront frontend hasn't shipped yet. When it
  does, it'll need React versions of these components; the `@aeros/react`
  package will then add `AttributeSelector`, `VariantPicker`, etc. with the
  same intent.
- **Production-ready PDF export** of a configured spec sheet (per the plan
  §13 wishlist). The `AerosPriceBreakdown` data model already carries the
  audit trail (`modifierKey`, `modifierVersion`) needed to reconstruct the
  configuration; the PDF renderer is a downstream concern.
- **Multi-line cart configurations.** v1 renders one configuration per cart
  line. Multi-line bulk configure (the same artwork across 50 SKUs) is a v2
  follow-up.

## Related

- [Components reference](./components.md) — full inventory.
- [Tokens reference](./tokens.md) — colour ramps, typography, spacing.
- [Backend memory](https://github.com/aeros-core/aeros-backend) (`memory/configurable_mto.md`) — backend state and links to the design plan.

import 'package:flutter/foundation.dart';

/// Plain data types shared across the configurable-MTO widgets
/// (AerosAttributeSelector, AerosEnumDropdown, AerosEnumChips, AerosRangeSlider,
/// AerosMeasurementInput, AerosFileUploadButton, AerosVariantPicker,
/// AerosPriceBreakdown, AerosRoutingSignalBadge, AerosConstraintErrorAlert).
///
/// These mirror the shapes the aeros-backend `/products/:id` and
/// `/cart/preview` endpoints return — but consumers translate API responses
/// into these types so the design system depends on no API client.

/// Attribute datatype. Mirrors the backend `datatype` enum.
enum AerosAttributeDatatype { enumValue, measurement, boolean }

/// Source of options for an attribute. Mirrors `option_source` on
/// `CategoryAttributeOption`.
enum AerosAttributeOptionSource { enumOptions, range, file }

/// A single discrete option for an ENUM-source attribute (e.g. a colour, a
/// print style). The [id] is the stable key the backend stores; [label] is
/// the localized display string the consumer has already resolved from the
/// JSONB locale map.
@immutable
class AerosAttributeOption {
  const AerosAttributeOption({
    required this.id,
    required this.label,
    this.swatchColor,
    this.disabled = false,
    this.disabledReason,
  });

  final String id;
  final String label;

  /// Optional swatch colour (used by AerosEnumChips when rendering colour
  /// pickers). Hex/RGB, owned by the consumer.
  final int? swatchColor;

  final bool disabled;

  /// Localized reason shown when the option is disabled (e.g. "out of stock
  /// for this size", "blocked by your selected GSM").
  final String? disabledReason;
}

/// A measurement unit (e.g. ml, gsm, mm). Mirrors `MeasurementUnit`.
@immutable
class AerosMeasurementUnit {
  const AerosMeasurementUnit({required this.code, required this.label});

  /// Stable key (`ml`, `gsm`, `mm`).
  final String code;

  /// Localized display label (`ml`, `gsm`, `mm` — usually identical, but
  /// some units have localised names).
  final String label;
}

/// A range definition for a MEASUREMENT-source attribute.
@immutable
class AerosNumericRange {
  const AerosNumericRange({
    required this.min,
    required this.max,
    this.step = 1,
  });

  final num min;
  final num max;
  final num step;
}

/// Spec describing one attribute the buyer can configure.
///
/// The composite [AerosAttributeSelector] uses [(datatype, optionSource)] to
/// pick the right input. Consumers populate this from the
/// `/products/:id` listing-detail enrichment.
@immutable
class AerosAttributeSpec {
  const AerosAttributeSpec({
    required this.key,
    required this.label,
    required this.datatype,
    required this.optionSource,
    this.required = false,
    this.helperText,
    this.lockedByAdmin = false,
    this.options = const [],
    this.range,
    this.units = const [],
    this.defaultUnit,
  });

  /// Global attribute key (e.g. `cup_size`, `paper_weight`). Stable across
  /// sellers — used by filters and by the cart `customization_json`.
  final String key;
  final String label;
  final AerosAttributeDatatype datatype;
  final AerosAttributeOptionSource optionSource;

  final bool required;
  final String? helperText;

  /// True when the seller (or admin) has locked this attribute on this
  /// listing. Renders disabled with a lock indicator.
  final bool lockedByAdmin;

  /// Populated for ENUM sources or for MEASUREMENT + discrete chip groups.
  final List<AerosAttributeOption> options;

  /// Populated for RANGE sources.
  final AerosNumericRange? range;

  /// Available units for MEASUREMENT attributes.
  final List<AerosMeasurementUnit> units;

  /// Default unit code (must match one of [units]).
  final String? defaultUnit;
}

/// Current value of an attribute. The shape depends on [AerosAttributeSpec.datatype].
///
/// - ENUM      → [enumValueId] is the picked option id.
/// - MEASUREMENT → [numericValue] + [unitCode].
/// - BOOLEAN   → [boolValue].
/// - FILE      → [fileRef] is the asset reference (an opaque id the consumer
///   resolves against its asset upload service; the design system does not
///   manage uploads itself).
@immutable
class AerosAttributeValue {
  const AerosAttributeValue({
    this.enumValueId,
    this.numericValue,
    this.unitCode,
    this.boolValue,
    this.fileRef,
  });

  final String? enumValueId;
  final num? numericValue;
  final String? unitCode;
  final bool? boolValue;
  final AerosFileRef? fileRef;

  bool get isEmpty =>
      enumValueId == null &&
      numericValue == null &&
      boolValue == null &&
      fileRef == null;
}

/// Reference to an uploaded artwork file. Lightweight — the actual upload is
/// handled by the consumer (mobile/admin call the backend `Asset` endpoints).
@immutable
class AerosFileRef {
  const AerosFileRef({
    required this.id,
    required this.name,
    this.sizeBytes,
    this.mimeType,
    this.previewUrl,
  });

  final String id;
  final String name;
  final int? sizeBytes;
  final String? mimeType;
  final String? previewUrl;
}

// ─── Variants ────────────────────────────────────────────────────────────

/// One purchasable variant (size/colour combo) of a configurable listing.
/// Mirrors `CatalogVariant`.
@immutable
class AerosVariantOption {
  const AerosVariantOption({
    required this.id,
    required this.label,
    this.sku,
    this.swatchColor,
    this.stockQty,
    this.disabled = false,
    this.disabledReason,
  });

  final String id;
  final String label;
  final String? sku;
  final int? swatchColor;

  /// `null` ⇒ stock-tracking off (always available for MTO_CONFIG).
  /// `0`    ⇒ explicitly out of stock.
  /// `> 0`  ⇒ in stock.
  final int? stockQty;

  final bool disabled;
  final String? disabledReason;

  bool get inStock => stockQty == null || stockQty! > 0;
}

// ─── Pricing breakdown ───────────────────────────────────────────────────

/// One step in the pricing-engine output. Mirrors `BreakdownStep` from the
/// backend pricing engine (PR #93).
@immutable
class AerosBreakdownStep {
  const AerosBreakdownStep({
    required this.name,
    required this.amount,
    this.kind,
    this.modifierKey,
    this.modifierVersion,
    this.discountable = true,
    this.perUnit = false,
    this.note,
  });

  /// Display label (e.g. "GSM 250", "Printed", "Bulk discount 5%").
  final String name;

  /// Signed amount in the base currency. Negative = discount.
  final num amount;

  /// e.g. `ADD_FLAT`, `ADD_PER_UNIT`, `SETUP_FEE`, `BULK_DISCOUNT`,
  /// `BASE_PRICE`. Free-form so it works with v2/v3 modifier kinds without
  /// a DS upgrade.
  final String? kind;

  /// Stable key of the contributing PriceModifier (for audit / debugging).
  final String? modifierKey;

  /// Versioned modifier id, useful when the price has changed since a prior
  /// quote.
  final int? modifierVersion;

  /// Whether this line counts toward the discountable subtotal. Setup fees
  /// and shipping are typically `discountable: false`.
  final bool discountable;

  /// `true` ⇒ render the amount as "₹X /u". `false` ⇒ render as a flat
  /// amount.
  final bool perUnit;

  final String? note;
}

/// Complete pricing breakdown with the two subtotal buckets the engine
/// computes (`discountable_subtotal` vs `non_discountable_subtotal`).
@immutable
class AerosPriceBreakdownData {
  const AerosPriceBreakdownData({
    required this.steps,
    required this.discountableSubtotal,
    required this.nonDiscountableSubtotal,
    required this.total,
    required this.currencySymbol,
    this.quantity,
    this.unitLabel = 'u',
  });

  final List<AerosBreakdownStep> steps;
  final num discountableSubtotal;
  final num nonDiscountableSubtotal;
  final num total;

  /// e.g. '₹', '$'. Kept as a string so v1 doesn't need an i18n currency
  /// formatter inside the design system.
  final String currencySymbol;

  /// Optional quantity context — when set, per-unit lines render with this
  /// unit suffix.
  final num? quantity;
  final String unitLabel;
}

// ─── Routing signals ─────────────────────────────────────────────────────

/// One routing signal returned by the backend `cart.preview` endpoint
/// (e.g. `requires_rfq`, `requires_credit_check`). Mirrors a single entry
/// from `routing_signals TEXT[]`.
@immutable
class AerosRoutingSignal {
  const AerosRoutingSignal({
    required this.kind,
    required this.label,
    this.severity = AerosRoutingSeverity.info,
    this.detail,
  });

  /// Stable key (`requires_rfq`, `requires_credit_check`, …).
  final String kind;

  /// Localized label the buyer sees (e.g. "Quantity > 100k → request a
  /// quote").
  final String label;

  final AerosRoutingSeverity severity;

  /// Optional secondary line (used in tooltip / sheet, not in the pill).
  final String? detail;
}

/// Severity for a routing signal pill. Maps to existing semantic colour
/// ramps (info=royal, warn=amber, error=danger).
enum AerosRoutingSeverity { info, warn, error }

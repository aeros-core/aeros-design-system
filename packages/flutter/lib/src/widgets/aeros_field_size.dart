import '../foundation/aeros_control_size.dart';

export '../foundation/aeros_control_size.dart';

/// 3.0: fields and buttons share one size ladder, [AerosControlSize] — which
/// also adds `xs` and `xl`. The members this type exposed (`height`, `padH`,
/// `padV`, `radius`, `iconSize`, `valueStyle`) live on the enum itself; the
/// `AerosFieldSizeMetrics` extension is gone.
@Deprecated('Use AerosControlSize')
typedef AerosFieldSize = AerosControlSize;

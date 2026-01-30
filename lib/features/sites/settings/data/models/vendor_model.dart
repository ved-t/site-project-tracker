import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/vendor.dart';

part 'vendor_model.freezed.dart';
part 'vendor_model.g.dart';

@freezed
class VendorModel with _$VendorModel {
  const VendorModel._();
  const factory VendorModel({
    required String id,
    required String siteId,
    required String name,
    String? phone,
    String? notes,
    required DateTime createdAt,
  }) = _VendorModel;

  factory VendorModel.fromJson(Map<String, dynamic> json) =>
      _$VendorModelFromJson(json);

  factory VendorModel.fromEntity(Vendor v) => VendorModel(
        id: v.id,
        siteId: v.siteId,
        name: v.name,
        phone: v.phone,
        notes: v.notes,
        createdAt: v.createdAt,
      );

  Vendor toEntity() => Vendor(
        id: id,
        siteId: siteId,
        name: name,
        phone: phone,
        notes: notes,
        createdAt: createdAt,
      );
}

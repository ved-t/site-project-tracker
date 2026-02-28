// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) {
  return _ExpenseModel.fromJson(json);
}

/// @nodoc
mixin _$ExpenseModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'site_id')
  String get siteId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String get categoryId => throw _privateConstructorUsedError;
  String get vendor => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_payment_completed')
  bool get isPaymentCompleted => throw _privateConstructorUsedError;
  String? get remarks => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'device_id')
  String get deviceId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpenseModelCopyWith<ExpenseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseModelCopyWith<$Res> {
  factory $ExpenseModelCopyWith(
          ExpenseModel value, $Res Function(ExpenseModel) then) =
      _$ExpenseModelCopyWithImpl<$Res, ExpenseModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'site_id') String siteId,
      String title,
      double amount,
      DateTime date,
      @JsonKey(name: 'category_id') String categoryId,
      String vendor,
      @JsonKey(name: 'is_payment_completed') bool isPaymentCompleted,
      String? remarks,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      @JsonKey(name: 'device_id') String deviceId});
}

/// @nodoc
class _$ExpenseModelCopyWithImpl<$Res, $Val extends ExpenseModel>
    implements $ExpenseModelCopyWith<$Res> {
  _$ExpenseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? siteId = null,
    Object? title = null,
    Object? amount = null,
    Object? date = null,
    Object? categoryId = null,
    Object? vendor = null,
    Object? isPaymentCompleted = null,
    Object? remarks = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? deviceId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      vendor: null == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String,
      isPaymentCompleted: null == isPaymentCompleted
          ? _value.isPaymentCompleted
          : isPaymentCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseModelImplCopyWith<$Res>
    implements $ExpenseModelCopyWith<$Res> {
  factory _$$ExpenseModelImplCopyWith(
          _$ExpenseModelImpl value, $Res Function(_$ExpenseModelImpl) then) =
      __$$ExpenseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'site_id') String siteId,
      String title,
      double amount,
      DateTime date,
      @JsonKey(name: 'category_id') String categoryId,
      String vendor,
      @JsonKey(name: 'is_payment_completed') bool isPaymentCompleted,
      String? remarks,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      @JsonKey(name: 'device_id') String deviceId});
}

/// @nodoc
class __$$ExpenseModelImplCopyWithImpl<$Res>
    extends _$ExpenseModelCopyWithImpl<$Res, _$ExpenseModelImpl>
    implements _$$ExpenseModelImplCopyWith<$Res> {
  __$$ExpenseModelImplCopyWithImpl(
      _$ExpenseModelImpl _value, $Res Function(_$ExpenseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? siteId = null,
    Object? title = null,
    Object? amount = null,
    Object? date = null,
    Object? categoryId = null,
    Object? vendor = null,
    Object? isPaymentCompleted = null,
    Object? remarks = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? deviceId = null,
  }) {
    return _then(_$ExpenseModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      vendor: null == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String,
      isPaymentCompleted: null == isPaymentCompleted
          ? _value.isPaymentCompleted
          : isPaymentCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      remarks: freezed == remarks
          ? _value.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseModelImpl extends _ExpenseModel {
  const _$ExpenseModelImpl(
      {required this.id,
      @JsonKey(name: 'site_id') required this.siteId,
      required this.title,
      required this.amount,
      required this.date,
      @JsonKey(name: 'category_id') required this.categoryId,
      required this.vendor,
      @JsonKey(name: 'is_payment_completed') this.isPaymentCompleted = false,
      this.remarks,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      @JsonKey(name: 'device_id') required this.deviceId})
      : super._();

  factory _$ExpenseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'site_id')
  final String siteId;
  @override
  final String title;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  @JsonKey(name: 'category_id')
  final String categoryId;
  @override
  final String vendor;
  @override
  @JsonKey(name: 'is_payment_completed')
  final bool isPaymentCompleted;
  @override
  final String? remarks;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  @JsonKey(name: 'device_id')
  final String deviceId;

  @override
  String toString() {
    return 'ExpenseModel(id: $id, siteId: $siteId, title: $title, amount: $amount, date: $date, categoryId: $categoryId, vendor: $vendor, isPaymentCompleted: $isPaymentCompleted, remarks: $remarks, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.siteId, siteId) || other.siteId == siteId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.isPaymentCompleted, isPaymentCompleted) ||
                other.isPaymentCompleted == isPaymentCompleted) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      siteId,
      title,
      amount,
      date,
      categoryId,
      vendor,
      isPaymentCompleted,
      remarks,
      createdAt,
      updatedAt,
      deletedAt,
      deviceId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseModelImplCopyWith<_$ExpenseModelImpl> get copyWith =>
      __$$ExpenseModelImplCopyWithImpl<_$ExpenseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseModelImplToJson(
      this,
    );
  }
}

abstract class _ExpenseModel extends ExpenseModel {
  const factory _ExpenseModel(
          {required final String id,
          @JsonKey(name: 'site_id') required final String siteId,
          required final String title,
          required final double amount,
          required final DateTime date,
          @JsonKey(name: 'category_id') required final String categoryId,
          required final String vendor,
          @JsonKey(name: 'is_payment_completed') final bool isPaymentCompleted,
          final String? remarks,
          required final DateTime createdAt,
          required final DateTime updatedAt,
          final DateTime? deletedAt,
          @JsonKey(name: 'device_id') required final String deviceId}) =
      _$ExpenseModelImpl;
  const _ExpenseModel._() : super._();

  factory _ExpenseModel.fromJson(Map<String, dynamic> json) =
      _$ExpenseModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'site_id')
  String get siteId;
  @override
  String get title;
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  @JsonKey(name: 'category_id')
  String get categoryId;
  @override
  String get vendor;
  @override
  @JsonKey(name: 'is_payment_completed')
  bool get isPaymentCompleted;
  @override
  String? get remarks;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  @JsonKey(name: 'device_id')
  String get deviceId;
  @override
  @JsonKey(ignore: true)
  _$$ExpenseModelImplCopyWith<_$ExpenseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

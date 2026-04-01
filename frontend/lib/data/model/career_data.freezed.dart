// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'career_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CareerData {
  String get company => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  DateTime get joinDateTime => throw _privateConstructorUsedError;
  DateTime? get endDateTime => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<CarrerDetailData> get detailDataList =>
      throw _privateConstructorUsedError;

  /// Create a copy of CareerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CareerDataCopyWith<CareerData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CareerDataCopyWith<$Res> {
  factory $CareerDataCopyWith(
          CareerData value, $Res Function(CareerData) then) =
      _$CareerDataCopyWithImpl<$Res, CareerData>;
  @useResult
  $Res call(
      {String company,
      String imagePath,
      DateTime joinDateTime,
      DateTime? endDateTime,
      String description,
      List<CarrerDetailData> detailDataList});
}

/// @nodoc
class _$CareerDataCopyWithImpl<$Res, $Val extends CareerData>
    implements $CareerDataCopyWith<$Res> {
  _$CareerDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CareerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? imagePath = null,
    Object? joinDateTime = null,
    Object? endDateTime = freezed,
    Object? description = null,
    Object? detailDataList = null,
  }) {
    return _then(_value.copyWith(
      company: null == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      joinDateTime: null == joinDateTime
          ? _value.joinDateTime
          : joinDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDateTime: freezed == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      detailDataList: null == detailDataList
          ? _value.detailDataList
          : detailDataList // ignore: cast_nullable_to_non_nullable
              as List<CarrerDetailData>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CareerDataImplCopyWith<$Res>
    implements $CareerDataCopyWith<$Res> {
  factory _$$CareerDataImplCopyWith(
          _$CareerDataImpl value, $Res Function(_$CareerDataImpl) then) =
      __$$CareerDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String company,
      String imagePath,
      DateTime joinDateTime,
      DateTime? endDateTime,
      String description,
      List<CarrerDetailData> detailDataList});
}

/// @nodoc
class __$$CareerDataImplCopyWithImpl<$Res>
    extends _$CareerDataCopyWithImpl<$Res, _$CareerDataImpl>
    implements _$$CareerDataImplCopyWith<$Res> {
  __$$CareerDataImplCopyWithImpl(
      _$CareerDataImpl _value, $Res Function(_$CareerDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CareerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? company = null,
    Object? imagePath = null,
    Object? joinDateTime = null,
    Object? endDateTime = freezed,
    Object? description = null,
    Object? detailDataList = null,
  }) {
    return _then(_$CareerDataImpl(
      company: null == company
          ? _value.company
          : company // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      joinDateTime: null == joinDateTime
          ? _value.joinDateTime
          : joinDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDateTime: freezed == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      detailDataList: null == detailDataList
          ? _value._detailDataList
          : detailDataList // ignore: cast_nullable_to_non_nullable
              as List<CarrerDetailData>,
    ));
  }
}

/// @nodoc

class _$CareerDataImpl implements _CareerData {
  const _$CareerDataImpl(
      {required this.company,
      required this.imagePath,
      required this.joinDateTime,
      this.endDateTime,
      required this.description,
      required final List<CarrerDetailData> detailDataList})
      : _detailDataList = detailDataList;

  @override
  final String company;
  @override
  final String imagePath;
  @override
  final DateTime joinDateTime;
  @override
  final DateTime? endDateTime;
  @override
  final String description;
  final List<CarrerDetailData> _detailDataList;
  @override
  List<CarrerDetailData> get detailDataList {
    if (_detailDataList is EqualUnmodifiableListView) return _detailDataList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_detailDataList);
  }

  @override
  String toString() {
    return 'CareerData(company: $company, imagePath: $imagePath, joinDateTime: $joinDateTime, endDateTime: $endDateTime, description: $description, detailDataList: $detailDataList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CareerDataImpl &&
            (identical(other.company, company) || other.company == company) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.joinDateTime, joinDateTime) ||
                other.joinDateTime == joinDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._detailDataList, _detailDataList));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      company,
      imagePath,
      joinDateTime,
      endDateTime,
      description,
      const DeepCollectionEquality().hash(_detailDataList));

  /// Create a copy of CareerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CareerDataImplCopyWith<_$CareerDataImpl> get copyWith =>
      __$$CareerDataImplCopyWithImpl<_$CareerDataImpl>(this, _$identity);
}

abstract class _CareerData implements CareerData {
  const factory _CareerData(
      {required final String company,
      required final String imagePath,
      required final DateTime joinDateTime,
      final DateTime? endDateTime,
      required final String description,
      required final List<CarrerDetailData> detailDataList}) = _$CareerDataImpl;

  @override
  String get company;
  @override
  String get imagePath;
  @override
  DateTime get joinDateTime;
  @override
  DateTime? get endDateTime;
  @override
  String get description;
  @override
  List<CarrerDetailData> get detailDataList;

  /// Create a copy of CareerData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CareerDataImplCopyWith<_$CareerDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CarrerDetailData {
  String get title => throw _privateConstructorUsedError;
  DateTime get startDateTime => throw _privateConstructorUsedError;
  DateTime? get endDateTime => throw _privateConstructorUsedError;
  String get appDescription => throw _privateConstructorUsedError;
  List<String> get screenshots => throw _privateConstructorUsedError;
  List<String> get skills => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;
  List<String> get tasks => throw _privateConstructorUsedError;
  List<String> get issues => throw _privateConstructorUsedError;
  String? get playStoreLink => throw _privateConstructorUsedError;
  String? get appStoreLink => throw _privateConstructorUsedError;
  int get downloadCount => throw _privateConstructorUsedError;
  int get userCount => throw _privateConstructorUsedError;

  /// Create a copy of CarrerDetailData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CarrerDetailDataCopyWith<CarrerDetailData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CarrerDetailDataCopyWith<$Res> {
  factory $CarrerDetailDataCopyWith(
          CarrerDetailData value, $Res Function(CarrerDetailData) then) =
      _$CarrerDetailDataCopyWithImpl<$Res, CarrerDetailData>;
  @useResult
  $Res call(
      {String title,
      DateTime startDateTime,
      DateTime? endDateTime,
      String appDescription,
      List<String> screenshots,
      List<String> skills,
      List<String> features,
      List<String> tasks,
      List<String> issues,
      String? playStoreLink,
      String? appStoreLink,
      int downloadCount,
      int userCount});
}

/// @nodoc
class _$CarrerDetailDataCopyWithImpl<$Res, $Val extends CarrerDetailData>
    implements $CarrerDetailDataCopyWith<$Res> {
  _$CarrerDetailDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CarrerDetailData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? startDateTime = null,
    Object? endDateTime = freezed,
    Object? appDescription = null,
    Object? screenshots = null,
    Object? skills = null,
    Object? features = null,
    Object? tasks = null,
    Object? issues = null,
    Object? playStoreLink = freezed,
    Object? appStoreLink = freezed,
    Object? downloadCount = null,
    Object? userCount = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDateTime: null == startDateTime
          ? _value.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDateTime: freezed == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      appDescription: null == appDescription
          ? _value.appDescription
          : appDescription // ignore: cast_nullable_to_non_nullable
              as String,
      screenshots: null == screenshots
          ? _value.screenshots
          : screenshots // ignore: cast_nullable_to_non_nullable
              as List<String>,
      skills: null == skills
          ? _value.skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tasks: null == tasks
          ? _value.tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      issues: null == issues
          ? _value.issues
          : issues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      playStoreLink: freezed == playStoreLink
          ? _value.playStoreLink
          : playStoreLink // ignore: cast_nullable_to_non_nullable
              as String?,
      appStoreLink: freezed == appStoreLink
          ? _value.appStoreLink
          : appStoreLink // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CarrerDetailDataImplCopyWith<$Res>
    implements $CarrerDetailDataCopyWith<$Res> {
  factory _$$CarrerDetailDataImplCopyWith(_$CarrerDetailDataImpl value,
          $Res Function(_$CarrerDetailDataImpl) then) =
      __$$CarrerDetailDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      DateTime startDateTime,
      DateTime? endDateTime,
      String appDescription,
      List<String> screenshots,
      List<String> skills,
      List<String> features,
      List<String> tasks,
      List<String> issues,
      String? playStoreLink,
      String? appStoreLink,
      int downloadCount,
      int userCount});
}

/// @nodoc
class __$$CarrerDetailDataImplCopyWithImpl<$Res>
    extends _$CarrerDetailDataCopyWithImpl<$Res, _$CarrerDetailDataImpl>
    implements _$$CarrerDetailDataImplCopyWith<$Res> {
  __$$CarrerDetailDataImplCopyWithImpl(_$CarrerDetailDataImpl _value,
      $Res Function(_$CarrerDetailDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of CarrerDetailData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? startDateTime = null,
    Object? endDateTime = freezed,
    Object? appDescription = null,
    Object? screenshots = null,
    Object? skills = null,
    Object? features = null,
    Object? tasks = null,
    Object? issues = null,
    Object? playStoreLink = freezed,
    Object? appStoreLink = freezed,
    Object? downloadCount = null,
    Object? userCount = null,
  }) {
    return _then(_$CarrerDetailDataImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      startDateTime: null == startDateTime
          ? _value.startDateTime
          : startDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDateTime: freezed == endDateTime
          ? _value.endDateTime
          : endDateTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      appDescription: null == appDescription
          ? _value.appDescription
          : appDescription // ignore: cast_nullable_to_non_nullable
              as String,
      screenshots: null == screenshots
          ? _value._screenshots
          : screenshots // ignore: cast_nullable_to_non_nullable
              as List<String>,
      skills: null == skills
          ? _value._skills
          : skills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tasks: null == tasks
          ? _value._tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<String>,
      issues: null == issues
          ? _value._issues
          : issues // ignore: cast_nullable_to_non_nullable
              as List<String>,
      playStoreLink: freezed == playStoreLink
          ? _value.playStoreLink
          : playStoreLink // ignore: cast_nullable_to_non_nullable
              as String?,
      appStoreLink: freezed == appStoreLink
          ? _value.appStoreLink
          : appStoreLink // ignore: cast_nullable_to_non_nullable
              as String?,
      downloadCount: null == downloadCount
          ? _value.downloadCount
          : downloadCount // ignore: cast_nullable_to_non_nullable
              as int,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$CarrerDetailDataImpl implements _CarrerDetailData {
  const _$CarrerDetailDataImpl(
      {required this.title,
      required this.startDateTime,
      this.endDateTime,
      required this.appDescription,
      final List<String> screenshots = const [],
      final List<String> skills = const [],
      final List<String> features = const [],
      final List<String> tasks = const [],
      final List<String> issues = const [],
      this.playStoreLink,
      this.appStoreLink,
      this.downloadCount = 0,
      this.userCount = 0})
      : _screenshots = screenshots,
        _skills = skills,
        _features = features,
        _tasks = tasks,
        _issues = issues;

  @override
  final String title;
  @override
  final DateTime startDateTime;
  @override
  final DateTime? endDateTime;
  @override
  final String appDescription;
  final List<String> _screenshots;
  @override
  @JsonKey()
  List<String> get screenshots {
    if (_screenshots is EqualUnmodifiableListView) return _screenshots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_screenshots);
  }

  final List<String> _skills;
  @override
  @JsonKey()
  List<String> get skills {
    if (_skills is EqualUnmodifiableListView) return _skills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skills);
  }

  final List<String> _features;
  @override
  @JsonKey()
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  final List<String> _tasks;
  @override
  @JsonKey()
  List<String> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  final List<String> _issues;
  @override
  @JsonKey()
  List<String> get issues {
    if (_issues is EqualUnmodifiableListView) return _issues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_issues);
  }

  @override
  final String? playStoreLink;
  @override
  final String? appStoreLink;
  @override
  @JsonKey()
  final int downloadCount;
  @override
  @JsonKey()
  final int userCount;

  @override
  String toString() {
    return 'CarrerDetailData(title: $title, startDateTime: $startDateTime, endDateTime: $endDateTime, appDescription: $appDescription, screenshots: $screenshots, skills: $skills, features: $features, tasks: $tasks, issues: $issues, playStoreLink: $playStoreLink, appStoreLink: $appStoreLink, downloadCount: $downloadCount, userCount: $userCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CarrerDetailDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.appDescription, appDescription) ||
                other.appDescription == appDescription) &&
            const DeepCollectionEquality()
                .equals(other._screenshots, _screenshots) &&
            const DeepCollectionEquality().equals(other._skills, _skills) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks) &&
            const DeepCollectionEquality().equals(other._issues, _issues) &&
            (identical(other.playStoreLink, playStoreLink) ||
                other.playStoreLink == playStoreLink) &&
            (identical(other.appStoreLink, appStoreLink) ||
                other.appStoreLink == appStoreLink) &&
            (identical(other.downloadCount, downloadCount) ||
                other.downloadCount == downloadCount) &&
            (identical(other.userCount, userCount) ||
                other.userCount == userCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      startDateTime,
      endDateTime,
      appDescription,
      const DeepCollectionEquality().hash(_screenshots),
      const DeepCollectionEquality().hash(_skills),
      const DeepCollectionEquality().hash(_features),
      const DeepCollectionEquality().hash(_tasks),
      const DeepCollectionEquality().hash(_issues),
      playStoreLink,
      appStoreLink,
      downloadCount,
      userCount);

  /// Create a copy of CarrerDetailData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CarrerDetailDataImplCopyWith<_$CarrerDetailDataImpl> get copyWith =>
      __$$CarrerDetailDataImplCopyWithImpl<_$CarrerDetailDataImpl>(
          this, _$identity);
}

abstract class _CarrerDetailData implements CarrerDetailData {
  const factory _CarrerDetailData(
      {required final String title,
      required final DateTime startDateTime,
      final DateTime? endDateTime,
      required final String appDescription,
      final List<String> screenshots,
      final List<String> skills,
      final List<String> features,
      final List<String> tasks,
      final List<String> issues,
      final String? playStoreLink,
      final String? appStoreLink,
      final int downloadCount,
      final int userCount}) = _$CarrerDetailDataImpl;

  @override
  String get title;
  @override
  DateTime get startDateTime;
  @override
  DateTime? get endDateTime;
  @override
  String get appDescription;
  @override
  List<String> get screenshots;
  @override
  List<String> get skills;
  @override
  List<String> get features;
  @override
  List<String> get tasks;
  @override
  List<String> get issues;
  @override
  String? get playStoreLink;
  @override
  String? get appStoreLink;
  @override
  int get downloadCount;
  @override
  int get userCount;

  /// Create a copy of CarrerDetailData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CarrerDetailDataImplCopyWith<_$CarrerDetailDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

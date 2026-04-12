// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_file_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$courseFilesHash() => r'5e787b62df4f6cfd35f8cac5e3b822deffa11ac4';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [courseFiles].
@ProviderFor(courseFiles)
const courseFilesProvider = CourseFilesFamily();

/// See also [courseFiles].
class CourseFilesFamily extends Family<AsyncValue<List<CourseFileModel>>> {
  /// See also [courseFiles].
  const CourseFilesFamily();

  /// See also [courseFiles].
  CourseFilesProvider call(
    String courseCode,
  ) {
    return CourseFilesProvider(
      courseCode,
    );
  }

  @override
  CourseFilesProvider getProviderOverride(
    covariant CourseFilesProvider provider,
  ) {
    return call(
      provider.courseCode,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'courseFilesProvider';
}

/// See also [courseFiles].
class CourseFilesProvider
    extends AutoDisposeStreamProvider<List<CourseFileModel>> {
  /// See also [courseFiles].
  CourseFilesProvider(
    String courseCode,
  ) : this._internal(
          (ref) => courseFiles(
            ref as CourseFilesRef,
            courseCode,
          ),
          from: courseFilesProvider,
          name: r'courseFilesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$courseFilesHash,
          dependencies: CourseFilesFamily._dependencies,
          allTransitiveDependencies:
              CourseFilesFamily._allTransitiveDependencies,
          courseCode: courseCode,
        );

  CourseFilesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseCode,
  }) : super.internal();

  final String courseCode;

  @override
  Override overrideWith(
    Stream<List<CourseFileModel>> Function(CourseFilesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CourseFilesProvider._internal(
        (ref) => create(ref as CourseFilesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseCode: courseCode,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CourseFileModel>> createElement() {
    return _CourseFilesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CourseFilesProvider && other.courseCode == courseCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CourseFilesRef on AutoDisposeStreamProviderRef<List<CourseFileModel>> {
  /// The parameter `courseCode` of this provider.
  String get courseCode;
}

class _CourseFilesProviderElement
    extends AutoDisposeStreamProviderElement<List<CourseFileModel>>
    with CourseFilesRef {
  _CourseFilesProviderElement(super.provider);

  @override
  String get courseCode => (origin as CourseFilesProvider).courseCode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

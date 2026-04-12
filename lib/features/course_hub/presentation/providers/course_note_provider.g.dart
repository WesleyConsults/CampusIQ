// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_note_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$courseNotesHash() => r'a5bca1d2aa6a3e19e82fca43bd8a86241990dfc1';

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

/// See also [courseNotes].
@ProviderFor(courseNotes)
const courseNotesProvider = CourseNotesFamily();

/// See also [courseNotes].
class CourseNotesFamily extends Family<AsyncValue<List<CourseNoteModel>>> {
  /// See also [courseNotes].
  const CourseNotesFamily();

  /// See also [courseNotes].
  CourseNotesProvider call(
    String courseCode,
  ) {
    return CourseNotesProvider(
      courseCode,
    );
  }

  @override
  CourseNotesProvider getProviderOverride(
    covariant CourseNotesProvider provider,
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
  String? get name => r'courseNotesProvider';
}

/// See also [courseNotes].
class CourseNotesProvider
    extends AutoDisposeStreamProvider<List<CourseNoteModel>> {
  /// See also [courseNotes].
  CourseNotesProvider(
    String courseCode,
  ) : this._internal(
          (ref) => courseNotes(
            ref as CourseNotesRef,
            courseCode,
          ),
          from: courseNotesProvider,
          name: r'courseNotesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$courseNotesHash,
          dependencies: CourseNotesFamily._dependencies,
          allTransitiveDependencies:
              CourseNotesFamily._allTransitiveDependencies,
          courseCode: courseCode,
        );

  CourseNotesProvider._internal(
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
    Stream<List<CourseNoteModel>> Function(CourseNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CourseNotesProvider._internal(
        (ref) => create(ref as CourseNotesRef),
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
  AutoDisposeStreamProviderElement<List<CourseNoteModel>> createElement() {
    return _CourseNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CourseNotesProvider && other.courseCode == courseCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CourseNotesRef on AutoDisposeStreamProviderRef<List<CourseNoteModel>> {
  /// The parameter `courseCode` of this provider.
  String get courseCode;
}

class _CourseNotesProviderElement
    extends AutoDisposeStreamProviderElement<List<CourseNoteModel>>
    with CourseNotesRef {
  _CourseNotesProviderElement(super.provider);

  @override
  String get courseCode => (origin as CourseNotesProvider).courseCode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

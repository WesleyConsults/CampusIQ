import 'package:campusiq/core/domain/grading_system.dart';

class University {
  final String name;
  final String gradingSystemId;
  final String? location;
  final String? shortName;
  final String? logoAssetPath;
  final bool logoNeedsDarkBackground;

  const University({
    required this.name,
    required this.gradingSystemId,
    this.location,
    this.shortName,
    this.logoAssetPath,
    this.logoNeedsDarkBackground = false,
  });

  GradingSystem get gradingSystem => GradingSystem.byId(gradingSystemId);
}

/// All Ghanaian universities mapped to their default grading system.
///
/// Sources:
///   - KNUST & UMaT: CWA (0–100 weighted average)
///   - Most public universities: GPA 4.0
///   - GIMPA: GPA 4.0 with distinct A+/A/B+/B/C+/C/D+/D/F scale
///   - Several private universities: CGPA 5.0

const ghanaianUniversities = <University>[
  // ── CWA system ───────────────────────────────────────────────────────────
  University(
    name: 'KNUST',
    gradingSystemId: 'cwa',
    location: 'Kumasi',
    shortName: 'Kwame Nkrumah University of Science and Technology',
    logoAssetPath: 'assets/images/universities/knust.png',
  ),
  University(
    name: 'UMaT',
    gradingSystemId: 'cwa',
    location: 'Tarkwa',
    shortName: 'University of Mines and Technology',
    logoAssetPath: 'assets/images/universities/umat.png',
    logoNeedsDarkBackground: true,
  ),

  // ── GPA 4.0 (Standard) ───────────────────────────────────────────────────
  University(
    name: 'University of Ghana',
    gradingSystemId: 'gpa_4pt',
    location: 'Legon, Accra',
    shortName: 'Legon',
    logoAssetPath: 'assets/images/universities/university_of_ghana.png',
    logoNeedsDarkBackground: true,
  ),
  University(
    name: 'University of Cape Coast',
    gradingSystemId: 'gpa_4pt',
    location: 'Cape Coast',
    shortName: 'UCC',
    logoAssetPath: 'assets/images/universities/university_of_cape_coast.png',
  ),
  University(
    name: 'University of Education, Winneba',
    gradingSystemId: 'gpa_4pt',
    location: 'Winneba',
    shortName: 'UEW',
    logoAssetPath: 'assets/images/universities/uew.png',
  ),
  University(
    name: 'University for Development Studies',
    gradingSystemId: 'gpa_4pt',
    location: 'Tamale',
    shortName: 'UDS',
    logoAssetPath:
        'assets/images/universities/university_for_development_studies.png',
  ),
  University(
    name: 'UPSA',
    gradingSystemId: 'gpa_4pt',
    location: 'Accra',
    shortName: 'University of Professional Studies, Accra',
    logoAssetPath: 'assets/images/universities/upsa.png',
    logoNeedsDarkBackground: true,
  ),
  University(
    name: 'UENR',
    gradingSystemId: 'gpa_4pt',
    location: 'Sunyani',
    shortName: 'University of Energy and Natural Resources',
    logoAssetPath: 'assets/images/universities/uenr.png',
  ),
  University(
    name: 'SD Dombo University',
    gradingSystemId: 'gpa_4pt',
    location: 'Wa',
    shortName: 'SD Dombo University of Business',
    logoAssetPath: 'assets/images/universities/sd_dombo_university.png',
  ),
  University(
    name: 'CKT-UTAS',
    gradingSystemId: 'gpa_4pt',
    location: 'Navrongo',
    shortName: 'C.K. Tedam University',
    logoAssetPath: 'assets/images/universities/ckt_utas.png',
  ),
  University(
    name: 'UniMAC',
    gradingSystemId: 'gpa_4pt',
    location: 'Accra',
    shortName: 'University of Media, Arts and Communication',
    logoAssetPath: 'assets/images/universities/unimac.png',
  ),
  University(
    name: 'AAMUSTED',
    gradingSystemId: 'gpa_4pt',
    location: 'Kumasi',
    shortName: 'Akenten Appiah-Menka University',
    logoAssetPath: 'assets/images/universities/aamusted.png',
  ),
  University(
    name: 'Ghana Institute of Journalism',
    gradingSystemId: 'gpa_4pt',
    location: 'Accra',
    shortName: 'GIJ',
    logoAssetPath:
        'assets/images/universities/ghana_institute_of_journalism.png',
  ),
  University(
    name: 'Ghana Institute of Languages',
    gradingSystemId: 'gpa_4pt',
    location: 'Accra',
    shortName: 'GIL',
    logoAssetPath:
        'assets/images/universities/ghana_institute_of_languages.png',
  ),

  // ── GPA 4.0 (GIMPA variant) ──────────────────────────────────────────────
  University(
    name: 'GIMPA',
    gradingSystemId: 'gpa_4pt_gimpa',
    location: 'Accra',
    shortName: 'Ghana Institute of Management and Public Administration',
    logoAssetPath: 'assets/images/universities/gimpa.png',
    logoNeedsDarkBackground: true,
  ),

  // ── CGPA 5.0 ─────────────────────────────────────────────────────────────
  University(
    name: 'Central University',
    gradingSystemId: 'cgpa_5pt',
    location: 'Accra',
    logoAssetPath: 'assets/images/universities/central_university.png',
  ),
  University(
    name: 'Valley View University',
    gradingSystemId: 'cgpa_5pt',
    location: 'Accra',
    shortName: 'VVU',
    logoAssetPath: 'assets/images/universities/valley_view_university.png',
  ),
  University(
    name: 'Pentecost University',
    gradingSystemId: 'cgpa_5pt',
    location: 'Accra',
    logoAssetPath: 'assets/images/universities/pentecost_university.png',
  ),
  University(
    name: 'All Nations University',
    gradingSystemId: 'cgpa_5pt',
    location: 'Koforidua',
    logoAssetPath: 'assets/images/universities/all_nations_university.png',
  ),
  University(
    name: 'Academic City University',
    gradingSystemId: 'cgpa_5pt',
    location: 'Accra',
    logoAssetPath: 'assets/images/universities/academic_city_university.png',
  ),
  University(
    name: 'Ashesi University',
    gradingSystemId: 'cgpa_5pt',
    location: 'Berekuso',
    logoAssetPath: 'assets/images/universities/ashesi_university.png',
  ),
];

const otherUniversity = University(
  name: 'Other',
  gradingSystemId: 'cwa',
  location: null,
  shortName: null,
);

/// Full list including "Other" for the onboarding picker.
const universityPickerOptions = [...ghanaianUniversities, otherUniversity];

University universityByName(String name) {
  for (final uni in ghanaianUniversities) {
    if (uni.name == name) return uni;
  }
  return otherUniversity;
}

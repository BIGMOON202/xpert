

enum Gender {
  male,
  female
}


enum MeasurementSystem {
  imperial,
  metric
}

extension GenderExtension on Gender {
   String get friendsModeVideoName {
    switch (this) {
      case Gender.male:
        return 'Male_Friend_Widget.mp4';

      case Gender.female:
        return 'Female_Friend_Widget.mp4';
    }
}
}
//
class MeasurementModel {

  UserType userType;
  Gender gender = Gender.male;

  MeasurementModel(Gender gen, UserType userType) {
    this.gender = gen;
    this.userType = userType;
  }
}

enum UserType {
  endWearer,
  salesRep
}

extension UserTypeExtension on UserType {

  String unselectedImageName() {
    switch (this) {
      case UserType.salesRep: return 'ic_salesRep_gray.png';
      case UserType.endWearer: return 'ic_endWearer.png';
    }
  }

  String selectedImageName() {
    switch (this) {
      case UserType.salesRep: return 'ic_salesRep_blue.png';
      case UserType.endWearer: return 'ic_endWearer_blue.png';
    }
  }

  String displayName() {
    switch (this) {
      case UserType.salesRep: return 'sales rep';
      case UserType.endWearer: return 'end-wearer';
    }
  }
}


enum PhotoType {
  front,
  side
}

extension PhotoTypeExtension on PhotoType {
  String rulesImageNameFor({Gender gender}) {
    switch (this) {
      case PhotoType.front:
        return gender == Gender.male ? 'howToTakeFront_male.png' : 'howToTakeFront_female.png';
      case PhotoType.side:
        return gender == Gender.male ? 'howToTakeSide_male.png' : 'howToTakeSide_female.png';
    }
  }
}

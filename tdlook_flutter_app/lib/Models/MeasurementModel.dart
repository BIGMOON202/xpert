

enum Gender {
  male,
  female
}


enum MeasurementSystem {
  imperial,
  metric
}

extension GenderExtension on Gender {

  String get handsFreeModeVideoName {
    switch (this) {
      case Gender.male:
        return 'Male_Hands_Free.mp4';

      case Gender.female:
        return 'Female_Hands_Free.mp4';
    }
  }

   String get friendsModeVideoName {
    switch (this) {
      case Gender.male:
        return 'Male_Friend_Widget.mp4';

      case Gender.female:
        return 'Female_Friend_Widget.mp4';
    }
  }

   String unselectedImageName() {
     switch (this) {
       case Gender.male: return 'ic_male_gray.png';
       case Gender.female: return 'ic_female_unselected.png';
     }
   }

   String selectedImageName() {
     switch (this) {
       case Gender.male: return 'ic_male_selected.png';
       case Gender.female: return 'ic_female_blue.png';
     }
   }

  String apiFlag() {
    switch (this) {
      case Gender.male: return 'male';
      case Gender.female: return 'female';
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
  String menuImageName() {
    switch (this) {
      case UserType.salesRep: return 'ic_sales_rep_menu.png';
      case UserType.endWearer: return 'ic_end_wearer_menu.png';
    }
  }

  String displayName() {
    switch (this) {
      case UserType.salesRep: return 'sales rep';
      case UserType.endWearer: return 'end-wearer';
    }
  }
}

enum CompanyType {
  uniforms, //Flying cross/Vertx/FH
  armor //SL
}

extension CompanyTypeExtension on CompanyType {

  String apiKey() {
    switch (this) {
      case CompanyType.uniforms: return 'FH';
      case CompanyType.armor: return 'SL';
    }
  }

  String unselectedImageName() {
    switch (this) {
      case CompanyType.uniforms: return 'ic_uniforms.png';
      case CompanyType.armor: return 'ic_armor.png';
    }
  }

  String selectedImageName() {
    switch (this) {
      case CompanyType.uniforms: return 'ic_uniforms_selected.png';
      case CompanyType.armor: return 'ic_armor_selected.png';
    }
  }
}

enum CaptureMode {
  withFriend,
  handsFree
}

extension CaptureModeExtension on CaptureMode {
  String selectedImageName({Gender gender}) {
    switch (this) {
      case CaptureMode.withFriend: return 'ic_friends_mode_selected.png';
      case CaptureMode.handsFree: return gender.selectedImageName() ?? '';
    }
  }
  String unselectedImageName({Gender gender}) {
    switch (this) {
      case CaptureMode.withFriend: return 'ic_friends_mode_unselected.png';
      case CaptureMode.handsFree: return gender.unselectedImageName() ?? '';
    }
  }
}

enum PhotoType {
  front,
  side
}

extension PhotoTypeExtension on PhotoType {

  String name() {
    switch (this) {
      case PhotoType.front:
        return 'front';
      case PhotoType.side:
        return 'side';
    }
  }

  String rulesImageNameFor({Gender gender, CaptureMode captureMode}) {
    if (captureMode == CaptureMode.withFriend) {
      switch (this) {
        case PhotoType.front:
          return gender == Gender.male ? 'howToTakeFront_male.png' : 'howToTakeFront_female.png';
        case PhotoType.side:
          return gender == Gender.male ? 'howToTakeSide_male.png' : 'howToTakeSide_female.png';
      }
    } else {
      switch (this) {
        case PhotoType.front:
          return gender == Gender.male ? 'how_take_male_front_hadsfree.png' : 'how_take_female_front_hadsfree.png';
        case PhotoType.side:
          return gender == Gender.male ? 'how_take_male_side_hadsfree.png' : 'how_take_female_side_hadsfree.png';
      }
    }

  }
}

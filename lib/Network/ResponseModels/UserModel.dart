import 'package:flutter/foundation.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/utilt/logger.dart';

enum UserRole { dealer, end_wearer, sales_rep }

class User {
  int? id;
  String? uuid;
  String? role;
  String? status;
  Company? company;
  CompanyType? provider;
  String? email;
  String? phone;
  String? firstName;
  String? lastName;
  String? name;
  Parent? parent;
  String? country;
  String? state;
  String? city;
  String? street;
  String? zip;
  String? passwordChangedAt;
  List<String>? permissions;
  bool? is_terms_accepted;
  String? terms_accepted_at;

  User({
    this.id,
    this.uuid,
    this.role,
    this.status,
    this.company,
    this.provider,
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
    this.name,
    this.parent,
    this.country,
    this.state,
    this.city,
    this.street,
    this.zip,
    this.passwordChangedAt,
    this.permissions,
    this.is_terms_accepted,
    this.terms_accepted_at,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    role = json['role'];
    status = json['status'];
    var companyInfo = json['company'];
    if (companyInfo != null) {
      if (companyInfo is String) {
        company = Company(name: companyInfo);
      } else if (companyInfo is int) {
        company = Company(name: companyInfo.toString());
      } else {
        company = new Company.fromJson(json['company']);
      }
    }
    if (json['provider'] != null) {
      provider = json['provider'] == 'FH'
          ? CompanyType.uniforms
          : json['provider'] == 'SL'
              ? CompanyType.armor
              : null;
    }
    email = json['email'];
    phone = json['phone'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    parent = json['parent'] != null ? new Parent.fromJson(json['parent']) : null;
    country = json['country'];
    state = json['state'];
    city = json['city'];
    street = json['street'];
    zip = json['zip'];
    passwordChangedAt = json['password_changed_at'];
    json['permissions'] != null
        ? permissions = json['permissions'].cast<String>()
        : permissions = [];
    is_terms_accepted = json['is_terms_accepted'];
    terms_accepted_at = json['terms_accepted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['role'] = this.role;
    data['status'] = this.status;
    data['company'] = this.company;
    // data['provider'] = this.provider;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    if (this.parent != null) {
      data['parent'] = this.parent?.toJson();
    }
    data['country'] = this.country;
    data['state'] = this.state;
    data['city'] = this.city;
    data['street'] = this.street;
    data['zip'] = this.zip;
    data['password_changed_at'] = this.passwordChangedAt;
    data['permissions'] = this.permissions;
    return data;
  }

  String userFullName() {
    logger.d('$firstName $lastName');
    if (this.name != null) {
      return this.name!;
    } else {
      var name = '';
      if (this.firstName != null) {
        name = '${this.firstName} ';
      }

      if (this.lastName != null) {
        name += this.lastName!;
      }
      return name;
    }
  }
}

class Company {
  int? id;
  String? name;

  Company({this.id, this.name});

  Company.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class Parent {
  int? id;
  String? firstName;
  String? lastName;
  Company? company;
  String? provider;
  String? role;

  Parent({
    this.id,
    this.firstName,
    this.lastName,
    this.company,
    this.provider,
    this.role,
  });

  Parent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    var companyInfo = json['company'];
    if (companyInfo != null) {
      if (companyInfo is String) {
        company = Company(name: companyInfo);
      } else if (companyInfo is int) {
        company = Company(name: companyInfo.toString());
      } else {
        company = new Company.fromJson(json['company']);
      }
    }
    provider = json['provider'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['company'] = this.company;
    data['provider'] = this.provider;
    data['role'] = this.role;
    return data;
  }
}

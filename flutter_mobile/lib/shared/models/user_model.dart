import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String? id;
  final String? userName;
  final String? email;
  final String? name;
  final String? surname;
  final String? phoneNumber;
  final bool? isActive;
  final List<String>? roles;
  final Map<String, dynamic>? extraProperties;

  UserModel({
    this.id,
    this.userName,
    this.email,
    this.name,
    this.surname,
    this.phoneNumber,
    this.isActive,
    this.roles,
    this.extraProperties,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get displayName {
    if (name != null && surname != null) {
      return '$name $surname';
    }
    if (name != null) {
      return name!;
    }
    if (userName != null) {
      return userName!;
    }
    return email ?? 'Unknown User';
  }

  String get displayInitials {
    if (name != null && surname != null) {
      return '${name!.substring(0, 1)}${surname!.substring(0, 1)}'.toUpperCase();
    }
    if (name != null) {
      return name!.substring(0, 2).toUpperCase();
    }
    if (userName != null) {
      return userName!.substring(0, 2).toUpperCase();
    }
    return 'UN';
  }

  bool get hasRole => roles != null && roles!.isNotEmpty;

  bool hasRoleByName(String roleName) {
    return roles?.contains(roleName) ?? false;
  }

  // Common role checks for restaurant staff
  bool get isOwner => hasRoleByName('Owner');
  bool get isManager => hasRoleByName('Manager');
  bool get isCashier => hasRoleByName('Cashier');
  bool get isKitchenStaff => hasRoleByName('KitchenStaff');
  bool get isWaitstaff => hasRoleByName('Waitstaff');

  // Permission checks
  bool get canManageOrders => isOwner || isManager || isCashier || isWaitstaff;
  bool get canManageReservations => isOwner || isManager || isWaitstaff;
  bool get canManageTakeaway => isOwner || isManager || isCashier;
  bool get canViewReports => isOwner || isManager;
  bool get canManageMenu => isOwner || isManager;
  bool get canManageInventory => isOwner || isManager;

  UserModel copyWith({
    String? id,
    String? userName,
    String? email,
    String? name,
    String? surname,
    String? phoneNumber,
    bool? isActive,
    List<String>? roles,
    Map<String, dynamic>? extraProperties,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      roles: roles ?? this.roles,
      extraProperties: extraProperties ?? this.extraProperties,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, userName: $userName, email: $email, name: $name, surname: $surname, roles: $roles)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
      other.id == id &&
      other.userName == userName &&
      other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userName.hashCode ^
      email.hashCode;
  }
}
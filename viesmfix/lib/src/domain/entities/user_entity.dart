import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;
  final Map<String, dynamic>? preferences;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    this.bio,
    this.createdAt,
    this.preferences,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    avatarUrl,
    bio,
    createdAt,
    preferences,
  ];
}

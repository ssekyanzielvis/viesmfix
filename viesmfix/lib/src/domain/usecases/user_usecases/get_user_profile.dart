import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

/// Use case for getting user profile
class GetUserProfile {
  final UserRepository repository;

  GetUserProfile(this.repository);

  Future<UserEntity> execute(String userId) async {
    return await repository.getUserProfile(userId);
  }
}

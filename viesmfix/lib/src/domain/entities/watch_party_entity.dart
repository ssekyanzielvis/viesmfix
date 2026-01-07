import 'package:equatable/equatable.dart';

/// Entity representing a synchronized watch party
class WatchPartyEntity extends Equatable {
  final String id;
  final String hostUserId;
  final String hostUsername;
  final int movieId;
  final String movieTitle;
  final String? moviePosterPath;
  final List<PartyMember> members;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final WatchPartyStatus status;
  final int currentTimestamp; // in seconds
  final bool isPlaying;
  final String? inviteCode;

  const WatchPartyEntity({
    required this.id,
    required this.hostUserId,
    required this.hostUsername,
    required this.movieId,
    required this.movieTitle,
    this.moviePosterPath,
    required this.members,
    required this.createdAt,
    this.scheduledFor,
    required this.status,
    this.currentTimestamp = 0,
    this.isPlaying = false,
    this.inviteCode,
  });

  @override
  List<Object?> get props => [
    id,
    hostUserId,
    hostUsername,
    movieId,
    movieTitle,
    moviePosterPath,
    members,
    createdAt,
    scheduledFor,
    status,
    currentTimestamp,
    isPlaying,
    inviteCode,
  ];

  WatchPartyEntity copyWith({
    String? id,
    String? hostUserId,
    String? hostUsername,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    List<PartyMember>? members,
    DateTime? createdAt,
    DateTime? scheduledFor,
    WatchPartyStatus? status,
    int? currentTimestamp,
    bool? isPlaying,
    String? inviteCode,
  }) {
    return WatchPartyEntity(
      id: id ?? this.id,
      hostUserId: hostUserId ?? this.hostUserId,
      hostUsername: hostUsername ?? this.hostUsername,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      status: status ?? this.status,
      currentTimestamp: currentTimestamp ?? this.currentTimestamp,
      isPlaying: isPlaying ?? this.isPlaying,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}

/// Status of watch party
enum WatchPartyStatus { scheduled, active, paused, ended }

/// Member of a watch party
class PartyMember extends Equatable {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime joinedAt;
  final bool isOnline;
  final int? currentTimestamp;

  const PartyMember({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.joinedAt,
    required this.isOnline,
    this.currentTimestamp,
  });

  @override
  List<Object?> get props => [
    userId,
    username,
    avatarUrl,
    joinedAt,
    isOnline,
    currentTimestamp,
  ];

  PartyMember copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    DateTime? joinedAt,
    bool? isOnline,
    int? currentTimestamp,
  }) {
    return PartyMember(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt ?? this.joinedAt,
      isOnline: isOnline ?? this.isOnline,
      currentTimestamp: currentTimestamp ?? this.currentTimestamp,
    );
  }
}

/// Chat message in watch party
class PartyChatMessage extends Equatable {
  final String id;
  final String partyId;
  final String userId;
  final String username;
  final String? avatarUrl;
  final String message;
  final DateTime timestamp;
  final int? movieTimestamp; // timestamp in movie when message was sent
  final ChatReaction? reaction;

  const PartyChatMessage({
    required this.id,
    required this.partyId,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.message,
    required this.timestamp,
    this.movieTimestamp,
    this.reaction,
  });

  @override
  List<Object?> get props => [
    id,
    partyId,
    userId,
    username,
    avatarUrl,
    message,
    timestamp,
    movieTimestamp,
    reaction,
  ];
}

/// Reaction types for chat and movie moments
enum ChatReaction {
  laugh('😂'),
  love('❤️'),
  wow('😮'),
  sad('😢'),
  angry('😠'),
  fire('🔥'),
  clap('👏'),
  scared('😱');

  final String emoji;
  const ChatReaction(this.emoji);
}

import 'package:equatable/equatable.dart';

/// News article entity representing a single news article
class NewsArticleEntity extends Equatable {
  final String id;
  final String? sourceId;
  final String sourceName;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String? content;
  final NewsCategory? category;
  final bool isBookmarked;

  const NewsArticleEntity({
    required this.id,
    this.sourceId,
    required this.sourceName,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    this.category,
    this.isBookmarked = false,
  });

  NewsArticleEntity copyWith({
    String? id,
    String? sourceId,
    String? sourceName,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    DateTime? publishedAt,
    String? content,
    NewsCategory? category,
    bool? isBookmarked,
  }) {
    return NewsArticleEntity(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sourceId,
    sourceName,
    author,
    title,
    description,
    url,
    urlToImage,
    publishedAt,
    content,
    category,
    isBookmarked,
  ];
}

/// News categories available from NewsAPI
enum NewsCategory {
  general('general', 'General'),
  business('business', 'Business'),
  entertainment('entertainment', 'Entertainment'),
  health('health', 'Health'),
  science('science', 'Science'),
  sports('sports', 'Sports'),
  technology('technology', 'Technology');

  final String key;
  final String displayName;

  const NewsCategory(this.key, this.displayName);

  static NewsCategory fromKey(String key) {
    return NewsCategory.values.firstWhere(
      (category) => category.key == key,
      orElse: () => NewsCategory.general,
    );
  }
}

/// News source entity
class NewsSourceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? url;
  final NewsCategory? category;
  final String? language;
  final String? country;

  const NewsSourceEntity({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.category,
    this.language,
    this.country,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    url,
    category,
    language,
    country,
  ];
}

/// Bookmarked article entity for local storage
class BookmarkedArticleEntity extends Equatable {
  final String id;
  final String userId;
  final String articleId;
  final String title;
  final String? description;
  final String url;
  final String? imageUrl;
  final String sourceName;
  final DateTime publishedAt;
  final DateTime bookmarkedAt;

  const BookmarkedArticleEntity({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.title,
    this.description,
    required this.url,
    this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
    required this.bookmarkedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    articleId,
    title,
    description,
    url,
    imageUrl,
    sourceName,
    publishedAt,
    bookmarkedAt,
  ];
}

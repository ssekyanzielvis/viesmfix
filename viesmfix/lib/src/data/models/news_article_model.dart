import '../../domain/entities/news_article_entity.dart';

/// News article model for JSON serialization
class NewsArticleModel {
  final SourceModel source;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String? content;

  NewsArticleModel({
    required this.source,
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    return NewsArticleModel(
      source: SourceModel.fromJson(json['source']),
      author: json['author'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? '',
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }

  NewsArticleEntity toEntity({
    NewsCategory? category,
    bool isBookmarked = false,
  }) {
    return NewsArticleEntity(
      id: url.hashCode.toString(),
      sourceId: source.id,
      sourceName: source.name,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: DateTime.tryParse(publishedAt) ?? DateTime.now(),
      content: content,
      category: category,
      isBookmarked: isBookmarked,
    );
  }
}

class SourceModel {
  final String? id;
  final String name;

  SourceModel({this.id, required this.name});

  factory SourceModel.fromJson(Map<String, dynamic> json) {
    return SourceModel(id: json['id'], name: json['name'] ?? 'Unknown');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class NewsSourceModel {
  final String id;
  final String name;
  final String? description;
  final String? url;
  final String? category;
  final String? language;
  final String? country;

  NewsSourceModel({
    required this.id,
    required this.name,
    this.description,
    this.url,
    this.category,
    this.language,
    this.country,
  });

  factory NewsSourceModel.fromJson(Map<String, dynamic> json) {
    return NewsSourceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      url: json['url'],
      category: json['category'],
      language: json['language'],
      country: json['country'],
    );
  }

  NewsSourceEntity toEntity() {
    return NewsSourceEntity(
      id: id,
      name: name,
      description: description,
      url: url,
      category: category != null ? NewsCategory.fromKey(category!) : null,
      language: language,
      country: country,
    );
  }
}

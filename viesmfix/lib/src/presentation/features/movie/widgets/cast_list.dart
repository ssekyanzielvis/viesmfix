import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extensions.dart';

class CastList extends StatelessWidget {
  final List<CastMember> cast;
  final VoidCallback? onViewAll;

  const CastList({super.key, required this.cast, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cast',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (cast.length > 5 && onViewAll != null)
                TextButton(onPressed: onViewAll, child: const Text('View All')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: cast.length > 10 ? 10 : cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return _CastCard(member: member);
            },
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastMember member;

  const _CastCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: context.colorScheme.surfaceContainerHighest,
            backgroundImage: member.profilePath != null
                ? NetworkImage(
                    'https://image.tmdb.org/t/p/w185${member.profilePath}',
                  )
                : null,
            child: member.profilePath == null
                ? Icon(
                    Icons.person,
                    size: 32,
                    color: context.colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            member.name,
            style: context.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (member.character != null) ...[
            const SizedBox(height: 2),
            Text(
              member.character!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Cast member model
class CastMember {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;

  const CastMember({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    required this.order,
  });
}

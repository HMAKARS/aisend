import 'package:flutter/material.dart';
import '../models/trip.dart';

class AttractionCard extends StatelessWidget {
  final Attraction attraction;
  final bool isSelected;
  final VoidCallback onTap;

  const AttractionCard({
    Key? key,
    required this.attraction,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 간단한 카드 디자인으로 변경
    return Card(
      elevation: isSelected ? 4 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide(color: Colors.transparent),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 260, // 최대 너비 제한
          ),
          height: 100,
          child: Row(
            mainAxisSize: MainAxisSize.min, // 콘텐츠 크기에 맞게 조절
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 이미지
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                child: Image.network(
                  attraction.imageUrl,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, color: Colors.white),
                    );
                  },
                ),
              ),
              // 오른쪽 정보 섹션
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 장소 이름
                      Flexible(
                        child: Text(
                          attraction.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 평점 및 시간 정보
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            attraction.rating.toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${attraction.visitDuration}분',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 설명
                      Expanded(
                        child: Text(
                          attraction.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 오른쪽 화살표 (작게 표시)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

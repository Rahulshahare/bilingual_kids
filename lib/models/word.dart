import 'package:hive/hive.dart';

part 'word.g.dart';

@HiveType(typeId: 0)
class Word extends HiveObject {
  @HiveField(0)
  final String native;

  @HiveField(1)
  final String english;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final String audioNative;

  @HiveField(4)
  final String audioEnglish;

  Word({
    required this.native,
    required this.english,
    required this.image,
    required this.audioNative,
    required this.audioEnglish,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        native: json['native'] ?? '',
        english: json['english'] ?? '',
        image: json['image'] ?? '',
        audioNative: json['audio_native'] ?? '',
        audioEnglish: json['audio_english'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'native': native,
        'english': english,
        'image': image,
        'audio_native': audioNative,
        'audio_english': audioEnglish,
      };
}
class Word {
  final String id;
  final String native;
  final String english;
  final String image;
  final String audioNative;
  final String audioEnglish;

  Word({
    required this.id,
    required this.native,
    required this.english,
    required this.image,
    required this.audioNative,
    required this.audioEnglish,
  });

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json['id'] ?? '',
        native: json['native'] ?? '',
        english: json['english'] ?? '',
        image: json['image'] ?? '',
        audioNative: json['audio_native'] ?? '',
        audioEnglish: json['audio_english'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'native': native,
        'english': english,
        'image': image,
        'audio_native': audioNative,
        'audio_english': audioEnglish,
      };
}

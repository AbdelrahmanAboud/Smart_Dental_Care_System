class Review {
  final String name;
  final String date;
  final int rating;
  final String comment;
  final String image;

  Review({
    required this.name,
    required this.date,
    required this.rating,
    required this.comment,
    required this.image,
  });
}

List<Review> pastReviews = [
  Review(
    name: 'Sophia Miller',
    date: '2023-11-15',
    rating: 5,
    comment:
    'Dr. Reed is incredibly professional and caring. Highly recommend!',
    image: 'lib/assets/doctor.jpeg',
  ),
  Review(
    name: 'Sophia Miller',
    date: '2023-11-15',
    rating: 5,
    comment:
    'Dr. Reed is incredibly professional and caring. Highly recommend!',
    image: 'lib/assets/doctor.jpeg',
  ),
  Review(
    name: 'Sophia Miller',
    date: '2023-11-15',
    rating: 5,
    comment:
    'Dr. Reed is incredibly professional and caring. Highly recommend!',
    image: 'lib/assets/doctor.jpeg',
  ),
  Review(
    name: 'Ethan Johnson',
    date: '2023-10-28',
    rating: 4,
    comment:
    'Great experience overall. Everything was explained clearly.',
    image: 'lib/assets/doctor.jpeg',
  ),
];
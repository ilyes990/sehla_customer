class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String cuisineType;
  final double rating;
  final int reviewsCount;
  final int deliveryTimeMin;
  final double deliveryFee;
  final double minOrder;
  final bool isOpen;
  final bool isFeatured;
  final List<String> tags;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.cuisineType,
    required this.rating,
    required this.reviewsCount,
    required this.deliveryTimeMin,
    required this.deliveryFee,
    required this.minOrder,
    required this.isOpen,
    required this.isFeatured,
    this.tags = const [],
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      RestaurantModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        imageUrl: json['image_url'] as String,
        cuisineType: json['cuisine_type'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewsCount: json['reviews_count'] as int,
        deliveryTimeMin: json['delivery_time_min'] as int,
        deliveryFee: (json['delivery_fee'] as num).toDouble(),
        minOrder: (json['min_order'] as num).toDouble(),
        isOpen: json['is_open'] as bool,
        isFeatured: json['is_featured'] as bool,
        tags: List<String>.from(json['tags'] ?? []),
      );
}

// ── Dummy Data ────────────────────────────────────────────────────────────────
final List<RestaurantModel> dummyRestaurants = [
  const RestaurantModel(
    id: 'r1',
    name: 'Le Palais du Couscous',
    description:
        'Cuisine traditionnelle algérienne authentique avec des saveurs d\'antan.',
    imageUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop',
    cuisineType: 'Algérienne',
    rating: 4.8,
    reviewsCount: 342,
    deliveryTimeMin: 25,
    deliveryFee: 150,
    minOrder: 800,
    isOpen: true,
    isFeatured: true,
    tags: ['Couscous', 'Traditionnel', 'Famille'],
  ),
  const RestaurantModel(
    id: 'r2',
    name: 'Pizza Milano',
    description:
        'Pizzas authentiques cuites au feu de bois avec des ingrédients frais.',
    imageUrl:
        'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=800&auto=format&fit=crop',
    cuisineType: 'Italienne',
    rating: 4.6,
    reviewsCount: 218,
    deliveryTimeMin: 35,
    deliveryFee: 200,
    minOrder: 600,
    isOpen: true,
    isFeatured: true,
    tags: ['Pizza', 'Pâtes', 'Italien'],
  ),
  const RestaurantModel(
    id: 'r3',
    name: 'Burger House',
    description: 'Les meilleurs burgers artisanaux de la ville.',
    imageUrl:
        'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&auto=format&fit=crop',
    cuisineType: 'Fast Food',
    rating: 4.5,
    reviewsCount: 505,
    deliveryTimeMin: 20,
    deliveryFee: 100,
    minOrder: 400,
    isOpen: true,
    isFeatured: false,
    tags: ['Burger', 'Fast Food', 'Plats rapides'],
  ),
  const RestaurantModel(
    id: 'r4',
    name: 'Sushi Osaka',
    description:
        'Sushis frais et rouleaux créatifs préparés par des maîtres sushis.',
    imageUrl:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800&auto=format&fit=crop',
    cuisineType: 'Japonaise',
    rating: 4.9,
    reviewsCount: 189,
    deliveryTimeMin: 45,
    deliveryFee: 300,
    minOrder: 1200,
    isOpen: false,
    isFeatured: true,
    tags: ['Sushi', 'Japonais', 'Fruits de mer'],
  ),
  const RestaurantModel(
    id: 'r5',
    name: 'Taco Fiesta',
    description: 'Tacos et burritos mexicains 100% authentiques.',
    imageUrl:
        'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=800&auto=format&fit=crop',
    cuisineType: 'Mexicaine',
    rating: 4.3,
    reviewsCount: 127,
    deliveryTimeMin: 30,
    deliveryFee: 150,
    minOrder: 500,
    isOpen: true,
    isFeatured: false,
    tags: ['Tacos', 'Mexicain', 'Épicé'],
  ),
  const RestaurantModel(
    id: 'r6',
    name: 'Healthy Bowl',
    description: 'Bowls nutritifs et délicieux pour une alimentation saine.',
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&auto=format&fit=crop',
    cuisineType: 'Healthy',
    rating: 4.7,
    reviewsCount: 93,
    deliveryTimeMin: 20,
    deliveryFee: 200,
    minOrder: 700,
    isOpen: true,
    isFeatured: false,
    tags: ['Salade', 'Bio', 'Vegan'],
  ),
];

class MealModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final double rating;
  final bool isAvailable;
  final bool isPopular;
  final bool isVegetarian;
  final List<String> ingredients;
  final int prepTimeMin;

  const MealModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.rating,
    required this.isAvailable,
    required this.isPopular,
    this.isVegetarian = false,
    this.ingredients = const [],
    this.prepTimeMin = 15,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
        id: (json['idplats'] ?? json['id'])?.toString() ?? '',
        restaurantId:
            (json['id_resto'] ?? json['restaurant_id'])?.toString() ?? '',
        name: json['nom'] ?? json['name'] as String? ?? 'Plat',
        description: json['description'] as String? ??
            'Savourez ce délicieux plat préparé avec des ingrédients frais.',
        imageUrl: json['image_url'] as String? ??
            'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&auto=format&fit=crop',
        price: (json['prix'] ?? json['price'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] as String? ?? 'Plat principal',
        rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
        isAvailable: json['is_available'] as bool? ?? true,
        isPopular: json['is_popular'] as bool? ?? false,
        isVegetarian: json['is_vegetarian'] as bool? ?? false,
        ingredients: List<String>.from(json['ingredients'] ?? []),
        prepTimeMin: json['prep_time_min'] as int? ?? 15,
      );
}

// ── Dummy Data ────────────────────────────────────────────────────────────────
final List<MealModel> dummyMeals = [
  const MealModel(
    id: 'm1',
    restaurantId: 'r1',
    name: 'Couscous Royal',
    description:
        'Un couscous généreux avec agneau, merguez, légumes frais et une sauce harissa maison.',
    imageUrl:
        'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800&auto=format&fit=crop',
    price: 1200,
    category: 'Plat principal',
    rating: 4.9,
    isAvailable: true,
    isPopular: true,
    ingredients: ['Semoule', 'Agneau', 'Merguez', 'Pois chiches', 'Légumes'],
    prepTimeMin: 20,
  ),
  const MealModel(
    id: 'm2',
    restaurantId: 'r2',
    name: 'Pizza Margherita',
    description:
        'La classique italienne : sauce tomate maison, mozzarella di buffalo et basilic frais.',
    imageUrl:
        'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&auto=format&fit=crop',
    price: 950,
    category: 'Pizza',
    rating: 4.7,
    isAvailable: true,
    isPopular: true,
    isVegetarian: true,
    ingredients: ['Pâte', 'Tomate', 'Mozzarella', 'Basilic'],
    prepTimeMin: 18,
  ),
  const MealModel(
    id: 'm3',
    restaurantId: 'r3',
    name: 'Smash Burger Double',
    description:
        'Double galette de bœuf smashée, cheddar fondu, oignons caramélisés et sauce secrète.',
    imageUrl:
        'https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&auto=format&fit=crop',
    price: 750,
    category: 'Burger',
    rating: 4.8,
    isAvailable: true,
    isPopular: true,
    ingredients: ['Bœuf', 'Cheddar', 'Oignons', 'Sauce secrète', 'Brioche'],
    prepTimeMin: 12,
  ),
  const MealModel(
    id: 'm4',
    restaurantId: 'r4',
    name: 'Salmon Roll Box',
    description:
        'Sélection de 12 rouleaux au saumon frais, avocat et fromage à la crème.',
    imageUrl:
        'https://images.unsplash.com/photo-1617196034183-421b4040ed20?w=800&auto=format&fit=crop',
    price: 1600,
    category: 'Sushi',
    rating: 4.9,
    isAvailable: false,
    isPopular: true,
    ingredients: ['Riz', 'Saumon', 'Avocat', 'Algue', 'Crème'],
    prepTimeMin: 25,
  ),
  const MealModel(
    id: 'm5',
    restaurantId: 'r5',
    name: 'Burrito Poulet',
    description:
        'Burrito géant au poulet grillé, guacamole, pico de gallo et crème fraîche.',
    imageUrl:
        'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=800&auto=format&fit=crop',
    price: 680,
    category: 'Burrito',
    rating: 4.5,
    isAvailable: true,
    isPopular: false,
    ingredients: ['Tortilla', 'Poulet', 'Guacamole', 'Fromage', 'Salsa'],
    prepTimeMin: 10,
  ),
  const MealModel(
    id: 'm6',
    restaurantId: 'r6',
    name: 'Buddha Bowl Vegan',
    description:
        'Bowl coloré au quinoa, pois chiches rôtis, légumes grillés et tahini citronné.',
    imageUrl:
        'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?w=800&auto=format&fit=crop',
    price: 890,
    category: 'Bowl',
    rating: 4.7,
    isAvailable: true,
    isPopular: false,
    isVegetarian: true,
    ingredients: ['Quinoa', 'Pois chiches', 'Légumes', 'Tahini', 'Graines'],
    prepTimeMin: 8,
  ),
  const MealModel(
    id: 'm7',
    restaurantId: 'r1',
    name: 'Chorba Frik',
    description:
        'Soupe traditionnelle à base de blé vert concassé, viande d\'agneau et épices.',
    imageUrl:
        'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&auto=format&fit=crop',
    price: 450,
    category: 'Soupe',
    rating: 4.6,
    isAvailable: true,
    isPopular: false,
    ingredients: ['Frik', 'Agneau', 'Tomate', 'Coriandre', 'Cumin'],
    prepTimeMin: 15,
  ),
  const MealModel(
    id: 'm8',
    restaurantId: 'r2',
    name: 'Penne all\'Arrabbiata',
    description:
        'Penne al dente dans une sauce tomate piquante à l\'ail et piment rouge.',
    imageUrl:
        'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=800&auto=format&fit=crop',
    price: 780,
    category: 'Pâtes',
    rating: 4.4,
    isAvailable: true,
    isPopular: false,
    isVegetarian: true,
    ingredients: ['Penne', 'Tomate', 'Ail', 'Piment', 'Parmesan'],
    prepTimeMin: 15,
  ),
];

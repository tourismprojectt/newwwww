import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MonumentPlaces {
  final String name;
  final List<String> imagePaths;
  final String description;
  bool isFavorite;
  int price;

  MonumentPlaces({
    required this.name,
    required this.imagePaths,
    required this.description,
    this.isFavorite = false,
    this.price = 0,
  });
}

List<MonumentPlaces> monumentPlacesList = [
  MonumentPlaces(
    name: "Ibn Tulun Mosque",
    imagePaths: [
      'images/monumentosplaces/ibn tolon1.jpg',
      'images/monumentosplaces/ibn tolon3.jpg',
      'images/monumentosplaces/ibntolon2.jpg',
    ],
    description: "Ibn Tulun Mosque stands as a masterpiece of Islamic architecture, known for its grand scale and historical significance.",
  ),
  MonumentPlaces(
    name: "Al Azhar Mosque",
    imagePaths: [
      'images/monumentosplaces/azhar1.jpg',
      'images/monumentosplaces/azhar2.jpg',
      'images/monumentosplaces/azhar3.jpg',
    ],
    description: "Al-Azhar Mosque, a beacon of Islamic learning and spirituality, stands as a symbol of Egypt's rich cultural heritage.",
  ),
  MonumentPlaces(
    name: 'Muhammad Ali Mosque',
    imagePaths: [
      'images/monumentosplaces/mhmdali1.jpg',
      'images/monumentosplaces/mhmdali2.jpg',
      'images/monumentosplaces/mhmdali3.jpg',
    ],
    description: "The Muhammad Ali Mosque, with its majestic domes and towering minarets, commands admiration as a testament to Egypt's architectural prowess and Islamic heritage.",
  ),
  MonumentPlaces(
    name: 'Al Sultan Hassan Mosque',
    imagePaths: [
      'images/monumentosplaces/sultanhassan1.jpg',
      'images/monumentosplaces/sultan2.jpg',
      'images/monumentosplaces/sultan3.jpg',
    ],
    description: "The Sultan Hassan Mosque, a timeless marvel of Islamic architecture, embodies elegance and grandeur, captivating visitors with its intricate designs and sacred ambiance.",
  ),
  MonumentPlaces(
    name: 'Al-Hakim Mosque',
    imagePaths: [
      'images/monumentosplaces/hakem1.jpg',
      'images/monumentosplaces/hakeem2.jpg',
      'images/monumentosplaces/hakem3.jpg',
    ],
    description: "Al-Hakim Mosque, with its ancient walls whispering tales of faith and history, stands as a testament to the enduring legacy of Islamic architecture and spirituality.",
  ),
];

class ScreenOne extends StatefulWidget {
  ScreenOne({Key? key}) : super(key: key);

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String? _userId;
  String? _firestoreUserId;
  List<int> activeIndices = List.filled(monumentPlacesList.length, 0);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getHotelPrices();
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _userId = user?.uid;
        if (_userId != null) {
          getFirestoreUserId(_userId!);
        }
      });
    });
  }

  void getFirestoreUserId(String uid) async {
    try {
      DocumentSnapshot docSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (docSnapshot.exists) {
        setState(() {
          _firestoreUserId = docSnapshot.get('userId') as String?;
        });
      } else {
        print('User document does not exist in Firestore');
      }
    } catch (e) {
      print('Error getting user ID from Firestore: $e');
    }
  }

  void toggleFavoriteStatus(int index) async {
    if (_firestoreUserId == null) return;

    final monumentPlace = monumentPlacesList[index];
    final monumentRef =
        FirebaseFirestore.instance.collection('Monuments').doc(monumentPlace.name);
    final userFavoritesRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_firestoreUserId!)
        .collection('favorites');

    await monumentRef.update({'isFavorite': !monumentPlace.isFavorite});

    if (!monumentPlace.isFavorite) {
  await userFavoritesRef.doc(monumentPlace.name).set({'name': monumentPlace.name});
} else {
  await userFavoritesRef.doc(monumentPlace.name).delete();
}

    setState(() {
      monumentPlace.isFavorite = !monumentPlace.isFavorite;
    });
  }

  Future<void> getHotelPrices() async {
    for (int i = 0; i < monumentPlacesList.length; i++) {
      DocumentSnapshot document =
          await FirebaseFirestore.instance.collection('Monuments').doc(monumentPlacesList[i].name).get();
      if (document.exists) {
        int price = document.get('price');
        bool isFavorite = document.get('isFavorite');
        setState(() {
          monumentPlacesList[i].price = price;
          monumentPlacesList[i].isFavorite = isFavorite;
        });
      } else {
        print('Document does not exist');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alexandria',
          style: TextStyle(
            fontFamily: 'MadimiOne',
            color: Color.fromARGB(255, 121, 155, 228),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 121, 155, 228),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Text(
              'Monuments',
              style: TextStyle(
                fontFamily: 'MadimiOne',
                color: Color.fromARGB(255, 121, 155, 230),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          for (int i = 0; i < monumentPlacesList.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  items: monumentPlacesList[i]
                      .imagePaths
                      .map((imagePath) => Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ))
                      .toList(),
                  options: CarouselOptions(
                    height: 180,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        activeIndices[i] = index;
                      });
                    },
                  ),
                ),
                SizedBox(height: 10),
                buildIndicator(activeIndices[i], monumentPlacesList[i].imagePaths.length),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        monumentPlacesList[i].name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'MadimiOne',
                          color: Color.fromARGB(255, 83, 137, 182),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          toggleFavoriteStatus(i);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(monumentPlacesList[i].isFavorite
                                  ? 'Removed from Favorites!'
                                  : 'Added to Favorites!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Icon(
                          monumentPlacesList[i].isFavorite
                              ? Icons.favorite
                              : Icons.favorite_outline,
                          color: Color.fromARGB(255, 13, 16, 74),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    monumentPlacesList[i].description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 36, 108, 163),
                      fontFamily: 'MadimiOne',
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (isLoading)
                        CircularProgressIndicator(), // Show loading icon
                      if (!isLoading && monumentPlacesList[i].price != 0)
                        Text(
                          '${monumentPlacesList[i].price} EGP',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 5, 59, 107),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildIndicator(int activeIndex, int length) {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: length,
        effect: WormEffect(
          dotWidth: 18,
          dotHeight: 18,
          activeDotColor: Colors.blue,
          dotColor: Color.fromARGB(255, 16, 65, 106),
        ),
      ),
    );
  }
}

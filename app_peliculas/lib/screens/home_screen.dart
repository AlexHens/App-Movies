
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_peliculas/widgets/widgets.dart';
import 'package:app_peliculas/providers/movies_provider.dart';
import 'package:app_peliculas/search/search_delegate.dart';


class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text('Películas en cines'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => showSearch(context: context, delegate: MovieSearchDelegate()), 
            icon: Icon(Icons.search_outlined)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
        children: [

          // Tarjetas principales
          CardSwiper(movies: moviesProvider.onDisplayMovies),

          // Slider de películas
          MovieSlider(
            movies: moviesProvider.popularMovies,
            title: 'Populares',
            onNextPage: () => moviesProvider.getPopularMovies(),
          ),
        ],
      )
      )
    );
  }
}
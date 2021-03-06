
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_peliculas/providers/movies_provider.dart';
import 'package:app_peliculas/models/models.dart';

class MovieSearchDelegate extends SearchDelegate{

  List<Movie> moviesResult = [];

  @override
  // TODO: implement searchFieldLabel
  String? get searchFieldLabel => 'Buscar película';

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        onPressed: (){
          query = '';
        }, 
        icon: Icon(Icons.clear)
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return  IconButton(
      onPressed: (){
        close(context, null);
      }, 
      icon: Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    if(query.isEmpty){
      return _emptyContainer();
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    return ListView.builder(
          itemCount: moviesResult.length,
          itemBuilder: (_, int index) => _MovieItem(moviesResult[index])
    );
    
  }

  Widget _emptyContainer(){
    return Container(
        child: Center(
          child: Icon(Icons.movie_creation_outlined, color: Colors.black38, size: 100,),
        ),
      );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    if(query.isEmpty) {
      return _emptyContainer();
    }

    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);

    moviesProvider.getSuggestionsByQuery(query);

    return StreamBuilder(
      stream: moviesProvider.suggestionsStream,
      builder: (_, AsyncSnapshot<List<Movie>> snapshot){

        if(!snapshot.hasData) return _emptyContainer();

        final movies = snapshot.data!;
        moviesResult = movies;

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, int index) => _MovieItem(movies[index])
        );
      }
    );
  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;

  const _MovieItem(this.movie);

  @override
  Widget build(BuildContext context) {

    movie.heroId = 'search-${movie.id}';

    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
          placeholder: AssetImage('assets/no-image.jpg'), 
          image: NetworkImage(movie.fullPosterImg),
          width: 50,
          fit: BoxFit.contain
        ),
      ),
      title: Text(movie.title),
      subtitle: Text(movie.originalTitle),
      onTap: () {
        Navigator.pushNamed(context, 'details', arguments: movie);
      },
    );
  }
}
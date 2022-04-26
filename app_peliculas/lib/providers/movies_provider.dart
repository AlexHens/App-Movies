
import 'dart:async';
import 'dart:convert';

import 'package:app_peliculas/helpers/debouncer.dart';
import 'package:app_peliculas/models/models.dart';
import 'package:app_peliculas/models/search_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MoviesProvider extends ChangeNotifier{

  String _baseUrl = 'api.themoviedb.org';
  String _apiKey = '75adbc7997e7f7cf19dc4c334a25ab05';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];

  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
  );

  final StreamController<List<Movie>> _suggestionStreamController = new StreamController.broadcast();
  Stream<List<Movie>> get suggestionsStream => this._suggestionStreamController.stream;



  MoviesProvider(){
    print('MoviesProvider inicializado');

    this.getOnDisplayMovies();
    this.getPopularMovies();

  }

  Future<String> _getJsonData(String endpoint, [int page = 1]) async{

    final url = Uri.https(this._baseUrl, endpoint, {
      'api_key' : _apiKey, 
      'language': _language,
      'page'    : '$page'
    });

    final response = await http.get(url);

    return response.body;

  }


  getOnDisplayMovies() async{

    final jsonData = await _getJsonData('3/movie/now_playing');
    
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);

    this.onDisplayMovies = nowPlayingResponse.results;

    notifyListeners();
  }

  getPopularMovies() async{

    _popularPage++;

    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    
    final popularResponse = PopularResponse.fromJson(jsonData);

    this.popularMovies = [...popularMovies, ...popularResponse.results];

    //print(popularMovies[0]);

    notifyListeners();

  }

  Future<List<Cast>> getMovieCast(int movieId) async{

    if(moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await _getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;    

  }

  Future<List<Movie>> searchMovies(String query) async{

    final url = Uri.https(_baseUrl, '3/search/movie', {
      'api_key' : _apiKey, 
      'language': _language,
      'query'   : query
    });

    final response = await http.get(url);

    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;

  }

  void getSuggestionsByQuery(String searchTerm){

    debouncer.value = '';
    debouncer.onValue = (value) async {
      //print('Tenemos un valor a buscar $value');
      final results = await this.searchMovies(value);
      this._suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) { 
      debouncer.value = searchTerm;
     });

     Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
     
  }

}
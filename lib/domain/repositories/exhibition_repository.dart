import '../entities/exhibition.dart';

abstract class ExhibitionRepository {
  Future<List<Exhibition>> getExhibitions();
  Future<Exhibition> getExhibitionById(String id);
  Future<List<Exhibition>> getSavedExhibitions();
  Future<void> toggleSaved(String id);
}

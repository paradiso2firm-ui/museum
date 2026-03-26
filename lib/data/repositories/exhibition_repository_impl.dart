import '../../domain/entities/exhibition.dart';
import '../../domain/repositories/exhibition_repository.dart';
import '../datasources/mock_data.dart';

class ExhibitionRepositoryImpl implements ExhibitionRepository {
  final Set<String> _savedIds = {
    for (final e in MockData.exhibitions)
      if (e.isSaved) e.id,
  };

  @override
  Future<List<Exhibition>> getExhibitions() async {
    return MockData.exhibitions.map((e) {
      return e.copyWith(isSaved: _savedIds.contains(e.id));
    }).toList();
  }

  @override
  Future<Exhibition> getExhibitionById(String id) async {
    final e = MockData.exhibitions.firstWhere((e) => e.id == id);
    return e.copyWith(isSaved: _savedIds.contains(e.id));
  }

  @override
  Future<List<Exhibition>> getSavedExhibitions() async {
    final all = await getExhibitions();
    return all.where((e) => e.isSaved).toList();
  }

  @override
  Future<void> toggleSaved(String id) async {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
  }
}

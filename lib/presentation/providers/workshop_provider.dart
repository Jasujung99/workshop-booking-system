import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../domain/entities/workshop.dart';
import '../../domain/usecases/workshop/get_workshops_use_case.dart';
import '../../domain/usecases/workshop/create_workshop_use_case.dart';
import '../../domain/usecases/workshop/update_workshop_use_case.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../core/error/result.dart';
import '../../core/error/exceptions.dart';

/// Provider for managing workshop state and operations
/// 
/// Handles workshop list management, search/filtering, and CRUD operations
/// for both user and admin interfaces
class WorkshopProvider extends ChangeNotifier {
  final GetWorkshopsUseCase _getWorkshopsUseCase;
  final CreateWorkshopUseCase _createWorkshopUseCase;
  final UpdateWorkshopUseCase _updateWorkshopUseCase;
  final WorkshopRepository _workshopRepository;
  final FirebaseStorageService _storageService;

  // State variables
  List<Workshop> _workshops = [];
  List<Workshop> _filteredWorkshops = [];
  WorkshopFilter _currentFilter = WorkshopFilter.empty();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _searchQuery;
  bool _hasMoreData = true;
  String? _lastDocumentId;
  
  // Pagination
  static const int _pageSize = 20;

  WorkshopProvider({
    required GetWorkshopsUseCase getWorkshopsUseCase,
    required CreateWorkshopUseCase createWorkshopUseCase,
    required UpdateWorkshopUseCase updateWorkshopUseCase,
    required WorkshopRepository workshopRepository,
    required FirebaseStorageService storageService,
  })  : _getWorkshopsUseCase = getWorkshopsUseCase,
        _createWorkshopUseCase = createWorkshopUseCase,
        _updateWorkshopUseCase = updateWorkshopUseCase,
        _workshopRepository = workshopRepository,
        _storageService = storageService;

  // Getters
  List<Workshop> get workshops => _filteredWorkshops;
  List<Workshop> get allWorkshops => _workshops;
  WorkshopFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String? get searchQuery => _searchQuery;
  bool get hasMoreData => _hasMoreData;
  bool get isEmpty => _filteredWorkshops.isEmpty && !_isLoading;
  bool get hasWorkshops => _filteredWorkshops.isNotEmpty;

  /// Load workshops with current filter
  Future<void> loadWorkshops({bool refresh = false}) async {
    if (refresh) {
      _resetPagination();
    }

    if (_isLoading || (_isLoadingMore && !refresh)) return;

    _setLoading(refresh ? true : false, loadingMore: !refresh);
    _clearError();

    try {
      final result = await _getWorkshopsUseCase.execute(
        filter: _currentFilter,
        limit: _pageSize,
        lastDocumentId: refresh ? null : _lastDocumentId,
      );

      result.fold(
        onSuccess: (workshops) {
          if (refresh) {
            _workshops = workshops;
          } else {
            _workshops.addAll(workshops);
          }
          
          _hasMoreData = workshops.length == _pageSize;
          if (workshops.isNotEmpty) {
            _lastDocumentId = workshops.last.id;
          }
          
          _applyCurrentFilter();
          _setLoading(false, loadingMore: false);
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false, loadingMore: false);
        },
      );
    } catch (e) {
      _setError('워크샵 목록을 불러오는 중 오류가 발생했습니다');
      _setLoading(false, loadingMore: false);
    }
  }

  /// Load more workshops (pagination)
  Future<void> loadMoreWorkshops() async {
    if (!_hasMoreData || _isLoadingMore || _isLoading) return;
    
    await loadWorkshops(refresh: false);
  }

  /// Refresh workshop list
  Future<void> refreshWorkshops() async {
    await loadWorkshops(refresh: true);
  }

  /// Search workshops by query
  Future<void> searchWorkshops(String query) async {
    _searchQuery = query.trim();
    
    if (_searchQuery!.isEmpty) {
      _currentFilter = _currentFilter.copyWith(searchQuery: null);
    } else {
      _currentFilter = _currentFilter.copyWith(searchQuery: _searchQuery);
    }
    
    await loadWorkshops(refresh: true);
  }

  /// Apply filter to workshops
  Future<void> applyFilter(WorkshopFilter filter) async {
    _currentFilter = filter;
    await loadWorkshops(refresh: true);
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _currentFilter = WorkshopFilter.empty();
    _searchQuery = null;
    await loadWorkshops(refresh: true);
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = null;
    _currentFilter = _currentFilter.copyWith(searchQuery: null);
    _applyCurrentFilter();
  }

  /// Apply current filter to workshop list
  void _applyCurrentFilter() {
    _filteredWorkshops = _workshops.where((workshop) {
      // Apply search query filter
      if (_currentFilter.searchQuery != null && _currentFilter.searchQuery!.isNotEmpty) {
        final query = _currentFilter.searchQuery!.toLowerCase();
        final matchesTitle = workshop.title.toLowerCase().contains(query);
        final matchesDescription = workshop.description.toLowerCase().contains(query);
        final matchesTags = workshop.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesTitle && !matchesDescription && !matchesTags) {
          return false;
        }
      }

      // Apply price range filter
      if (_currentFilter.minPrice != null && workshop.price < _currentFilter.minPrice!) {
        return false;
      }
      
      if (_currentFilter.maxPrice != null && workshop.price > _currentFilter.maxPrice!) {
        return false;
      }

      // Apply tags filter
      if (_currentFilter.tags != null && _currentFilter.tags!.isNotEmpty) {
        final hasMatchingTag = _currentFilter.tags!.any((filterTag) =>
            workshop.tags.any((workshopTag) => workshopTag.toLowerCase() == filterTag.toLowerCase()));
        if (!hasMatchingTag) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort workshops by creation date (newest first)
    _filteredWorkshops.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get workshop by ID
  Future<Workshop?> getWorkshopById(String id) async {
    // First check if workshop is already in memory
    try {
      return _workshops.firstWhere((workshop) => workshop.id == id);
    } catch (e) {
      // Workshop not found in memory, fetch from repository
      try {
        final result = await _workshopRepository.getWorkshopById(id);
        return result.fold(
          onSuccess: (workshop) => workshop,
          onFailure: (exception) {
            _setError(_getErrorMessage(exception));
            return null;
          },
        );
      } catch (e) {
        _setError('워크샵 정보를 불러오는 중 오류가 발생했습니다');
        return null;
      }
    }
  }

  /// Create new workshop (Admin only)
  Future<bool> createWorkshop(Workshop workshop, {File? imageFile}) async {
    _setLoading(true);
    _clearError();

    try {
      Workshop workshopToCreate = workshop;
      
      // Upload image if provided
      if (imageFile != null) {
        final imageResult = await _storageService.uploadWorkshopImage(
          imageFile,
          'workshop_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        final imageUrl = await imageResult.fold(
          onSuccess: (url) async => url,
          onFailure: (exception) async {
            _setError('이미지 업로드에 실패했습니다: ${_getErrorMessage(exception)}');
            _setLoading(false);
            return null;
          },
        );
        
        if (imageUrl == null) return false;
        
        workshopToCreate = workshop.copyWith(imageUrl: imageUrl);
      }
      
      final result = await _createWorkshopUseCase.execute(workshopToCreate);
      
      return result.fold(
        onSuccess: (createdWorkshop) {
          _workshops.insert(0, createdWorkshop);
          _applyCurrentFilter();
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('워크샵 생성 중 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Update existing workshop (Admin only)
  Future<bool> updateWorkshop(Workshop workshop, {File? imageFile}) async {
    _setLoading(true);
    _clearError();

    try {
      Workshop workshopToUpdate = workshop;
      
      // Upload new image if provided
      if (imageFile != null) {
        final imageResult = await _storageService.uploadWorkshopImage(
          imageFile,
          'workshop_${workshop.id}_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        final imageUrl = await imageResult.fold(
          onSuccess: (url) async => url,
          onFailure: (exception) async {
            _setError('이미지 업로드에 실패했습니다: ${_getErrorMessage(exception)}');
            _setLoading(false);
            return null;
          },
        );
        
        if (imageUrl == null) return false;
        
        // Delete old image if it exists
        if (workshop.imageUrl != null) {
          await _storageService.deleteWorkshopImage(workshop.imageUrl!);
        }
        
        workshopToUpdate = workshop.copyWith(imageUrl: imageUrl);
      }
      
      final result = await _updateWorkshopUseCase.execute(workshopToUpdate);
      
      return result.fold(
        onSuccess: (updatedWorkshop) {
          final index = _workshops.indexWhere((w) => w.id == updatedWorkshop.id);
          if (index != -1) {
            _workshops[index] = updatedWorkshop;
            _applyCurrentFilter();
          }
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('워크샵 수정 중 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Delete workshop (Admin only)
  Future<bool> deleteWorkshop(String workshopId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _workshopRepository.deleteWorkshop(workshopId);
      
      return result.fold(
        onSuccess: (_) {
          _workshops.removeWhere((workshop) => workshop.id == workshopId);
          _applyCurrentFilter();
          _setLoading(false);
          return true;
        },
        onFailure: (exception) {
          _setError(_getErrorMessage(exception));
          _setLoading(false);
          return false;
        },
      );
    } catch (e) {
      _setError('워크샵 삭제 중 오류가 발생했습니다');
      _setLoading(false);
      return false;
    }
  }

  /// Get available tags from all workshops
  List<String> getAvailableTags() {
    final allTags = <String>{};
    for (final workshop in _workshops) {
      allTags.addAll(workshop.tags);
    }
    return allTags.toList()..sort();
  }

  /// Get price range from all workshops
  ({double min, double max})? getPriceRange() {
    if (_workshops.isEmpty) return null;
    
    double min = _workshops.first.price;
    double max = _workshops.first.price;
    
    for (final workshop in _workshops) {
      if (workshop.price < min) min = workshop.price;
      if (workshop.price > max) max = workshop.price;
    }
    
    return (min: min, max: max);
  }

  /// Reset pagination state
  void _resetPagination() {
    _hasMoreData = true;
    _lastDocumentId = null;
  }

  /// Set loading state
  void _setLoading(bool loading, {bool loadingMore = false}) {
    _isLoading = loading;
    _isLoadingMore = loadingMore;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clear any existing error message
  void clearError() {
    _clearError();
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(AppException exception) {
    switch (exception.runtimeType) {
      case ValidationException:
        return exception.message;
      case NetworkException:
        return '네트워크 연결을 확인해주세요';
      case ServerException:
        return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
      case AuthException:
        return '권한이 없습니다. 다시 로그인해주세요';
      default:
        return exception.message.isNotEmpty 
            ? exception.message 
            : '알 수 없는 오류가 발생했습니다';
    }
  }
}
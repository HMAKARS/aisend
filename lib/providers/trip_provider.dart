import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

class TripProvider with ChangeNotifier {
  final TripService _tripService = TripService();
  
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  bool _isLoading = false;
  String _error = '';
  
  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // 모든 여행 코스 가져오기
  Future<void> fetchAllTrips() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _trips = await _tripService.getAllTrips();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 여행 타입별 여행 코스 가져오기
  Future<void> fetchTripsByType(TripType type) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _trips = await _tripService.getTripsByType(type);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 여행 상세 정보 가져오기
  Future<void> fetchTripDetail(String id) async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    
    try {
      _selectedTrip = await _tripService.getTripById(id);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 선택된 여행 초기화
  void clearSelectedTrip() {
    _selectedTrip = null;
    notifyListeners();
  }
}
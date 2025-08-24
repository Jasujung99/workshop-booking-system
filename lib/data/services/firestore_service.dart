import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/result.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/workshop.dart';
import '../../domain/entities/time_slot.dart';
import '../../domain/entities/booking.dart';
import '../models/workshop_dto.dart';
import '../models/time_slot_dto.dart';
import '../models/booking_dto.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Workshop CRUD operations
  Future<Result<List<Workshop>>> getWorkshops({
    String? searchQuery,
    List<String>? tags,
    double? minPrice,
    double? maxPrice,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.workshopsCollection);

      // Apply filters
      if (tags != null && tags.isNotEmpty) {
        query = query.where('tags', arrayContainsAny: tags);
      }

      if (minPrice != null) {
        query = query.where('price', isGreaterThanOrEqualTo: minPrice);
      }

      if (maxPrice != null) {
        query = query.where('price', isLessThanOrEqualTo: maxPrice);
      }

      // Order by creation date (newest first)
      query = query.orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      final workshops = querySnapshot.docs.map((doc) {
        final workshopDto = WorkshopDto.fromFirestore(doc);
        return workshopDto.toDomain(doc.id);
      }).toList();

      // Apply text search filter (Firestore doesn't support full-text search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final filteredWorkshops = workshops.where((workshop) {
          final query = searchQuery.toLowerCase();
          return workshop.title.toLowerCase().contains(query) ||
                 workshop.description.toLowerCase().contains(query) ||
                 workshop.tags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();
        
        AppLogger.info('Retrieved ${filteredWorkshops.length} workshops with search query: $searchQuery');
        return Success(filteredWorkshops);
      }

      AppLogger.info('Retrieved ${workshops.length} workshops');
      return Success(workshops);
    } catch (e) {
      AppLogger.error('Error getting workshops', exception: e);
      return Failure(DataException('Failed to get workshops: ${e.toString()}'));
    }
  }

  Future<Result<Workshop>> getWorkshopById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.workshopsCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        return const Failure(DataException('Workshop not found'));
      }

      final workshopDto = WorkshopDto.fromFirestore(doc);
      final workshop = workshopDto.toDomain(doc.id);
      
      AppLogger.info('Retrieved workshop: ${workshop.title}');
      return Success(workshop);
    } catch (e) {
      AppLogger.error('Error getting workshop by ID', exception: e);
      return Failure(DataException('Failed to get workshop: ${e.toString()}'));
    }
  }

  Future<Result<Workshop>> createWorkshop(Workshop workshop) async {
    try {
      final workshopDto = WorkshopDto.fromDomain(workshop);
      final docRef = await _firestore
          .collection(AppConstants.workshopsCollection)
          .add(workshopDto.toFirestore());

      final createdWorkshop = workshop.copyWith(id: docRef.id);
      
      AppLogger.info('Created workshop: ${createdWorkshop.title}');
      return Success(createdWorkshop);
    } catch (e) {
      AppLogger.error('Error creating workshop', exception: e);
      return Failure(DataException('Failed to create workshop: ${e.toString()}'));
    }
  }

  Future<Result<Workshop>> updateWorkshop(Workshop workshop) async {
    try {
      final updatedWorkshop = workshop.copyWith(updatedAt: DateTime.now());
      final workshopDto = WorkshopDto.fromDomain(updatedWorkshop);
      
      await _firestore
          .collection(AppConstants.workshopsCollection)
          .doc(workshop.id)
          .update(workshopDto.toFirestore());

      AppLogger.info('Updated workshop: ${updatedWorkshop.title}');
      return Success(updatedWorkshop);
    } catch (e) {
      AppLogger.error('Error updating workshop', exception: e);
      return Failure(DataException('Failed to update workshop: ${e.toString()}'));
    }
  }

  Future<Result<void>> deleteWorkshop(String id) async {
    try {
      // Check if there are any active bookings for this workshop
      final bookingsQuery = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('itemId', isEqualTo: id)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      if (bookingsQuery.docs.isNotEmpty) {
        return const Failure(BusinessLogicException(
          'Cannot delete workshop with active bookings'
        ));
      }

      // Delete associated time slots
      final timeSlotsQuery = await _firestore
          .collection(AppConstants.timeSlotsCollection)
          .where('itemId', isEqualTo: id)
          .get();

      final batch = _firestore.batch();
      
      // Delete time slots
      for (final doc in timeSlotsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete workshop
      batch.delete(_firestore.collection(AppConstants.workshopsCollection).doc(id));

      await batch.commit();
      
      AppLogger.info('Deleted workshop and associated time slots: $id');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Error deleting workshop', exception: e);
      return Failure(DataException('Failed to delete workshop: ${e.toString()}'));
    }
  }

  // TimeSlot CRUD operations
  Future<Result<List<TimeSlot>>> getTimeSlots({
    String? itemId,
    SlotType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAvailable,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.timeSlotsCollection);

      if (itemId != null) {
        query = query.where('itemId', isEqualTo: itemId);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (isAvailable != null) {
        query = query.where('isAvailable', isEqualTo: isAvailable);
      }

      query = query.orderBy('date').orderBy('startTimeHour').orderBy('startTimeMinute');

      final querySnapshot = await query.get();
      final timeSlots = querySnapshot.docs.map((doc) {
        final timeSlotDto = TimeSlotDto.fromFirestore(doc);
        return timeSlotDto.toDomain(doc.id);
      }).toList();

      AppLogger.info('Retrieved ${timeSlots.length} time slots');
      return Success(timeSlots);
    } catch (e) {
      AppLogger.error('Error getting time slots', exception: e);
      return Failure(DataException('Failed to get time slots: ${e.toString()}'));
    }
  }

  Future<Result<TimeSlot>> createTimeSlot(TimeSlot timeSlot) async {
    try {
      final timeSlotDto = TimeSlotDto.fromDomain(timeSlot);
      final docRef = await _firestore
          .collection(AppConstants.timeSlotsCollection)
          .add(timeSlotDto.toFirestore());

      final createdTimeSlot = timeSlot.copyWith(id: docRef.id);
      
      AppLogger.info('Created time slot: ${createdTimeSlot.timeRangeString}');
      return Success(createdTimeSlot);
    } catch (e) {
      AppLogger.error('Error creating time slot', exception: e);
      return Failure(DataException('Failed to create time slot: ${e.toString()}'));
    }
  }

  Future<Result<TimeSlot>> updateTimeSlot(TimeSlot timeSlot) async {
    try {
      final timeSlotDto = TimeSlotDto.fromDomain(timeSlot);
      
      await _firestore
          .collection(AppConstants.timeSlotsCollection)
          .doc(timeSlot.id)
          .update(timeSlotDto.toFirestore());

      AppLogger.info('Updated time slot: ${timeSlot.timeRangeString}');
      return Success(timeSlot);
    } catch (e) {
      AppLogger.error('Error updating time slot', exception: e);
      return Failure(DataException('Failed to update time slot: ${e.toString()}'));
    }
  }

  Future<Result<void>> deleteTimeSlot(String id) async {
    try {
      // Check if there are any active bookings for this time slot
      final bookingsQuery = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('timeSlotId', isEqualTo: id)
          .where('status', whereIn: ['pending', 'confirmed'])
          .get();

      if (bookingsQuery.docs.isNotEmpty) {
        return const Failure(BusinessLogicException(
          'Cannot delete time slot with active bookings'
        ));
      }

      await _firestore
          .collection(AppConstants.timeSlotsCollection)
          .doc(id)
          .delete();
      
      AppLogger.info('Deleted time slot: $id');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Error deleting time slot', exception: e);
      return Failure(DataException('Failed to delete time slot: ${e.toString()}'));
    }
  }

  // Booking CRUD operations
  Future<Result<List<Booking>>> getBookings({
    String? userId,
    String? timeSlotId,
    String? itemId,
    BookingStatus? status,
    BookingType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.bookingsCollection);

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (timeSlotId != null) {
        query = query.where('timeSlotId', isEqualTo: timeSlotId);
      }

      if (itemId != null) {
        query = query.where('itemId', isEqualTo: itemId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();
      final bookings = querySnapshot.docs.map((doc) {
        final bookingDto = BookingDto.fromFirestore(doc);
        return bookingDto.toDomain(doc.id);
      }).toList();

      AppLogger.info('Retrieved ${bookings.length} bookings');
      return Success(bookings);
    } catch (e) {
      AppLogger.error('Error getting bookings', exception: e);
      return Failure(DataException('Failed to get bookings: ${e.toString()}'));
    }
  }

  Future<Result<Booking>> createBooking(Booking booking) async {
    try {
      // Use transaction to ensure data consistency
      final result = await _firestore.runTransaction<Booking>((transaction) async {
        // Check time slot availability
        final timeSlotRef = _firestore
            .collection(AppConstants.timeSlotsCollection)
            .doc(booking.timeSlotId);
        
        final timeSlotDoc = await transaction.get(timeSlotRef);
        if (!timeSlotDoc.exists) {
          throw const DataException('Time slot not found');
        }

        final timeSlotDto = TimeSlotDto.fromFirestore(timeSlotDoc);
        final timeSlot = timeSlotDto.toDomain(timeSlotDoc.id);

        if (!timeSlot.hasAvailableCapacity) {
          throw const BusinessLogicException('Time slot is fully booked');
        }

        // Create booking
        final bookingDto = BookingDto.fromDomain(booking);
        final bookingRef = _firestore.collection(AppConstants.bookingsCollection).doc();
        transaction.set(bookingRef, bookingDto.toFirestore());

        // Update time slot current bookings
        final updatedTimeSlot = timeSlot.copyWith(
          currentBookings: timeSlot.currentBookings + 1,
        );
        final updatedTimeSlotDto = TimeSlotDto.fromDomain(updatedTimeSlot);
        transaction.update(timeSlotRef, updatedTimeSlotDto.toFirestore());

        return booking.copyWith(id: bookingRef.id);
      });

      AppLogger.info('Created booking: ${result.id}');
      return Success(result);
    } catch (e) {
      AppLogger.error('Error creating booking', exception: e);
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(DataException('Failed to create booking: ${e.toString()}'));
    }
  }

  Future<Result<Booking>> updateBooking(Booking booking) async {
    try {
      final updatedBooking = booking.copyWith(updatedAt: DateTime.now());
      final bookingDto = BookingDto.fromDomain(updatedBooking);
      
      await _firestore
          .collection(AppConstants.bookingsCollection)
          .doc(booking.id)
          .update(bookingDto.toFirestore());

      AppLogger.info('Updated booking: ${updatedBooking.id}');
      return Success(updatedBooking);
    } catch (e) {
      AppLogger.error('Error updating booking', exception: e);
      return Failure(DataException('Failed to update booking: ${e.toString()}'));
    }
  }

  Future<Result<Booking>> cancelBooking(String bookingId, String cancellationReason) async {
    try {
      final result = await _firestore.runTransaction<Booking>((transaction) async {
        // Get booking
        final bookingRef = _firestore
            .collection(AppConstants.bookingsCollection)
            .doc(bookingId);
        
        final bookingDoc = await transaction.get(bookingRef);
        if (!bookingDoc.exists) {
          throw const DataException('Booking not found');
        }

        final bookingDto = BookingDto.fromFirestore(bookingDoc);
        final booking = bookingDto.toDomain(bookingDoc.id);

        if (!booking.isActive) {
          throw const BusinessLogicException('Booking cannot be cancelled');
        }

        // Update booking status
        final cancelledBooking = booking.copyWith(
          status: BookingStatus.cancelled,
          cancelledAt: DateTime.now(),
          cancellationReason: cancellationReason,
          updatedAt: DateTime.now(),
        );

        final updatedBookingDto = BookingDto.fromDomain(cancelledBooking);
        transaction.update(bookingRef, updatedBookingDto.toFirestore());

        // Update time slot current bookings
        final timeSlotRef = _firestore
            .collection(AppConstants.timeSlotsCollection)
            .doc(booking.timeSlotId);
        
        final timeSlotDoc = await transaction.get(timeSlotRef);
        if (timeSlotDoc.exists) {
          final timeSlotDto = TimeSlotDto.fromFirestore(timeSlotDoc);
          final timeSlot = timeSlotDto.toDomain(timeSlotDoc.id);
          
          final updatedTimeSlot = timeSlot.copyWith(
            currentBookings: (timeSlot.currentBookings - 1).clamp(0, timeSlot.maxCapacity),
          );
          final updatedTimeSlotDto = TimeSlotDto.fromDomain(updatedTimeSlot);
          transaction.update(timeSlotRef, updatedTimeSlotDto.toFirestore());
        }

        return cancelledBooking;
      });

      AppLogger.info('Cancelled booking: ${result.id}');
      return Success(result);
    } catch (e) {
      AppLogger.error('Error cancelling booking', exception: e);
      if (e is AppException) {
        return Failure(e);
      }
      return Failure(DataException('Failed to cancel booking: ${e.toString()}'));
    }
  }

  // Batch operations
  Future<Result<void>> createMultipleTimeSlots(List<TimeSlot> timeSlots) async {
    try {
      final batch = _firestore.batch();
      
      for (final timeSlot in timeSlots) {
        final timeSlotDto = TimeSlotDto.fromDomain(timeSlot);
        final docRef = _firestore.collection(AppConstants.timeSlotsCollection).doc();
        batch.set(docRef, timeSlotDto.toFirestore());
      }

      await batch.commit();
      
      AppLogger.info('Created ${timeSlots.length} time slots in batch');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Error creating multiple time slots', exception: e);
      return Failure(DataException('Failed to create time slots: ${e.toString()}'));
    }
  }

  // Analytics and reporting
  Future<Result<Map<String, dynamic>>> getBookingStats({
    DateTime? startDate,
    DateTime? endDate,
    String? itemId,
  }) async {
    try {
      Query query = _firestore.collection(AppConstants.bookingsCollection);

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (itemId != null) {
        query = query.where('itemId', isEqualTo: itemId);
      }

      final querySnapshot = await query.get();
      final bookings = querySnapshot.docs.map((doc) {
        final bookingDto = BookingDto.fromFirestore(doc);
        return bookingDto.toDomain(doc.id);
      }).toList();

      final stats = {
        'totalBookings': bookings.length,
        'confirmedBookings': bookings.where((b) => b.status == BookingStatus.confirmed).length,
        'cancelledBookings': bookings.where((b) => b.status == BookingStatus.cancelled).length,
        'completedBookings': bookings.where((b) => b.status == BookingStatus.completed).length,
        'totalRevenue': bookings
            .where((b) => b.isPaymentCompleted)
            .fold<double>(0, (sum, b) => sum + b.totalAmount),
        'averageBookingValue': bookings.isNotEmpty
            ? bookings.fold<double>(0, (sum, b) => sum + b.totalAmount) / bookings.length
            : 0.0,
      };

      AppLogger.info('Generated booking stats: ${stats['totalBookings']} bookings');
      return Success(stats);
    } catch (e) {
      AppLogger.error('Error getting booking stats', exception: e);
      return Failure(DataException('Failed to get booking stats: ${e.toString()}'));
    }
  }
}
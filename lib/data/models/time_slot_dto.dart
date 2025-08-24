import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/time_slot.dart';

class TimeSlotDto {
  final Timestamp date;
  final int startTimeHour;
  final int startTimeMinute;
  final int endTimeHour;
  final int endTimeMinute;
  final String type;
  final String? itemId;
  final bool isAvailable;
  final int maxCapacity;
  final int currentBookings;
  final double? price;
  final Timestamp createdAt;

  const TimeSlotDto({
    required this.date,
    required this.startTimeHour,
    required this.startTimeMinute,
    required this.endTimeHour,
    required this.endTimeMinute,
    required this.type,
    this.itemId,
    required this.isAvailable,
    required this.maxCapacity,
    required this.currentBookings,
    this.price,
    required this.createdAt,
  });

  factory TimeSlotDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimeSlotDto(
      date: data['date'] ?? Timestamp.now(),
      startTimeHour: data['startTimeHour'] ?? 0,
      startTimeMinute: data['startTimeMinute'] ?? 0,
      endTimeHour: data['endTimeHour'] ?? 0,
      endTimeMinute: data['endTimeMinute'] ?? 0,
      type: data['type'] ?? 'workshop',
      itemId: data['itemId'],
      isAvailable: data['isAvailable'] ?? true,
      maxCapacity: data['maxCapacity'] ?? 0,
      currentBookings: data['currentBookings'] ?? 0,
      price: data['price']?.toDouble(),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date,
      'startTimeHour': startTimeHour,
      'startTimeMinute': startTimeMinute,
      'endTimeHour': endTimeHour,
      'endTimeMinute': endTimeMinute,
      'type': type,
      'itemId': itemId,
      'isAvailable': isAvailable,
      'maxCapacity': maxCapacity,
      'currentBookings': currentBookings,
      'price': price,
      'createdAt': createdAt,
    };
  }

  TimeSlot toDomain(String id) {
    return TimeSlot(
      id: id,
      date: date.toDate(),
      startTime: TimeOfDay(hour: startTimeHour, minute: startTimeMinute),
      endTime: TimeOfDay(hour: endTimeHour, minute: endTimeMinute),
      type: SlotType.values.byName(type),
      itemId: itemId,
      isAvailable: isAvailable,
      maxCapacity: maxCapacity,
      currentBookings: currentBookings,
      price: price,
      createdAt: createdAt.toDate(),
    );
  }

  static TimeSlotDto fromDomain(TimeSlot timeSlot) {
    return TimeSlotDto(
      date: Timestamp.fromDate(timeSlot.date),
      startTimeHour: timeSlot.startTime.hour,
      startTimeMinute: timeSlot.startTime.minute,
      endTimeHour: timeSlot.endTime.hour,
      endTimeMinute: timeSlot.endTime.minute,
      type: timeSlot.type.name,
      itemId: timeSlot.itemId,
      isAvailable: timeSlot.isAvailable,
      maxCapacity: timeSlot.maxCapacity,
      currentBookings: timeSlot.currentBookings,
      price: timeSlot.price,
      createdAt: Timestamp.fromDate(timeSlot.createdAt),
    );
  }
}
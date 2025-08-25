import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_booking_system/domain/entities/workshop.dart';

void main() {
  group('Workshop Entity Tests', () {
    late Workshop testWorkshop;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 1);
      testWorkshop = Workshop(
        id: 'workshop123',
        title: 'Flutter 개발 워크샵',
        description: '플러터를 이용한 모바일 앱 개발을 배우는 워크샵입니다.',
        price: 50000.0,
        capacity: 20,
        imageUrl: 'https://example.com/workshop.jpg',
        tags: ['Flutter', 'Mobile', 'Development'],
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Constructor and Properties', () {
      test('should create workshop with all properties', () {
        expect(testWorkshop.id, 'workshop123');
        expect(testWorkshop.title, 'Flutter 개발 워크샵');
        expect(testWorkshop.description, '플러터를 이용한 모바일 앱 개발을 배우는 워크샵입니다.');
        expect(testWorkshop.price, 50000.0);
        expect(testWorkshop.capacity, 20);
        expect(testWorkshop.imageUrl, 'https://example.com/workshop.jpg');
        expect(testWorkshop.tags, ['Flutter', 'Mobile', 'Development']);
        expect(testWorkshop.createdAt, testDate);
        expect(testWorkshop.updatedAt, testDate);
      });

      test('should create workshop with minimal required properties', () {
        final minimalWorkshop = Workshop(
          id: 'workshop456',
          title: 'Basic Workshop',
          description: 'A basic workshop description.',
          price: 30000.0,
          capacity: 10,
          tags: [],
          createdAt: testDate,
        );

        expect(minimalWorkshop.imageUrl, isNull);
        expect(minimalWorkshop.updatedAt, isNull);
        expect(minimalWorkshop.tags, isEmpty);
      });
    });

    group('copyWith', () {
      test('should create copy with updated properties', () {
        final updatedWorkshop = testWorkshop.copyWith(
          title: 'Updated Workshop',
          price: 60000.0,
          capacity: 25,
        );

        expect(updatedWorkshop.id, testWorkshop.id);
        expect(updatedWorkshop.title, 'Updated Workshop');
        expect(updatedWorkshop.description, testWorkshop.description);
        expect(updatedWorkshop.price, 60000.0);
        expect(updatedWorkshop.capacity, 25);
        expect(updatedWorkshop.imageUrl, testWorkshop.imageUrl);
        expect(updatedWorkshop.tags, testWorkshop.tags);
        expect(updatedWorkshop.createdAt, testWorkshop.createdAt);
        expect(updatedWorkshop.updatedAt, testWorkshop.updatedAt);
      });

      test('should create identical copy when no parameters provided', () {
        final copiedWorkshop = testWorkshop.copyWith();

        expect(copiedWorkshop, equals(testWorkshop));
        expect(copiedWorkshop.hashCode, equals(testWorkshop.hashCode));
      });
    });

    group('Title Validation', () {
      test('should return null for valid title', () {
        expect(Workshop.validateTitle('Valid Workshop Title'), isNull);
        expect(Workshop.validateTitle('워크샵 제목'), isNull);
      });

      test('should return error for null or empty title', () {
        expect(Workshop.validateTitle(null), '워크샵 제목을 입력해주세요');
        expect(Workshop.validateTitle(''), '워크샵 제목을 입력해주세요');
      });

      test('should return error for title too short', () {
        expect(Workshop.validateTitle('AB'), '제목은 3글자 이상이어야 합니다');
      });

      test('should return error for title too long', () {
        final longTitle = 'a' * 101;
        expect(Workshop.validateTitle(longTitle), '제목은 100글자 이하여야 합니다');
      });

      test('should accept title at boundary lengths', () {
        expect(Workshop.validateTitle('ABC'), isNull); // 3 characters
        expect(Workshop.validateTitle('a' * 100), isNull); // 100 characters
      });
    });

    group('Description Validation', () {
      test('should return null for valid description', () {
        expect(Workshop.validateDescription('Valid workshop description'), isNull);
        expect(Workshop.validateDescription('워크샵에 대한 상세한 설명입니다'), isNull);
      });

      test('should return error for null or empty description', () {
        expect(Workshop.validateDescription(null), '워크샵 설명을 입력해주세요');
        expect(Workshop.validateDescription(''), '워크샵 설명을 입력해주세요');
      });

      test('should return error for description too short', () {
        expect(Workshop.validateDescription('Short'), '설명은 10글자 이상이어야 합니다');
      });

      test('should return error for description too long', () {
        final longDescription = 'a' * 1001;
        expect(Workshop.validateDescription(longDescription), '설명은 1000글자 이하여야 합니다');
      });

      test('should accept description at boundary lengths', () {
        expect(Workshop.validateDescription('a' * 10), isNull); // 10 characters
        expect(Workshop.validateDescription('a' * 1000), isNull); // 1000 characters
      });
    });

    group('Price Validation', () {
      test('should return null for valid price', () {
        expect(Workshop.validatePrice(0.0), isNull);
        expect(Workshop.validatePrice(50000.0), isNull);
        expect(Workshop.validatePrice(999999.0), isNull);
      });

      test('should return error for null price', () {
        expect(Workshop.validatePrice(null), '가격을 입력해주세요');
      });

      test('should return error for negative price', () {
        expect(Workshop.validatePrice(-1.0), '가격은 0원 이상이어야 합니다');
        expect(Workshop.validatePrice(-100.0), '가격은 0원 이상이어야 합니다');
      });

      test('should return error for price too high', () {
        expect(Workshop.validatePrice(1000001.0), '가격은 1,000,000원 이하여야 합니다');
      });

      test('should accept price at boundary values', () {
        expect(Workshop.validatePrice(0.0), isNull);
        expect(Workshop.validatePrice(1000000.0), isNull);
      });
    });

    group('Capacity Validation', () {
      test('should return null for valid capacity', () {
        expect(Workshop.validateCapacity(1), isNull);
        expect(Workshop.validateCapacity(50), isNull);
        expect(Workshop.validateCapacity(100), isNull);
      });

      test('should return error for null capacity', () {
        expect(Workshop.validateCapacity(null), '정원을 입력해주세요');
      });

      test('should return error for capacity too low', () {
        expect(Workshop.validateCapacity(0), '정원은 1명 이상이어야 합니다');
        expect(Workshop.validateCapacity(-1), '정원은 1명 이상이어야 합니다');
      });

      test('should return error for capacity too high', () {
        expect(Workshop.validateCapacity(101), '정원은 100명 이하여야 합니다');
      });

      test('should accept capacity at boundary values', () {
        expect(Workshop.validateCapacity(1), isNull);
        expect(Workshop.validateCapacity(100), isNull);
      });
    });

    group('formattedPrice', () {
      test('should format price with Korean Won and commas', () {
        final workshop1 = testWorkshop.copyWith(price: 50000.0);
        expect(workshop1.formattedPrice, '50,000원');

        final workshop2 = testWorkshop.copyWith(price: 1000000.0);
        expect(workshop2.formattedPrice, '1,000,000원');

        final workshop3 = testWorkshop.copyWith(price: 0.0);
        expect(workshop3.formattedPrice, '0원');

        final workshop4 = testWorkshop.copyWith(price: 123456.0);
        expect(workshop4.formattedPrice, '123,456원');
      });
    });

    group('hasAvailableCapacity', () {
      test('should return true when current bookings less than capacity', () {
        expect(testWorkshop.hasAvailableCapacity(0), isTrue);
        expect(testWorkshop.hasAvailableCapacity(10), isTrue);
        expect(testWorkshop.hasAvailableCapacity(19), isTrue);
      });

      test('should return false when current bookings equal or exceed capacity', () {
        expect(testWorkshop.hasAvailableCapacity(20), isFalse);
        expect(testWorkshop.hasAvailableCapacity(21), isFalse);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all properties are same', () {
        final sameWorkshop = Workshop(
          id: 'workshop123',
          title: 'Flutter 개발 워크샵',
          description: '플러터를 이용한 모바일 앱 개발을 배우는 워크샵입니다.',
          price: 50000.0,
          capacity: 20,
          imageUrl: 'https://example.com/workshop.jpg',
          tags: ['Flutter', 'Mobile', 'Development'],
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(testWorkshop, equals(sameWorkshop));
        expect(testWorkshop.hashCode, equals(sameWorkshop.hashCode));
      });

      test('should not be equal when properties differ', () {
        final differentWorkshop = testWorkshop.copyWith(title: 'Different Title');

        expect(testWorkshop, isNot(equals(differentWorkshop)));
        expect(testWorkshop.hashCode, isNot(equals(differentWorkshop.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation with key properties', () {
        final workshopString = testWorkshop.toString();

        expect(workshopString, contains('Workshop('));
        expect(workshopString, contains('id: workshop123'));
        expect(workshopString, contains('title: Flutter 개발 워크샵'));
        expect(workshopString, contains('price: 50000.0'));
        expect(workshopString, contains('capacity: 20'));
      });
    });
  });

  group('WorkshopFilter Tests', () {
    group('Constructor and Properties', () {
      test('should create filter with all properties', () {
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 12, 31);
        final filter = WorkshopFilter(
          searchQuery: 'Flutter',
          minPrice: 10000.0,
          maxPrice: 100000.0,
          tags: ['Development', 'Mobile'],
          startDate: startDate,
          endDate: endDate,
        );

        expect(filter.searchQuery, 'Flutter');
        expect(filter.minPrice, 10000.0);
        expect(filter.maxPrice, 100000.0);
        expect(filter.tags, ['Development', 'Mobile']);
        expect(filter.startDate, startDate);
        expect(filter.endDate, endDate);
      });

      test('should create empty filter', () {
        final filter = WorkshopFilter.empty();

        expect(filter.searchQuery, isNull);
        expect(filter.minPrice, isNull);
        expect(filter.maxPrice, isNull);
        expect(filter.tags, isNull);
        expect(filter.startDate, isNull);
        expect(filter.endDate, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated properties', () {
        final originalFilter = WorkshopFilter(
          searchQuery: 'Original',
          minPrice: 10000.0,
        );

        final updatedFilter = originalFilter.copyWith(
          searchQuery: 'Updated',
          maxPrice: 50000.0,
        );

        expect(updatedFilter.searchQuery, 'Updated');
        expect(updatedFilter.minPrice, 10000.0);
        expect(updatedFilter.maxPrice, 50000.0);
        expect(updatedFilter.tags, isNull);
      });
    });

    group('isEmpty and hasFilters', () {
      test('should return true for empty filter', () {
        final emptyFilter = WorkshopFilter.empty();
        expect(emptyFilter.isEmpty, isTrue);
        expect(emptyFilter.hasFilters, isFalse);
      });

      test('should return false for filter with search query', () {
        final filter = WorkshopFilter(searchQuery: 'Flutter');
        expect(filter.isEmpty, isFalse);
        expect(filter.hasFilters, isTrue);
      });

      test('should return false for filter with price range', () {
        final filter = WorkshopFilter(minPrice: 10000.0, maxPrice: 50000.0);
        expect(filter.isEmpty, isFalse);
        expect(filter.hasFilters, isTrue);
      });

      test('should return false for filter with tags', () {
        final filter = WorkshopFilter(tags: ['Development']);
        expect(filter.isEmpty, isFalse);
        expect(filter.hasFilters, isTrue);
      });

      test('should return true for filter with empty tags list', () {
        final filter = WorkshopFilter(tags: []);
        expect(filter.isEmpty, isTrue);
        expect(filter.hasFilters, isFalse);
      });
    });

    group('Equality and HashCode', () {
      test('should be equal when all properties are same', () {
        final filter1 = WorkshopFilter(
          searchQuery: 'Flutter',
          minPrice: 10000.0,
          maxPrice: 50000.0,
          tags: ['Development'],
        );

        final filter2 = WorkshopFilter(
          searchQuery: 'Flutter',
          minPrice: 10000.0,
          maxPrice: 50000.0,
          tags: ['Development'],
        );

        expect(filter1, equals(filter2));
        expect(filter1.hashCode, equals(filter2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final filter1 = WorkshopFilter(searchQuery: 'Flutter');
        final filter2 = WorkshopFilter(searchQuery: 'React');

        expect(filter1, isNot(equals(filter2)));
        expect(filter1.hashCode, isNot(equals(filter2.hashCode)));
      });
    });

    group('toString', () {
      test('should return string representation with properties', () {
        final filter = WorkshopFilter(
          searchQuery: 'Flutter',
          minPrice: 10000.0,
          maxPrice: 50000.0,
          tags: ['Development'],
        );

        final filterString = filter.toString();

        expect(filterString, contains('WorkshopFilter('));
        expect(filterString, contains('searchQuery: Flutter'));
        expect(filterString, contains('minPrice: 10000.0'));
        expect(filterString, contains('maxPrice: 50000.0'));
        expect(filterString, contains('tags: [Development]'));
      });
    });
  });
}
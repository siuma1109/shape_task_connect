import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/location.dart' as loc;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shape_task_connect/services/location_service.dart';

// Generate mock classes
@GenerateNiceMocks([
  MockSpec<loc.Location>(),
  MockSpec<BuildContext>(),
])
import 'location_service_test.mocks.dart';

void main() {
  late LocationService locationService;
  late MockLocation mockLocation;
  late MockBuildContext mockContext;

  setUp(() {
    mockLocation = MockLocation();
    mockContext = MockBuildContext();
    locationService = LocationService();
    // Replace the real Location instance with our mock
    locationService.location = mockLocation;
  });

  group('LocationService', () {
    test('checkPermission returns true when permission is granted', () async {
      when(mockLocation.hasPermission())
          .thenAnswer((_) async => loc.PermissionStatus.granted);

      final result = await locationService.checkPermission(mockContext);

      expect(result, true);
      verify(mockLocation.hasPermission()).called(1);
      verifyNoMoreInteractions(mockLocation);
    });

    test('checkPermission requests permission when initially denied', () async {
      when(mockLocation.hasPermission())
          .thenAnswer((_) async => loc.PermissionStatus.denied);
      when(mockLocation.requestPermission())
          .thenAnswer((_) async => loc.PermissionStatus.granted);

      final result = await locationService.checkPermission(mockContext);

      expect(result, true);
      verify(mockLocation.hasPermission()).called(1);
      verify(mockLocation.requestPermission()).called(1);
    });
  });
}

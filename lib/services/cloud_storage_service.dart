// Abstraction for Google Integrations
abstract class CloudStorageService {
  Future<void> backupDataToGoogleDrive();
  Future<void> restoreDataFromGoogleDrive();
  Future<void> syncWithGoogleCalendar();
}

class MockCloudStorageService implements CloudStorageService {
  @override
  Future<void> backupDataToGoogleDrive() async {
    // Stub: Serialize Hive boxes to JSON and upload to Google Drive AppFolder
    await Future.delayed(const Duration(seconds: 2));
    print("Backup to Google Drive (Mock) completed.");
  }

  @override
  Future<void> restoreDataFromGoogleDrive() async {
    // Stub: Download JSON and put into Hive
    await Future.delayed(const Duration(seconds: 2));
    print("Restore from Google Drive (Mock) completed.");
  }

  @override
  Future<void> syncWithGoogleCalendar() async {
    // Stub: Fetch tasks with due dates -> Push to Google Calendar API
    await Future.delayed(const Duration(seconds: 2));
    print("Google Calendar Sync (Mock) completed.");
  }
}
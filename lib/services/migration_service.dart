import 'post_service.dart';
import 'local_storage_service.dart';

class MigrationService {
  final PostService _postService = PostService();
  final LocalStorageService _localStorageService = LocalStorageService();

  /// Run all necessary migrations for Phase 2
  Future<void> runPhase2Migrations() async {
    try {
      // Migrate database posts from gender to world schema
      await _postService.migrateGenderToWorldSchema();
      
      // Migrate local storage: ensure user has world set
      await _migrateLocalUserWorld();
      
      print('✅ Phase 2 migration completed successfully');
    } catch (e) {
      print('❌ Phase 2 migration failed: $e');
      rethrow;
    }
  }

  /// Migrate local user from gender to world in SharedPreferences
  Future<void> _migrateLocalUserWorld() async {
    final currentWorld = await _localStorageService.getWorld();
    
    // If world is already set, no migration needed
    if (currentWorld != null) {
      print('✅ User world already set: $currentWorld');
      return;
    }
    
    // Migrate from gender if available
    final gender = await _localStorageService.getGender();
    if (gender == 'girl') {
      await _localStorageService.setWorld('Girl Meets College');
      print('✅ Migrated user from girl → Girl Meets College');
    } else if (gender == 'boy') {
      await _localStorageService.setWorld('Guy Meets College');
      print('✅ Migrated user from boy → Guy Meets College');
    } else {
      // Default to Girl Meets College for backward compatibility
      await _localStorageService.setWorld('Girl Meets College');
      print('✅ Set default world: Girl Meets College');
    }
  }

  /// Check if Phase 2 migration is needed
  Future<bool> isPhase2MigrationNeeded() async {
    // Check if user has world set
    final userWorld = await _localStorageService.getWorld();
    return userWorld == null;
  }

  /// Get migration status summary
  Future<Map<String, dynamic>> getMigrationStatus() async {
    final userWorld = await _localStorageService.getWorld();
    final userGender = await _localStorageService.getGender();
    
    return {
      'phase2_needed': userWorld == null,
      'current_world': userWorld,
      'legacy_gender': userGender,
      'migration_complete': userWorld != null,
    };
  }
}
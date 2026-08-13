import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambalinks/core/database/app_database.dart';
import 'package:sambalinks/core/database/daos/settings_dao.dart';
import 'package:sambalinks/core/providers.dart';
import 'package:sambalinks/features/links/domain/link_query.dart';

import '../../core/database/database_test_helpers.dart';

void main() {
  test('la ordenación elegida persiste en settings', () async {
    final AppDatabase database = openTestDatabase();
    addTearDown(database.close);
    final ProviderContainer container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(cardSortPreferenceProvider.future),
      CardSort.newest,
    );
    await container
        .read(cardSortPreferenceProvider.notifier)
        .setSort(CardSort.titleDesc);

    expect(
      await database.settingsDao.read<String>(SettingsKeys.defaultSort),
      CardSort.titleDesc.name,
    );
    expect(
      container.read(cardSortPreferenceProvider).value,
      CardSort.titleDesc,
    );
  });
}

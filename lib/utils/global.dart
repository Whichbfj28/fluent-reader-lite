import 'package:fluent_reader_lite/models/feeds_model.dart';
import 'package:fluent_reader_lite/models/global_model.dart';
import 'package:fluent_reader_lite/models/groups_model.dart';
import 'package:fluent_reader_lite/models/items_model.dart';
import 'package:fluent_reader_lite/models/service.dart';
import 'package:fluent_reader_lite/models/services/fever.dart';
import 'package:fluent_reader_lite/models/sources_model.dart';
import 'package:fluent_reader_lite/models/sync_model.dart';
import 'package:fluent_reader_lite/utils/db.dart';
import 'package:fluent_reader_lite/utils/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

abstract class Global {
  static bool _initialized = false;
  static GlobalModel globalModel;
  static SourcesModel sourcesModel;
  static ItemsModel itemsModel;
  static FeedsModel feedsModel;
  static GroupsModel groupsModel;
  static SyncModel syncModel;
  static ServiceHandler service;
  static Database db;
  static final GlobalKey<NavigatorState> tabletPanel = GlobalKey();

  static void init() {
    assert(!_initialized);
    _initialized = true;
    globalModel = GlobalModel();
    sourcesModel = SourcesModel();
    itemsModel = ItemsModel();
    feedsModel = FeedsModel();
    groupsModel = GroupsModel();
    var serviceType = SyncService.values[Store.sp.getInt(StoreKeys.SYNC_SERVICE) ?? 0];
    switch (serviceType) {
      case SyncService.None:
        break;
      case SyncService.Fever:
        service = FeverServiceHandler();
        break;
      case SyncService.Feedbin:
        // TODO: Handle this case.
        break;
      case SyncService.GReader:
        // TODO: Handle this case.
        break;
      case SyncService.Inoreader:
        // TODO: Handle this case.
        break;
    }
    syncModel = SyncModel();
    _initContents();
  }

  static void _initContents() async {
    db = await DatabaseHelper.getDatabase();
    await db.delete(
      "items",
      where: "date < ?",
      whereArgs: [
        DateTime.now()
          .subtract(Duration(days: globalModel.keepItemsDays))
          .millisecondsSinceEpoch,
      ],
    );
    await sourcesModel.init();
    await feedsModel.all.init();
    if (globalModel.syncOnStart) await syncModel.syncWithService();
  }

  static Brightness currentBrightness(BuildContext context) {
    return globalModel.getBrightness() ?? MediaQuery.of(context).platformBrightness;
  }

  static bool get isTablet => tabletPanel.currentWidget != null;

  static NavigatorState responsiveNavigator(BuildContext context) {
    return tabletPanel.currentWidget != null
      ? Global.tabletPanel.currentState
      : Navigator.of(context, rootNavigator: true);
  }
}
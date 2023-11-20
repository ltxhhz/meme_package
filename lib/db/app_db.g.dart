// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  GroupDao? _groupDaoInstance;

  ImageDao? _imageDaoInstance;

  TagDao? _tagDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `groups` (`gid` INTEGER PRIMARY KEY AUTOINCREMENT, `label` TEXT NOT NULL, `sequence` INTEGER NOT NULL, `uuid` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `images` (`iid` INTEGER PRIMARY KEY AUTOINCREMENT, `hash` TEXT NOT NULL, `filename` TEXT NOT NULL, `gid` INTEGER NOT NULL, `time` INTEGER NOT NULL, `sequence` INTEGER NOT NULL, `mime` TEXT NOT NULL, `content` TEXT NOT NULL, FOREIGN KEY (`gid`) REFERENCES `groups` (`gid`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `tags` (`tid` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `iid` INTEGER NOT NULL, FOREIGN KEY (`iid`) REFERENCES `images` (`iid`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_images_hash` ON `images` (`hash`)');
        await database
            .execute('CREATE INDEX `index_tags_name` ON `tags` (`name`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  GroupDao get groupDao {
    return _groupDaoInstance ??= _$GroupDao(database, changeListener);
  }

  @override
  ImageDao get imageDao {
    return _imageDaoInstance ??= _$ImageDao(database, changeListener);
  }

  @override
  TagDao get tagDao {
    return _tagDaoInstance ??= _$TagDao(database, changeListener);
  }
}

class _$GroupDao extends GroupDao {
  _$GroupDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _groupsInsertionAdapter = InsertionAdapter(
            database,
            'groups',
            (Groups item) => <String, Object?>{
                  'gid': item.gid,
                  'label': item.label,
                  'sequence': item.sequence,
                  'uuid': item.uuid
                }),
        _imageItemDeletionAdapter = DeletionAdapter(
            database,
            'images',
            ['iid'],
            (ImageItem item) => <String, Object?>{
                  'iid': item.iid,
                  'hash': item.hash,
                  'filename': item.filename,
                  'gid': item.gid,
                  'time': _dateTimeConverter.encode(item.time),
                  'sequence': item.sequence,
                  'mime': item.mime,
                  'content': item.content
                }),
        _groupsDeletionAdapter = DeletionAdapter(
            database,
            'groups',
            ['gid'],
            (Groups item) => <String, Object?>{
                  'gid': item.gid,
                  'label': item.label,
                  'sequence': item.sequence,
                  'uuid': item.uuid
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Groups> _groupsInsertionAdapter;

  final DeletionAdapter<ImageItem> _imageItemDeletionAdapter;

  final DeletionAdapter<Groups> _groupsDeletionAdapter;

  @override
  Future<List<Groups>> getAllGroups() async {
    return _queryAdapter.queryList('SELECT * FROM \"groups\"',
        mapper: (Map<String, Object?> row) => Groups(
            gid: row['gid'] as int?,
            label: row['label'] as String,
            sequence: row['sequence'] as int,
            uuid: row['uuid'] as String));
  }

  @override
  Future<List<ImageItem>> getAllImages(int gid) async {
    return _queryAdapter.queryList('SELECT * FROM images where gid=?1',
        mapper: (Map<String, Object?> row) => ImageItem(
            iid: row['iid'] as int?,
            hash: row['hash'] as String,
            filename: row['filename'] as String,
            gid: row['gid'] as int,
            time: _dateTimeConverter.decode(row['time'] as int),
            sequence: row['sequence'] as int,
            mime: row['mime'] as String,
            content: row['content'] as String),
        arguments: [gid]);
  }

  @override
  Future<int?> getMaxSequence() async {
    return _queryAdapter.query('SELECT MAX(sequence) FROM groups;',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> addGroup(Groups group) {
    return _groupsInsertionAdapter.insertAndReturnId(
        group, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeImage(ImageItem imageItem) {
    return _imageItemDeletionAdapter.deleteAndReturnChangedRows(imageItem);
  }

  @override
  Future<int> removeImages(List<ImageItem> imageItem) {
    return _imageItemDeletionAdapter.deleteListAndReturnChangedRows(imageItem);
  }

  @override
  Future<int> removeGroup(Groups group) {
    return _groupsDeletionAdapter.deleteAndReturnChangedRows(group);
  }
}

class _$ImageDao extends ImageDao {
  _$ImageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _imageItemInsertionAdapter = InsertionAdapter(
            database,
            'images',
            (ImageItem item) => <String, Object?>{
                  'iid': item.iid,
                  'hash': item.hash,
                  'filename': item.filename,
                  'gid': item.gid,
                  'time': _dateTimeConverter.encode(item.time),
                  'sequence': item.sequence,
                  'mime': item.mime,
                  'content': item.content
                }),
        _imageItemUpdateAdapter = UpdateAdapter(
            database,
            'images',
            ['iid'],
            (ImageItem item) => <String, Object?>{
                  'iid': item.iid,
                  'hash': item.hash,
                  'filename': item.filename,
                  'gid': item.gid,
                  'time': _dateTimeConverter.encode(item.time),
                  'sequence': item.sequence,
                  'mime': item.mime,
                  'content': item.content
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ImageItem> _imageItemInsertionAdapter;

  final UpdateAdapter<ImageItem> _imageItemUpdateAdapter;

  @override
  Future<int?> getMaxSequence() async {
    return _queryAdapter.query('SELECT MAX(sequence) FROM images;',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> addImage(ImageItem imageItem) {
    return _imageItemInsertionAdapter.insertAndReturnId(
        imageItem, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> addImages(List<ImageItem> imageItem) {
    return _imageItemInsertionAdapter.insertListAndReturnIds(
        imageItem, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateImage(ImageItem imageItem) {
    return _imageItemUpdateAdapter.updateAndReturnChangedRows(
        imageItem, OnConflictStrategy.abort);
  }
}

class _$TagDao extends TagDao {
  _$TagDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _tagInsertionAdapter = InsertionAdapter(
            database,
            'tags',
            (Tag item) => <String, Object?>{
                  'tid': item.tid,
                  'name': item.name,
                  'iid': item.iid
                }),
        _tagUpdateAdapter = UpdateAdapter(
            database,
            'tags',
            ['tid'],
            (Tag item) => <String, Object?>{
                  'tid': item.tid,
                  'name': item.name,
                  'iid': item.iid
                }),
        _tagDeletionAdapter = DeletionAdapter(
            database,
            'tags',
            ['tid'],
            (Tag item) => <String, Object?>{
                  'tid': item.tid,
                  'name': item.name,
                  'iid': item.iid
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Tag> _tagInsertionAdapter;

  final UpdateAdapter<Tag> _tagUpdateAdapter;

  final DeletionAdapter<Tag> _tagDeletionAdapter;

  @override
  Future<List<Tag>> getTag(int tid) async {
    return _queryAdapter.queryList('select * from tags where tid=?1',
        mapper: (Map<String, Object?> row) => Tag(
            tid: row['tid'] as int?,
            iid: row['iid'] as int,
            name: row['name'] as String),
        arguments: [tid]);
  }

  @override
  Future<List<Tag>> getTagByIid(int iid) async {
    return _queryAdapter.queryList('select * from tags where iid=?1',
        mapper: (Map<String, Object?> row) => Tag(
            tid: row['tid'] as int?,
            iid: row['iid'] as int,
            name: row['name'] as String),
        arguments: [iid]);
  }

  @override
  Future<int> addTag(Tag tag) {
    return _tagInsertionAdapter.insertAndReturnId(
        tag, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateTag(Tag tag) {
    return _tagUpdateAdapter.updateAndReturnChangedRows(
        tag, OnConflictStrategy.abort);
  }

  @override
  Future<int> removeTag(Tag tag) {
    return _tagDeletionAdapter.deleteAndReturnChangedRows(tag);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();

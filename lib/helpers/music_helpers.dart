import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

String idColumn = "idColumn";
String titleColumn = "titleColumn";
String artistColumn = "artistColumn";
String albumColumn = "albumColumn";
String genreColumn = "genreColumn";
String contactTable = "MusicTable";

class MusicHelper {
  static final MusicHelper _instance = MusicHelper.internal();
  factory MusicHelper() => _instance;

  MusicHelper.internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

Future<Database> initDb() async {
  final databasesPath = await getDatabasesPath();
  final path = "$databasesPath/music.db";

  return await openDatabase(path, version: 2, // Alterei a versão para 2
    onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE musicTable($idColumn INTEGER PRIMARY KEY, $titleColumn TEXT, $artistColumn TEXT, $albumColumn TEXT, $genreColumn TEXT, imgColumn TEXT)"
      );
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      if (oldVersion < 2) {
        // Atualiza o banco de dados, adicionando a coluna imgColumn se ela não existir
        await db.execute("ALTER TABLE musicTable ADD COLUMN imgColumn TEXT");
      }
    },
  );
}


  Future<Music> saveMusic(Music music) async {
    Database dbMusic = await db;
    print("Inserting music: ${music.toMap()}"); // Log para verificar o mapa
    music.id = await dbMusic.insert("musicTable", music.toMap());
    return music;
  }

  Future<Music?> getMusic(int id) async {
    Database dbMusic = await db;
    List<Map> maps = await dbMusic.query(
      "musicTable",
      columns: [idColumn, titleColumn, artistColumn, albumColumn, genreColumn],
      where: "$idColumn = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Music.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Music>> getAllMusic() async {
    Database dbMusic = await db;
    List<Map> listMap = await dbMusic.rawQuery("SELECT * FROM musicTable");
    List<Music> musicList = listMap.map((map) => Music.fromMap(map)).toList();
    return musicList;
  }

  Future<int> deleteMusic(int id) async {
    Database dbMusic = await db;
    return await dbMusic.delete(
      "musicTable",
      where: "$idColumn = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateMusic(Music music) async {
    Database dbMusic = await db;
    return await dbMusic.update(
      "musicTable",
      music.toMap(),
      where: "$idColumn = ?",
      whereArgs: [music.id],
    );
  }

  Future close() async {
    Database dbMusic = await db;
    dbMusic.close();
  }
}

class Music {
  int? id;
  String? title;
  String? artist;
  String? album;
  String? genre;
  String? img;

  Music();

  Music.fromMap(Map map) {
    id = map[idColumn];
    title = map[titleColumn];
    artist = map[artistColumn];
    album = map[albumColumn];
    genre = map[genreColumn];
    img = map['imgColumn'];
  }

  Map<String, dynamic> toMap() {
    final map = {
      titleColumn: title,
      artistColumn: artist,
      albumColumn: album,
      genreColumn: genre,
      'imgColumn': img,
    };
    if (id != null) {
      map[idColumn] = id.toString();
    }
    return map;
  }

  @override
  String toString() {
    return "Music(id: $id, title: $title, artist: $artist, album: $album, genre: $genre, img: $img)";
  }
}

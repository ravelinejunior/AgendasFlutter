import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String imageColumn = "imageColumn";
final String phoneColumn = "phoneColumn";
final String contactTable = "contactTable";

class ContactHelper {
//como essa classe terá apenas um objeto, seu padrão será tipo Singleton
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      //caso banco de dados ja tenha sido inicializado
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contacts.db");

    //abrir o banco de dados
    return await openDatabase(path,
        version: 1,
        onCreate: (db, newerVersion) async => await db.execute(
            "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY," +
                " $nameColumn TEXT, " +
                "$emailColumn TEXT," +
                "$phoneColumn TEXT," +
                "$imageColumn TEXT)"));
  }

//salvar contato
  Future<Contact> saveContact(Contact contact) async {
    //obter banco de dados
    Database dbContact = await db;
    //inserir contato
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

//pegar contato
  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else
      return null;
  }

//deletar contato
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: ]id]);

  }

  //editar(atualizar contato)
  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
    where: "$idColumn = ?",
    whereArgs: [contact.id]);
  }

  //recuperar todos os contatos
   Future<List> getAllContacts() async{
    Database dbContacts = await db;
    List listMap = await dbContacts.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //OBTER NUMERO DE CONTATOS DA LISTA
  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //fechar o banco de dados
  Future closeDb() async{
    Database dbContact = await db;
    dbContact.close();     
  }

  //FIM CLASSE CONTACT HELPER
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String image;

  Contact.fromMap(Map map) {
    // para armazenar os contatos em forma de mapa
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
  }

  //para transformar os dados das colunas em maps
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: image
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    // TODO: implement toString
    return "Contatc(id: $id, name: $name, email: $email, phone: $phone, image: $image)";
  }
}

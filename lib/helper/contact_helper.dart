import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String idColumn = "idColumn";
final String nameColumn = "nameColumn";

final String imageColumn = "imageColumn";
final String phoneColumn = "phoneColumn";
final String phonesColumn = "phonesColumn";
final String cpfColumn = "cpfColumn";
final String ufColumn = "ufColumn";
final String dateBornColumn = "dateBornColumn";
final String dateRegisterColumn = "dateRegisterColumn";
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
                  "$phoneColumn TEXT," +
                  "$imageColumn TEXT," +
                  "$cpfColumn TEXT," +
                  "$ufColumn TEXT," +
                  "$dateBornColumn TEXT," +
                  "$dateRegisterColumn TEXT ," +
                  "$phonesColumn TEXT ) ",
            ));
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
        columns: [
          idColumn,
          nameColumn,
          phoneColumn,
          imageColumn,
          dateBornColumn,
          dateRegisterColumn,
          cpfColumn,
          phonesColumn
        ],
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
    return await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //editar(atualizar contato)
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //recuperar todos os contatos
  Future<List> getAllContacts() async {
    Database dbContacts = await db;
    List listMap = await dbContacts.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //OBTER NUMERO DE CONTATOS DA LISTA
  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //obter numeros

  //fechar o banco de dados
  Future closeDb() async {
    Database dbContact = await db;
    dbContact.close();
  }

  //FIM CLASSE CONTACT HELPER
}

class Contact {
  int id;
  String name;
  String phone;
  String image;
  String uf;
  String cpf;
  String dateRegister;
  String dateBorn;
  List<String> phones;
  Contact();
  Contact.fromMap(Map map) {
    // para armazenar os contatos em forma de mapas
    id = map[idColumn];
    name = map[nameColumn];
    phone = map[phoneColumn];
    image = map[imageColumn];
    uf = map[ufColumn];
    dateBorn = map[dateBornColumn];
    dateRegister = map[dateRegisterColumn];
    cpf = map[cpfColumn];
    phones = map[phonesColumn];
  }

  //para transformar os dados das colunas em maps
  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      phoneColumn: phone,
      imageColumn: image,
      ufColumn: uf,
      dateBornColumn: dateBorn,
      dateRegisterColumn: dateRegister,
      cpfColumn: cpf,
      phonesColumn: phones
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contatc(id: $id, name: $name, phone: $phone, image: $image)";
  }
}

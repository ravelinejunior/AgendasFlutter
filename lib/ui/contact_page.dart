import 'dart:convert';
import 'dart:io';
import 'package:agenda_app/helper/contact_helper.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  int numberList;
  ContactPage({this.contact, this.numberList});
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _userEdited = false;
  List phoneList = [];

  void _addPhone() {
    if (_phoneController.text.isNotEmpty)
      setState(() {
        Map<String, dynamic> newPhone = Map();
        newPhone['phone'] = _phoneController.text;
        _phoneController.clear();
        phoneList.add(newPhone);
        _userEdited = true;
        _saveData();
      });
  }

  final _nameController = TextEditingController();
  final _cpfController = MaskedTextController(mask: '000.000.000-00');
  final _phoneController = MaskedTextController(mask: '(00) 00000-0000');
  final _dateController = TextEditingController();
  final _ufController = TextEditingController();
  final _nameFocus = FocusNode();

  DateTime dateTime = DateTime.now();

  bool majorAge = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _cpfController.text = _editedContact.cpf;
      _phoneController.text = _editedContact.phone;
      _dateController.text = _editedContact.dateBorn;
      _ufController.text = _editedContact.uf;
    }

    _readData().then((data) {
      setState(() {
        phoneList = json.decode(data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: actionBar(),
        floatingActionButton: fab(),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  child: containerImage(),
                  // ignore: deprecated_member_use
                  onTap: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);
                    File _image = File(pickedFile.path);
                    setState(() {
                      _editedContact.image = _image.path;
                    });
                    _userEdited = true;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                editName(),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                editCpf(),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                editDateBorn(),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                editUf(),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                phones(),
              ],
            ),
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  //alert de saida
  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações"),
              content:
                  Text("Se sair sem salvar, suas alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancelar"),
                ),
                FlatButton(
                  onPressed: () {
                    _deleteData();
                    //um pop para remover o dialog e outro para remover o ContactPage
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text("Confirmar"),
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      //caso usuario tenha feito alguma alteração
      return Future.value(true);
    }
  }

  //fab
  Widget fab() {
    return FloatingActionButton(
      onPressed: () {
        if (_editedContact.name != null &&
            _editedContact.name.isNotEmpty &&
            majorAge) {
          //elimina o elemento de cima (a pagina inteira no caso, num esquema de pilha LiFo)
          //e enviei o editedContact como valor
          if (formKey.currentState.validate()) {
            String _formatDate = formatDate(dateTime, [dd, '/', mm, '/', yyyy]);

            _editedContact.dateRegister = _formatDate;
            Navigator.pop(context, _editedContact);
            _deleteData();
          }
        } else if (!majorAge) {
          showDialog(
              context: context,
              child: AlertDialog(
                title: Text('Idade do cliente não permitida'),
                content: Text(
                    'Cliente deve ter no minino 18 anos para ser cadastrado no sistema.'),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Ok"),
                  ),
                ],
              ));
        } else {
          FocusScope.of(context).requestFocus(_nameFocus);
        }
      },
      child: Icon(Icons.save),
      backgroundColor: Colors.red,
      splashColor: Colors.orange,
      foregroundColor: Colors.white,
    );
  }

  //actionBar
  Widget actionBar() {
    return AppBar(
      title: Text(
        _editedContact.name ?? "Novo Cliente",
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.red,
      elevation: 0.0,
      centerTitle: true,
    );
  }

  //image
  Widget containerImage() {
    return Container(
      width: 150.0,
      height: 150.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
            image: _editedContact.image != null
                ? FileImage(File(_editedContact.image))
                : AssetImage("images/icon.png"),
            fit: BoxFit.cover),
      ),
    );
  }

  //editar nome
  Widget editName() {
    return TextField(
      maxLength: 30,
      focusNode: _nameFocus,
      controller: _nameController,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: "Nome",
        prefixIcon: Icon(Icons.person),
      ),
      onChanged: (text) {
        _userEdited = true;
        setState(() {
          _editedContact.name = text;
        });
      },
    );
  }

  //editar cpf
  Widget editCpf() {
    return TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          if (_ufController.text == 'SP' ||
              _ufController.text == 'sp' ||
              _ufController.text == 'Sp')
            return 'Campo Obrigatório';
          else
            return null;
        } else
          return null;
      },
      maxLength: 15,
      controller: _cpfController,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: "Cpf",
        prefixIcon: Icon(Icons.insert_drive_file),
      ),
      onChanged: (text) {
        _userEdited = true;
        _editedContact.cpf = text;
      },
      keyboardType: TextInputType.number,
    );
  }

  //editar dateBorn
  Widget editDateBorn() {
    return TextFormField(
        validator: (value) {
          if (value.isEmpty) {
            if (_ufController.text == 'MG' ||
                _ufController.text == 'mg' ||
                _ufController.text == 'Mg')
              return 'Cliente deve ser maior de idade.';
            else
              return null;
          } else
            return null;
        },
        maxLength: 12,
        enableInteractiveSelection: false,
        controller: _dateController,
        showCursor: false,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          labelText: "Data Nascimento",
          prefixIcon: Icon(Icons.date_range),
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());

          showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1910),
            lastDate: DateTime(2100),
          ).then(
            (value) {
              _dateController.text =
                  formatDate(value, [dd, '/', mm, '/', yyyy]);

              var _formatDateYear =
                  int.parse(formatDate(DateTime.now(), [yyyy]));

              int year = value.year;

              if (_ufController.text == 'MG' ||
                  _ufController.text == 'mg' ||
                  _ufController.text == 'Mg') {
                if (_formatDateYear - year >= 18)
                  majorAge = true;
                else
                  majorAge = false;
              }

              _userEdited = true;
              _editedContact.dateBorn = _dateController.text;
            },
          );
        });
  }

  //editar uf
  Widget editUf() {
    return TextFormField(
      maxLength: 2,
      controller: _ufController,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: "UF",
        prefixIcon: Icon(Icons.location_city),
      ),
      onChanged: (text) {
        _userEdited = true;
        _editedContact.uf = text;
      },
      keyboardType: TextInputType.text,
    );
  }

  Widget phones() {
    return Container(
      height: 400,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  maxLength: 15,
                  controller: _phoneController,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    labelText: "Telefone",
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact.phone = text;
                  },
                  keyboardType: TextInputType.phone,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 15, bottom: 20),
                child: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 25,
                  child: IconButton(
                    alignment: Alignment.center,
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _addPhone,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10.0),
              itemBuilder: (context, index) {
                return _editedContact.id == null
                    ? ListTile(
                        title: _editedContact.id == null
                            ? Text(phoneList[index]['phone'])
                            : null,
                        leading: _editedContact.id == null
                            ? Icon(Icons.phone)
                            : null,
                      )
                    : Container();
              },
              itemCount: phoneList.length,
            ),
          ),
        ],
      ),
    );
  }

  //editar phone
  Widget editPhone() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            maxLength: 15,
            controller: _phoneController,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              labelText: "Telefone",
              prefixIcon: Icon(Icons.phone_android),
            ),
            onChanged: (text) {
              _userEdited = true;
              _editedContact.phone = text;
            },
            keyboardType: TextInputType.phone,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30, bottom: 20),
          child: CircleAvatar(
            backgroundColor: Colors.redAccent,
            radius: 25,
            child: IconButton(
              alignment: Alignment.center,
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        )
      ],
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    directory.createSync(recursive: true);
    final bla = File("${directory.path}data.json");
    return bla;
    //return File("${directory.path}data.json");
  }

  Future<File> _saveData() async {
    //transformando lista em arquivo json
    String data = json.encode(phoneList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  Future<Null> _deleteData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final direc = File("${directory.path}data.json");
      direc.deleteSync(recursive: true);
    } catch (e) {
      return null;
    }
  }
}

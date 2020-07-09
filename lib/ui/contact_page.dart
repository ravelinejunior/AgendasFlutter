import 'dart:io';

import 'package:agenda_app/helper/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact});
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
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
              editEmail(),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              editPhone(),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
            ],
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
        if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
          //elimina o elemento de cima (a pagina inteira no caso, num esquema de pilha LiFo) e enviei o editedContact como valor
          Navigator.pop(context, _editedContact);
        } else {
          FocusScope.of(context).requestFocus(_nameFocus);
        }
      },
      child: Icon(Icons.save),
      backgroundColor: Colors.red,
      splashColor: Colors.amber,
      foregroundColor: Colors.white,
    );
  }

  //actionBar
  Widget actionBar() {
    return AppBar(
      title: Text(
        _editedContact.name ?? "Novo Contatinho",
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.red,
      elevation: 10.0,
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
                : AssetImage("images/couple.png"),
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

  //editar email
  Widget editEmail() {
    return TextField(
      maxLength: 30,
      controller: _emailController,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.alternate_email),
      ),
      onChanged: (text) {
        _userEdited = true;
        _editedContact.email = text;
      },
      keyboardType: TextInputType.emailAddress,
    );
  }

  //editar phone
  Widget editPhone() {
    return TextField(
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
    );
  }
}

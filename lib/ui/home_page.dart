import 'dart:io';

import 'package:agenda_app/helper/contact_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contactList = List();

  //quando app carregar, preparar e carregar todos os contatos ja salvos
  @override
  void initState() {
    super.initState();
    helper
        .getAllContacts()
        .then((list) => //para atualizar a lista, setar um setState
            setState(() {
              contactList = list;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: actionBar(),
      backgroundColor: Colors.white,
      floatingActionButton: fab(),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contactList.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  //fab
  Widget fab() {
    return FloatingActionButton(
      onPressed: () {},
      child: Icon(Icons.add),
      backgroundColor: Colors.red,
      splashColor: Colors.amber,
      foregroundColor: Colors.white,
    );
  }

  //actionBar
  Widget actionBar() {
    return AppBar(
      title: Text(
        "Meus Contatinhos",
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.red,
      elevation: 10.0,
      centerTitle: true,
    );
  }

  //contact card
  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        color: Colors.white70,
        elevation: 10,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contactList[index].image != null
                          ? FileImage(File(contactList[index].image))
                          : AssetImage("images/couple.png"),
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _textoNome(index),
                    _textoEmail(index),
                    _textoPhone(index),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //texto nome
  Widget _textoNome(int index) {
    return Text(
        //caso nome seja vazio
        contactList[index].name ?? "",
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ));
  }

  //texto email
  Widget _textoEmail(int index) {
    return Text(
        //caso nome seja vazio
        contactList[index].email ?? "",
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
        ));
  }

  //texto phone
  Widget _textoPhone(int index) {
    return Text(
        //caso nome seja vazio
        contactList[index].phone ?? "",
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
        ));
  }
}

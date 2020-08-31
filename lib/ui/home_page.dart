import 'dart:io';

import 'package:agenda_app/helper/contact_helper.dart';
import 'package:agenda_app/ui/contact_page.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { order_az, order_za }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contactList = List();
  DateTime dateTime = DateTime.now();
  int number = 0;

  //quando app carregar, preparar e carregar todos os contatos ja salvos
  @override
  void initState() {
    super.initState();
    _getAllContacts();
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
      onPressed: () {
        number = contactList.length;
        print('tamanho lista init: $number');

        return _showContactPage(number: number);
      },
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
        "Minha Agenda de Clientes",
        style: TextStyle(
            color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blueAccent,
      elevation: 10.0,
      centerTitle: true,
      actions: <Widget>[
        PopupMenuButton<OrderOptions>(
          itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordernar de A-Z"),
              value: OrderOptions.order_az,
            ),
            const PopupMenuItem<OrderOptions>(
              child: Text("Ordernar de Z-A"),
              value: OrderOptions.order_za,
            ),
          ],
          onSelected: _orderList,
        ),
      ],
    );
  }

  //função de ordenacao
  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.order_az:
        contactList.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.order_za:
        contactList.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  //contact card
  Widget _contactCard(BuildContext context, int index) {
    String _formatDate = formatDate(dateTime, [dd, '/', mm, '/', yyyy]);
    return GestureDetector(
      child: Card(
        color: Colors.white,
        elevation: 2,
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
                padding: EdgeInsets.only(left: 7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _textoNome(index),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                    ),
                    _textoCpf(index),
                    Padding(
                      padding: EdgeInsets.only(top: 4.0),
                    ),
                    _textoPhone(index),
                    _textoDateBorn(index),
                    _textoUf(index),
                    Text(_formatDate),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  //show options
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: () {
                          launch("tel:${contactList[index].phone}");
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Ligar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: () {
                          print('Number Edit Id ${contactList[index].id}');
                          Navigator.pop(context);
                          _showContactPage(
                              contact: contactList[index],
                              number: contactList[index].id);
                        },
                        child: Text(
                          "Editar",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: () {
                          helper.deleteContact(contactList[index].id);
                          setState(() {
                            contactList.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                        child: Text(
                          "Excluir",
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            onClosing: () {},
          );
        });
  }

  //texto nome
  Widget _textoNome(int index) {
    return Text(
      //caso nome seja vazio,
      contactList[index].name ?? "",
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.fade,
      softWrap: false,
    );
  }

  //texto cpf
  Widget _textoCpf(int index) {
    return Text(
      //caso nome seja vazio demais
      contactList[index].cpf != null
          ? "CPF: ${contactList[index].cpf}"
          : "CPF não cadastrado",
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  //texto phone
  Widget _textoPhone(int index) {
    return Text(
      //caso nome seja vazio
      contactList[index].phone != null
          ? "Contato Principal: ${contactList[index].phone}"
          : "Telefone não cadastrado",
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  //texto uf
  Widget _textoUf(int index) {
    return Text(
      //caso fone seja vazio
      contactList[index].uf != null
          ? "UF: ${contactList[index].uf}".toUpperCase()
          : "UF não cadastrado",
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  //texto date
  Widget _textoDateBorn(int index) {
    return Text(
      //caso nome seja vazio
      contactList[index].dateBorn != null
          ? "Data Nascimento: ${contactList[index].dateBorn}"
          : "Data Nascimento não cadastrada",
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  //texto datereg
  Widget _textoDateRegister(int index) {
    return Text(
      //caso nome seja vazio
      contactList[index].dateRegister != null
          ? "Ativo desde: ${contactList[index].dateRegister}"
          : "Não cadastrado",
      style: TextStyle(
        color: Colors.grey[700],
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  //exibir tela de contatos
  void _showContactPage({Contact contact, int number}) async {
    number = contactList.length;
    if (number == 0) number = 1;
    print('List Size $number');
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact, numberList: number),
      ),
    );
//caso ele receba um novo contato
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
        _getAllContacts();
      } else {
        //caso ele receba um contato porem nós não enviemos nenhum contato
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then(
          (list) => //para atualizar a lista, setar um setState
              setState(() {
            contactList = list;
          }),
        );
  }
}

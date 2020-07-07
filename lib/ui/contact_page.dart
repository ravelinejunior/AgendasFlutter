import 'package:agenda_app/helper/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact});
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: actionBar(),
      floatingActionButton: fab(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(),
      ),
    );
  }

  //fab
  Widget fab() {
    return FloatingActionButton(
      onPressed: () {},
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
}

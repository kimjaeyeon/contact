import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';

//실제 앱이 동작하는 부분
void main() {
  runApp(
      MaterialApp(
          home : MyApp()
      )
  ); //앱 시작해 주세요
}

class MyApp extends StatefulWidget {
   MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  getPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      print('허락됨');
      var contacts = await ContactsService.getContacts(); //업데이트 개념
      var length_Contact = contacts.length;
      print('${length_Contact} 이다.');

      setState(() {
        name_p = contacts;
      });

    } else if (status.isDenied) {
      print('거절됨');
      Permission.contacts.request();
      openAppSettings();
    }
  }

  @override
  void initState() // 처음 클래스가 켜질때
  {
    super.initState();
    getPermission();
  }

  var total = 1;
  var state_count = 3;
  var name = '연락처 앱';
  List<Contact> name_p = [];

  addOne(Contact newName)
  {
    setState(() { // state update and make new widget
      name_p.add(newName);
      ContactsService.addContact(newName);
    });
  }

  delete(Contact deleteName,i)
  {
    setState(() {
      name_p.removeAt(i);
      ContactsService.deleteContact(deleteName);
    });
  }


 // 재렌더링을 해주어야 한다.
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Text(total.toString()),
          onPressed: (){
                showDialog(context: context, builder : (context) {
                return DialogUI(addOne : addOne);
              });
            },
        ),

        appBar: AppBar(title:Text(name), actions: [IconButton(onPressed: (){getPermission();}, icon: Icon(Icons.contacts))]),

        body: ListView.builder(
            itemCount: name_p.length,
            itemBuilder: (c,i){
              return ListTile(
                leading: Icon(Icons.people),
                title: Text(name_p[i].displayName ?? ""),
                trailing: IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (context) {
                      return DialogUI2(delete : delete, name_p : name_p, i : i);
                    });
                  },
                    //delete(name_p[i],i);

                  icon: Icon(Icons.delete),
                )

              );
            },
        ),


        bottomNavigationBar: Row(
          mainAxisAlignment : MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children : const [
            Icon(Icons.phone),
            Icon(Icons.message),
            Icon(Icons.contact_page),
          ],
        ),

      );
   }
}

class DialogUI extends StatelessWidget {
  
  DialogUI({super.key, this.addOne});
  var addOne;
  var inputData = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child : SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              TextField( controller : inputData,),
              TextButton(onPressed: (){
                if(inputData.text != "")
                  {
                    Contact newContact = Contact();
                    newContact.displayName = inputData.text;
                    addOne(newContact);
                  }
                },
                  child: Text('완료')),
              TextButton(onPressed: (){ Navigator.pop(context); }, child: Text('취소'))
            ],
          )
      ),
    );
  }
}

class DialogUI2 extends StatelessWidget {

  var delete;
  List<Contact> name_p;
  var i;

  DialogUI2({super.key, this.delete, required this.name_p, this.i});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child : SizedBox(
        width: 300,
        height: 300,
          child: Column(
            children: [
              Text('정말 삭제하시겠습니까?'),
              TextButton(onPressed: (){
                  delete(name_p[i],i);
              },
                  child: Text('네')),
              TextButton(onPressed: (){ Navigator.pop(context); }, child: Text('아니오'))
            ],
          )
      )

    );
  }
}


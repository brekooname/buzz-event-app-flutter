import 'dart:math';
import 'package:assessment_task/submitcode_screen.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Widget/customClipper.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:mailer/mailer.dart';

class ForgotPassEmail extends StatefulWidget {
  const ForgotPassEmail({Key? key}) : super(key: key);

  @override
  _ForgotPassEmailState createState() => _ForgotPassEmailState();
}

class _ForgotPassEmailState extends State<ForgotPassEmail> {
  TextEditingController emailctrl = TextEditingController();
  var codeRandom = Random();
  bool processing = false;
  GlobalKey<FormState> _keyforg = new GlobalKey<FormState>();
  //bool verifyButton = false;
  //late String verifyLnk;
  int codeReset=0;
  int min=100000,max=999999;
  saveInfo(int id_buzz,String email) async {
    SharedPreferences sessionLogin = await SharedPreferences.getInstance();
    sessionLogin.setInt("id_buzz", id_buzz);
    sessionLogin.setString("email",email);
    sessionLogin.setString("phone","");
  }
  //form != null && !form.validate()
  forgetPassValid(){
    var formdata = _keyforg.currentState;
    if(formdata != null && !formdata.validate()){
      return "make sure all the fields are valide";
    }else if(formdata != null && formdata.validate()){
      checkUser();
    }
  }
  Future checkUser()async{
    setState(() {
      processing = true;
    });
    codeReset= min+codeRandom.nextInt(max - min);
    var response = await http.post(Uri.parse('https://okydigital.com/buzz_login/check.php'),body:{
      'email':emailctrl.text.trim(),
      'codeReset':codeReset.toString()
    });
    var res = jsonDecode(response.body);
    if(res=="Invalidemail"){
      Fluttertoast.showToast(msg: "Cet e-mail est incorrect",toastLength: Toast.LENGTH_SHORT, fontSize: 12, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.deepPurple, textColor: Colors.white);
    }else{
      //generate code :
      print(codeReset);
      print(int.parse(res['id']));
      //save code to shared preference
      saveInfo(int.parse(res['id']),res['email']);
      Fluttertoast.showToast(msg: "Vérifiez votre boîte de réception",toastLength: Toast.LENGTH_SHORT, fontSize: 12, gravity: ToastGravity.BOTTOM, backgroundColor: Colors.deepPurple, textColor: Colors.white);
      Navigator.push(context, MaterialPageRoute(builder: (context) => Verificatoin()));
      // send code to box mail
      sendMail(codeReset);
    }
    setState(() {
      processing = false;
    });
    }
  sendMail(int ccReset) async {
    String username = 'yassinedoumil96@gmail.com';
    String password = 'jysjamalyassine9669.com';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'team buzzevvent')
      ..recipients.add(emailctrl.text.toString())
      ..subject = 'Reset Password verification : ${DateTime.now().hour}:${DateTime.now().minute}'
      ..html = "<h1>Votre ocde est :</h1>\n<p>${ccReset}</p>";
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    var connection = PersistentConnection(smtpServer);
    // send the equivalent message
    await connection.send(message);
    // close the connection
    await connection.close();
  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          height: height,
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                height:200,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(image:
                    AssetImage("assets/background-buz2.png"),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  child:  Center(
                    child: Container(
                      child: const Center(child: Image(image: AssetImage("assets/logobuzzeventsf.png"),width: 230, alignment: Alignment.center,)),
                    ),
                  ) ,
                ),
              ),
              Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .4,
                child: Container(
                    child: Transform.rotate(
                      angle: -pi / 3.5,
                      child: ClipPath(
                        clipper: ClipPainter(),
                        child: Container(
                          height: MediaQuery.of(context).size.height * .5,
                          width: MediaQuery.of(context).size.width,

                        ),
                      ),
                    )),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 300,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Text('Réinitialisez le mot de passe',
                          style: TextStyle(fontSize: 20,color: Color(0xff692062),fontWeight: FontWeight.bold),
                        ),
                      ),

                      Form(
                        key: _keyforg,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                      controller: emailctrl,
                                      validator: (value) {
                                        Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

                                        if (value == null || value.trim().isEmpty) {
                                          return 'Champ obligatoire';
                                        }
                                        else{
                                          RegExp regex =  RegExp(pattern.toString());
                                          if(!regex.hasMatch(value)){
                                            return 'Entrer une Adresse Email valide';
                                          }
                                        }
                                        return null;
                                      },
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        hintText: 'Email',
                                        fillColor: Color(0xfff3f3f4),
                                        filled: true,
                                      )
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      MaterialButton(
                        onPressed:(){
                          //Navigator.push(
                            //  context, MaterialPageRoute(builder: (context) => Verificatoin()));
                            forgetPassValid();
                            //print(codeReset.nextInt(999999));
                        },
                        child: processing == false
                            ?Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey.shade200,
                                  offset: Offset(2, 4),
                                  blurRadius: 5,
                                  spreadRadius: 2)
                            ],
                            color: Color(0xff692062),
                          ),
                          child: Text('Envoyez', style: TextStyle(fontSize: 20, color: Colors.white),),
                        )
                            : CircularProgressIndicator(
                          color: Colors.white,
                          backgroundColor: Color(0xff692062),
                        )
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                          child:
                          Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Text('',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    ));
  }
  showToast(String msg, {required int duration, required int gravity}){

    showToast(msg, duration: duration, gravity: gravity);

  }
}

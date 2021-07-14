import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Generated in previous step 
import 'amplifyconfiguration.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: MyHomePage(title: 'Somdaka Messenger'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  initState() {
    super.initState(); 
    _configureAmplify(); 
  }

  void _configureAmplify() async {

    // Add Pinpoint and Cognito Plugins, or any other plugins you want to use
    AmplifyAPI apiPlugin = AmplifyAPI();
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugins([authPlugin, apiPlugin]);

    // Once Plugins are added, configure Amplify
    // Note: Amplify can only be configured once.
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print("Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
    }
  }

  final Telephony telephony = Telephony.instance;

  late GraphQLSubscriptionOperation<String> operation;
  bool isListening = false;

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s) != null;
  }

  void _fetchMessageData(BuildContext context) {
    String message = "Hi Valued Client\n\nWe are testing a new sms solution built for you.\n\nPlease ignore this message.\n\nSomdaka Funerals";

    var memberRecords = [
      {
        "policy_number": "TMB1001",
        "main_member": "Buhle Sibiya",
        "cell_number": "0785928904"
      },
      {
        "policy_number": "TMB1002",
        "main_member": "Wendy Somdaka",
        "cell_number": "0609724788"
      },
      {
        "policy_number": "TMB1003",
        "main_member": "Simone Granger",
        "cell_number": "0624130430"
      },
      {
        "policy_number": "TMB1004",
        "main_member": "Given Somdaka",
        "cell_number": "0846853064"
      },
    ];

    for (var i = 0; i < memberRecords.length; i++) {
      var number =
          memberRecords[i]['cell_number'].toString().replaceAll(' ', '').trim();

      if (number != '' && number.length == 10 && isNumeric(number)) {
        _sendMessage(context, message, number);
      }
    }
  }

  void _sendMessage (BuildContext context, String messageBody, String phoneNumber) async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    final SmsSendStatusListener listener = (SendStatus status) {
      String notification = 'Failed to send message to ' + phoneNumber;

      SnackBar snackBar = SnackBar(content: Text(notification), backgroundColor: Colors.red);

      SnackBar sentSnack = SnackBar(content: Text(notification), backgroundColor: Colors.green);

      if(status == SendStatus.SENT) {
        notification = 'Message sent to ' + phoneNumber;
        snackBar = sentSnack;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      if(status == SendStatus.DELIVERED) {
        notification = 'Message delivered to ' + phoneNumber;
        snackBar = sentSnack;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

    };

    if(permissionsGranted != null && permissionsGranted) {
      telephony.sendSms(to: phoneNumber, message: messageBody, statusListener: listener);
    }
  }

  void _listenForMessages () {
    try {
      String graphQLDocument = '''subscription OnCreateMessage {
          OnCreateMessage {
            id
            messageBody
            recipients
          }
        }''';

      operation = Amplify.API.subscribe(
          request: GraphQLRequest<String>(document: graphQLDocument),
          onData: (event) {
            print('Subscription event data received: ${event.data}');
          },
          onEstablished: () {
            print('Subscription established');
          },
          onError: (e) {
            print('Subscription failed with error: $e');
          },
          onDone: () {
            print('Subscription has been closed successfully');
          });

      setState(() {
        isListening = true;
      });
    } on ApiException catch (e) {
        print('Failed to establish subscription: $e');
    }
  }

  void _stopMessageListener () {
    operation.cancel();

    setState(() {
      isListening = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listenForMessages,
        tooltip: 'Increment',
        child: Icon(Icons.message_outlined),
      ),
    );
  }
}

class SimpleButton extends StatelessWidget {
  final String displayText; 
  final void Function() handleTap;
  final Color buttonColor;
  final Color buttonTextColor;

  SimpleButton({ required this.displayText, required this.handleTap, this.buttonColor: Colors.blueGrey, this.buttonTextColor: Colors.white });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(displayText,
            style: TextStyle(
              color: Colors.white
            ),
          ),
        ),
      ),
    );
  }
}
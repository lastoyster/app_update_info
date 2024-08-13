import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showData();
  }
  void showData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var collection = FirebaseFirestore.instance.collection('User');
    print(packageInfo.appName);
    print(packageInfo.buildNumber);
    print(packageInfo.packageName);
    print(packageInfo.version);
    print(packageInfo.data);
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = queryDocumentSnapshot.data();
     if(data['version'] != packageInfo.version) {
       _showAlert();
     }
    }
  }
    void _showAlert() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          scrollable: false,
          content: Container(
            height: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'UPDATE_VERSION_TITLE',
                ),
                const SizedBox(height: 32),
                const Text(
                  'UPDATE_VERSION_CONTENT',
                ),
                const Spacer(),
                Container(
                  width: double.maxFinite,
                  child: Row(
                    children: [
                        Expanded(
                          child: GestureDetector(
                          child: const Text("Cancel"),
                          onTap: () {
                              
                            },
                          )
                        ),
                      Expanded(
                        child: GestureDetector(
                             child: const Text("Update"),
                             onTap: () {
                                 LaunchReview.launch(
                                   androidAppId: '',
                                   iOSAppId: '',
                                   writeReview: false,
                                 );
                               },
                             )
                    
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("User").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(documents[index]['version']),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            )
    );
  }
}

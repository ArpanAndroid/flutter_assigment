import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import'package:http/http.dart' as http;

void main() {
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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<dynamic>repositories=[];
  Map<String,dynamic>lastCommits={};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRepository();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text("Assignment"),
      ),
      body: repositories.isEmpty?Center(
        child: CircularProgressIndicator(),
      ):ListView.builder(
          itemCount: repositories.length??0,
          itemBuilder: (context,index){
            final repo=repositories[index];
            final lastCommit=lastCommits[repo['name']];
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration:BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.0)
                ) ,
                child:ListTile(
                  title: Text('${repo['name']}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold
                  ),),
                  subtitle: lastCommit!=null
                      ?Text("${lastCommit['commit']['message']}",
                      style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400
                      )):
                      Text("No commits")
                ) ,

              ),
            );

          }
      )

    );
  }
  Future<void>fetchRepository()async{
    final response=await http.get(Uri.parse("https://api.github.com/users/freeCodeCamp/repos"));
    if(response.statusCode==200){
      final List<dynamic>repos=jsonDecode(response.body);
      setState(() {
        repositories=repos;
      });
      fetchLastCommits(repos);
    }else{
      throw Exception("Faild load");
    }
  }
  Future<void>fetchLastCommits(List<dynamic>repos)async{
    for(var repo in repos){
      final response=await http.get(Uri.parse("https://api.github.com/repos/freeCodeCamp/${repo['name']}/commits"));
      if(response.statusCode==200){
        final List<dynamic>commit=jsonDecode(response.body);
        setState(() {
          lastCommits[repo['name']]=commit[0];
        });
      }else{
        throw Exception("Faild load last commit");
      }
    }
 
  }


}

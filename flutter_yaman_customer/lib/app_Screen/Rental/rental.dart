import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yaman_driver/app_Screen/Rental/addRentalPost.dart';
import 'package:flutter_yaman_driver/model/posts.dart';


class Rental extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RentalState();
  }
}

class RentalState extends State<Rental> {
  List<Posts> postList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DatabaseReference database = FirebaseDatabase.instance.reference().child("Rental_post");

    database.once().then((DataSnapshot data){
      var keys = data.value.keys;
      var Data1 = data.value;

      postList.clear();

      for(var individualKey in keys){
        Posts posts = new Posts(Data1[individualKey]['title'], Data1[individualKey]['description'], Data1[individualKey]['date']);

        postList.add(posts);
      }

      setState(() {
        print(postList.length);
      });

    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Rental'),
      ),
      body: Container(
          child: Center(
            child: postList.length == 0? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                new Text("No rental Post avilable")
              ],
            ): new ListView.builder(
              itemCount: postList.length,
              itemBuilder: (_,index){
                return postsUI(postList[index].title, postList[index].decription, postList[index].date);
              },
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddRental()));
        },
      ),
    );
  }

  Widget postsUI(String title,String description,String date){
    return new Card(
      elevation: 10.0,
      margin: EdgeInsets.all(10.0),
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(title,style: Theme.of(context).textTheme.title,textAlign: TextAlign.center,),
             new Text(date,style: Theme.of(context).textTheme.subtitle),
              new Text(description,style: Theme.of(context).textTheme.subtitle)
          ],
        ),
      ),
    );

  }
}

//declare packages
import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_mysql_crud/pageAdmin/Mamager_User/editdata.dart';

class Search_restaurant extends StatefulWidget {
  Search_restaurant() : super();

  @override
  Search_State createState() => Search_State();
}

class Debouncer {
  late int milliseconds;
  late VoidCallback action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer;
    }
    timer = Timer(
      Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class Search_State extends State<Search_restaurant> {
  final _debouncer = Debouncer();

  List<Subject> ulist = [];
  List<Subject> restaurant_Lists = [];
  //API call for All Subject List

  Future<List<Subject>> getAllulistList() async {
    try {
      final responce = await rootBundle.loadString('assets/example_data.json');

      if (responce != 0) {
        print(responce);
        List<Subject> list = parseAgents(responce);
        return list;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Subject> parseAgents(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Subject>((json) => Subject.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    getAllulistList().then((subjectFromServer) {
      setState(() {
        ulist = subjectFromServer;
        restaurant_Lists = ulist;
      });
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/ICS.PNG'),
          height: 30,
        ),
        backgroundColor: Colors.blue[900],
        actions: <Widget>[
          Image(
            image: AssetImage('assets/ICS2.PNG'),
            height: 30,
            width: 50,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          //Search Bar to List of typed Subject

          Container(
            height: 50,
            padding: EdgeInsets.all(5),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                  ),
                ),
                suffixIcon: InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: EdgeInsets.all(15.0),
                hintText: 'Search Restaurant',
              ),
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    restaurant_Lists = ulist
                        .where(
                          (u) => (u.name!.toLowerCase().contains(
                                string.toLowerCase(),
                              )),
                        )
                        // .where(
                        //   (u) => (u.firstName.toLowerCase().contains(
                        //         string.toLowerCase(),
                        //       )),
                        // )
                        .toList();
                  });
                });
              },
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Text(
                "Place  List",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),

          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.all(5),
              // itemCount: userLists == null ? 0 : userLists.length,
              itemCount: restaurant_Lists == null ? 0 : restaurant_Lists.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                          ),
                          Column(
                            children: [
                              Image.network(
                                  restaurant_Lists[index].profileImageUrl,
                                  width: 300,
                                  height: 100,
                                  fit: BoxFit.fill),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text(
                                    restaurant_Lists[index].name,
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 120,
                                  ),
                                  Container(
                                    width: 50,
                                    height: 40,
                                    color: Colors.blue[900],
                                    child: Text(
                                      restaurant_Lists[index].rating.toString(),
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Image.network(
                                  restaurant_Lists[index].images[0].toString(),
                                  width: 300,
                                  height: 150,
                                  fit: BoxFit.fill)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//Declare Subject class for json data or parameters of json string/data
//Class For Subject
class Subject {
  late int id;
  late String name;
  late List<String>? categories;
  late String profileImageUrl;
  late List<String> images;
  late List<OperationTime> operationTime;
  late String address;
  double? rating;

  Subject(
      {required this.id,
      required this.name,
      this.categories,
      required this.profileImageUrl,
      required this.images,
      required this.operationTime,
      required this.address,
      this.rating});

  Subject.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    categories = json['categories'].cast<String>();
    profileImageUrl = json['profile_image_url'];
    images = json['images'].cast<String>();
    if (json['operation_time'] != null) {
      operationTime = <OperationTime>[];
      json['operation_time'].forEach((v) {
        operationTime!.add(new OperationTime.fromJson(v));
      });
    }
    address = json['address'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['categories'] = this.categories;
    data['profile_image_url'] = this.profileImageUrl;
    data['images'] = this.images;
    if (this.operationTime != null) {
      data['operation_time'] =
          this.operationTime!.map((v) => v.toJson()).toList();
    }
    data['address'] = this.address;
    data['rating'] = this.rating;
    return data;
  }
}

class OperationTime {
  String? day;
  String? timeOpen;
  String? timeClose;

  OperationTime({this.day, this.timeOpen, this.timeClose});

  OperationTime.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    timeOpen = json['time_open'];
    timeClose = json['time_close'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['day'] = this.day;
    data['time_open'] = this.timeOpen;
    data['time_close'] = this.timeClose;
    return data;
  }
}

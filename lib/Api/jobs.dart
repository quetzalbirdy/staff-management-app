import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:wolf_jobs/model/JobListHolder.dart';
import 'package:wolf_jobs/model/jobList.dart';

class HttpService {


  final String postsURL = "#/api/v1/shifts/view_all_jobs/?tenant=vetsny_db";
  List <JobListHolder> response = [];
  getPosts() async {
    Response res = await get(postsURL, headers: {'AUTHORIZATION':'#', 'Content-Type':'application/json'});
    if (res.statusCode == 200) {
      var responseJson = jsonDecode(res.body);
     Map <String, dynamic> dataHolder = responseJson['data']['campaigns'];
      print(dataHolder.length);
      for(var i in dataHolder.values){
        JobListHolder models = JobListHolder.fromJson(i);
//        print(models.title);
          response.add(models);
//        print(response);
//        return response;
      }
    }
  }
}
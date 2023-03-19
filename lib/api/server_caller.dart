import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import 'models/project.dart';

class ServerCaller {
  static const String _serverUrl = "http://127.0.0.1:8000";
  
  static Future<List<ProjectModel>> getProjects(String username) async {
    final response = await http.get(
        Uri.parse("$_serverUrl/project/user/$username"),
    );
    if (response.statusCode == 200) {
      var projects = jsonDecode(response.body);
      return [
        for (var project in projects)
          ProjectModel.fromJson(project)
      ];
    }
    
    throw Exception("Failed to get projects from user $username");
  }

  static Future<ProjectModel> getProject(String projectId) async {
    final response = await http.get(
      Uri.parse("$_serverUrl/project/$projectId"),
    );
    if (response.statusCode == 200) {
      return ProjectModel.fromJson(jsonDecode(response.body));
    }

    throw Exception("Failed to get project $projectId");
  }
  
  static Future<ProjectModel> createProject(String username, String title, String description) async {
    final response = await http.post(
      Uri.parse("$_serverUrl/project/create_project"),
      body: jsonEncode({
        "username": username,
        "title": title,
        "description": description,
      }),
    );
    
    if (response.statusCode == 200) {
      return ProjectModel.fromJson(jsonDecode(response.body));  
    }

    throw Exception("Failed to create projects for user $username");
  } 
  
  static Future deleteProject(String projectId) async {
    final response = await http.get(
      Uri.parse("$_serverUrl/project/delete/$projectId"),
    );
    
    if (response.statusCode == 200) {
      return;
    }

    throw Exception("Failed to delete project $projectId");
  }
  
  static Future saveProject(ProjectModel projectModel) async {
    final response = await http.post(
      Uri.parse("$_serverUrl/project/save_project"),
      body: jsonEncode(projectModel.toJson()),
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception("Failed to save project ${projectModel.projectId}");
  }
  
  static Future uploadAudio(String projectId, String filename, Uint8List bytes) async {
    final response = await http.post(
      Uri.parse("$_serverUrl/audio/upload/$projectId/$filename"),
      body: bytes,
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception("Failed to upload audio with name $filename");
  }
  
  static Source audioSource(String projectId, String filename) {
    return UrlSource(audioSourceUrl(projectId, filename));
  }

  static String audioSourceUrl(String projectId, String filename) {
    return "$_serverUrl/audio/$projectId/$filename";
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:ai_mock_interview/core/network/backend_configuration.dart';
import 'package:ai_mock_interview/models/interview_configuration.dart';
import 'package:ai_mock_interview/models/interview_session.dart';
import 'package:ai_mock_interview/repositories/interview_repository.dart';

class InterviewApiException implements Exception {
  const InterviewApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiInterviewRepository implements InterviewRepository {
  ApiInterviewRepository({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  @override
  Future<InterviewSession> createSession(InterviewConfiguration configuration) async {
    final Map<String, dynamic> response = await _send(
      method: 'POST',
      path: '/api/v1/interviews',
      body: <String, dynamic>{
        'interview_type': configuration.type.name,
        'difficulty': configuration.difficulty.name,
        'question_count': configuration.questionCount,
        'job_role': configuration.jobRole,
        'programming_language': configuration.type == InterviewType.technical ? configuration.programmingLanguage : null,
        'topics': configuration.topics.toList(),
      },
    );
    final Map<String, dynamic>? currentQuestion = response['current_question'] as Map<String, dynamic>?;
    if (currentQuestion == null) {
      throw const InterviewApiException('The backend did not return an opening question.');
    }
    return InterviewSession(
      id: response['id'] as String,
      configuration: configuration,
      questions: <InterviewQuestion>[_questionFromJson(currentQuestion)],
    );
  }

  @override
  Future<InterviewSession> submitAnswer({required InterviewSession session, required String answer}) async {
    final Map<String, dynamic> response = await _send(
      method: 'POST',
      path: '/api/v1/interviews/${session.id}/answer',
      body: <String, dynamic>{'answer': answer.trim()},
    );
    final List<InterviewAnswer> answers = <InterviewAnswer>[
      ...session.answers,
      InterviewAnswer(questionId: session.currentQuestion.id, text: answer.trim()),
    ];
    final Map<String, dynamic>? nextQuestion = response['current_question'] as Map<String, dynamic>?;
    return session.copyWith(
      answers: answers,
      questions: nextQuestion == null ? session.questions : <InterviewQuestion>[...session.questions, _questionFromJson(nextQuestion)],
    );
  }

  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
  }) async {
    if (!BackendConfiguration.isConfigured) {
      throw const InterviewApiException('Backend configuration is missing. Start Flutter with BACKEND_BASE_URL and DEV_AUTH_TOKEN.');
    }
    final Uri uri = Uri.parse('${BackendConfiguration.baseUrl.replaceFirst(RegExp(r'/$'), '')}$path');
    try {
      final HttpClientRequest request = await _httpClient.openUrl(method, uri).timeout(const Duration(seconds: 15));
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer ${BackendConfiguration.developmentToken}');
      if (body != null) request.write(jsonEncode(body));
      final HttpClientResponse response = await request.close().timeout(const Duration(seconds: 30));
      final String content = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> payload = content.isEmpty ? <String, dynamic>{} : jsonDecode(content) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw InterviewApiException(payload['detail'] as String? ?? 'The backend rejected the interview request.');
      }
      return payload;
    } on SocketException {
      throw const InterviewApiException('Unable to reach the backend. Check your network and server address.');
    } on HttpException {
      throw const InterviewApiException('The backend response was invalid. Please try again.');
    } on FormatException {
      throw const InterviewApiException('The backend returned an unreadable response.');
    }
  }
}

InterviewQuestion _questionFromJson(Map<String, dynamic> json) => InterviewQuestion(
      id: json['id'] as String,
      text: json['question'] as String,
      expectedTopics: List<String>.from(json['expected_topics'] as List<dynamic>),
      isFollowUp: json['follow_up'] as bool,
    );

import 'package:flutter/foundation.dart';

class ApiConstants {
  static const baseUrl = kIsWeb ? 'http://localhost:8000/api/v1' : 'http://192.168.31.53:8000/api/v1';
  static const authRegister = '/auth/register';
  static const authLogin = '/auth/login';
  static const authMe = '/auth/me';
  static const authOtpSend = '/auth/otp/send';
  static const authOtpVerify = '/auth/otp/verify';
  static const sosTrigger = '/sos/trigger';
  static const sosCancel = '/sos/cancel';
  static String sosResolve(String id) => '/sos/resolve/$id';
  static const sosActive = '/sos/active';
  static const evidenceUpload = '/evidence/upload';
  static const evidenceList = '/evidence/list';
  static const reports = '/reports/';
  static const aiPhishing = '/ai/phishing';
  static const aiDeepfake = '/ai/deepfake';
  static const aiFakeProfile = '/ai/fake-profile';
  static const aiUnsafeZone = '/ai/unsafe-zone';
  static const guardians = '/guardians/';
  static const awarenessArticles = '/awareness/articles';
  static const evidenceVerify = '/evidence/verify';
}

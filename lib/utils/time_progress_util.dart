import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TimeProgressUtil {
  /// 현재 시간 기준으로 진행률을 계산합니다 (0.0 ~ 1.0)
  static double calculateProgress(Todo todo) {
    if (todo.startTime == null ||
        todo.endTime == null ||
        !todo.useTimeProgress) {
      return 0.0;
    }

    final now = DateTime.now();

    // 이미 종료 시간이 지났으면 100% 반환
    if (now.isAfter(todo.endTime!)) {
      return 1.0;
    }

    // 아직 시작 시간이 되지 않았으면 0% 반환
    if (now.isBefore(todo.startTime!)) {
      return 0.0;
    }

    // 시작 시간과 종료 시간 사이의 총 시간(밀리초)
    final totalDuration = todo.endTime!
        .difference(todo.startTime!)
        .inMilliseconds;

    // 시작 시간부터 현재까지의 경과 시간(밀리초)
    final elapsedDuration = now.difference(todo.startTime!).inMilliseconds;

    // 진행률 계산 (0.0 ~ 1.0 사이의 값)
    return elapsedDuration / totalDuration;
  }

  /// 진행률에 따른 색상을 반환합니다
  static Color getProgressColor(double progress) {
    if (progress >= 0.8) {
      // 80% 이상 진행: 빨간색 계열
      return Colors.red;
    } else if (progress >= 0.5) {
      // 50% 이상 진행: 주황색 계열
      return Colors.orange;
    } else {
      // 50% 미만 진행: 초록색 계열
      return Colors.green;
    }
  }

  /// 남은 시간을 문자열로 반환합니다
  static String getRemainingTimeText(Todo todo) {
    if (todo.endTime == null || !todo.useTimeProgress) {
      return '';
    }

    final now = DateTime.now();

    if (now.isAfter(todo.endTime!)) {
      return '기한 초과';
    }

    final remaining = todo.endTime!.difference(now);

    if (remaining.inDays > 0) {
      return '${remaining.inDays}일 남음';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}시간 남음';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}분 남음';
    } else {
      return '${remaining.inSeconds}초 남음';
    }
  }
}

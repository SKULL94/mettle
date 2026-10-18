enum InterviewTopic {
  stateManagement('state-management'),
  widgetLifecycle('widget-lifecycle'),
  keys('keys'),
  asyncIsolates('async-isolates'),
  performance('performance'),
  navigation('navigation'),
  testing('testing');

  const InterviewTopic(this.id);

  final String id;

  static InterviewTopic fromId(String id) {
    return InterviewTopic.values.firstWhere(
      (topic) => topic.id == id,
      orElse: () => InterviewTopic.stateManagement,
    );
  }
}

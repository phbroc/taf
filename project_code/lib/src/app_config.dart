class AppConfig {
  String apiEndpoint;
  String title;
  String user;
}

AppConfig appConfigFactory() => AppConfig()
  ..apiEndpoint = ''
  ..title = 'Trucs à faire'
  ..user = 'PBD';
class AppConfig {
  String apiEndpoint;
  String title;
  String user;
}

AppConfig tafConfigFactory() => new AppConfig()
  ..apiEndpoint = 'some url .fr'
  ..title = 'Trucs à faire'
  ..user = 'PBD';
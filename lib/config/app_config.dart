enum Environment { dev, prod }

class AppConfig {
  static late Environment _env;
  
  static void setEnvironment(Environment env) {
    _env = env;
  }
  
  static Environment get environment => _env;
  
  static bool get isDev => _env == Environment.dev;
  static bool get isProd => _env == Environment.prod;
  
  static String get environmentName {
    switch (_env) {
      case Environment.dev:
        return 'Development';
      case Environment.prod:
        return 'Production';
    }
  }
}
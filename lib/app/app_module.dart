import 'package:flutter_modular/flutter_modular.dart';
import 'package:portfolio_01/app/pages/home/home_controller.dart';
import 'package:portfolio_01/app/pages/home/home_module.dart';

class AppModule extends Module{
  @override
  List<Bind> get binds => [
      Bind((i) => HomeController()),
  ];

  // Provide all the routes for your module
  @override
  final List<ModularRoute> routes = [
    //ChildRoute('/', child: (_, args) => HomePage()),
    ModuleRoute("/", module: HomeModule()),
  ];
}
import 'package:go_router/go_router.dart';
import '../views/project/project_list_view.dart';
import '../views/project/project_add_view.dart';
import '../views/project/project_detail_view.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProjectListView(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const ProjectAddView(),
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) => ProjectDetailView(
        projectId: state.pathParameters['id']!,
      ),
    ),
  ],
);

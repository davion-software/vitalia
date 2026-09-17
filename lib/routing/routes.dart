abstract final class Routes {
  static const today = '/today';
  static const medications = '/medications';
  static const history = '/history';
  static const settings = '/settings';
  static const newMedication = '/medications/new';

  static String editMedication(String id) => '/medications/$id/edit';
}

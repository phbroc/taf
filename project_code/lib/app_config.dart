class AppConfig {
  // String apiUrl = 'http://localhost/api'; /* en DEV */
  String apiUrl = 'api'; /* en PROD */
  String userUrl = 'user.php';
  String toknowUrl = 'toknow.php';
  String authAltHeader = 'X-Authorization';
  String authAltProcess = 'Bearer ';
  String localStName = 'myToknows';
  List<String> appTitle = ['Trucs à savoir','Things to know'];
  List<String> tagListTitle = ['Tout ce qui concerne','All about'];
  List<String> weekListTitleThis = ['Cette semaine','This week'];
  List<String> weekListTitleNext = ['La semaine prochaine','The next week'];
  List<String> weekListTitleLast = ['La semaine dernière','The last week'];
  List<String> weekListNext = ['semaine suivante','next week'];
  List<String> weekListPrevious = ['semaine précédente','previous week'];
  List<String> nothing = ['Rien', 'Nothing'];
  List<String> delete = ['Supprimer','Delete'];
  List<String> edit = ['Éditer','Edit'];
  List<String> add = ['Ajouter','Add'];
  List<String> newToknow = ['Nouveau', 'New'];
  List<String> title = ['Titre', 'Title'];
  List<String> description = ['Description', 'Description'];
  List<String> tag = ['Tag', 'Tag'];
  List<String> tags = ['Tags', 'Tags'];
  List<String> crypto = ['Crypto', 'Crypto'];
  List<String> quick = ['Rapide', 'Quick'];
  List<String> done = ['Fait !', 'Done!'];
  List<String> end = ['Échéance', 'Ending'];
  List<String> save = ['Enregistrer', 'Save'];
  List<String> back = ['Retour', 'Back'];
  List<String> close = ['Fermer', 'Close'];
  List<String> date = ['Date', 'Date'];
  List<String> loginTitle = ['Compte utilisateur', 'User account'];
  List<String> identification = ['Identification', 'Identification'];
  List<String> personalPass = ['Mot de passe', 'Password'];
  List<String> newPersonalPass = ['Nouveau mot de passe', 'New password'];
  List<String> newPassRepeat = ['Répéter le nouveau mot de passe', 'Repeat the new password'];
  List<String> repeatError = ['Les deux mots ne sont pas identiques.', 'The two words are not the same.'];
  List<String> passChange = ['Changement de mot de passe', 'Password change'];
  List<String> cryptography = ['Cryptographie', 'Cryptography'];
  List<String> enabled = ['activée', 'enabled'];
  List<String> keyFormatError = ['La clé ne doit pas contenir d\'espace.',
                            'The key musn\'t contains spaces.'];
  List<String> keyLengthError = ['La clé doit avoir la longueur: ', 'The key must be long: '];
  List<String> look = ['Voir', 'Look'];
  List<String> mask = ['Masquer', 'Mask'];
  List<String> keySet = ['Activer la clé', 'Key set'];
  List<String> keyUnset = ['Désactiver la clé', 'Key unset'];
  List<String> change = ['Changer', 'Change'];
  List<String> personalKey = ['Clé personnelle', 'Personal key'];
  List<String> keyUpdate = ['Modifier la clé', 'Key update'];
  List<String> connection = ['Connexion', 'Connection'];
  List<String> disconnection = ['Déconnexion', 'Disconnection'];
  List<String> connected = ['Connecté', 'Connected'];
  List<String> disconnected = ['Déconnecté', 'Disconnected'];
  List<String> dashboardTitle = ['Tableau de bord', 'Dashboard'];
  List<String> homeLink = ['Accueil', 'Home'];
  List<String> userLink = ['Utilisateur', 'User'];
  List<String> requiredError = ['Saisie incomplète', 'Missing informations'];
  List<String> connectionError = ['Erreur de connexion', 'Connection error'];
  List<String> changedDone = ['Changement effectué', 'Change done'];
  List<String> share = ['Partager', 'Share'];
  List<String> shared = ['Partagé', 'Shared'];
  List<String> search = ['Chercher', 'Search'];
  List<String> prevPage = ['Page précédente', 'Previous page'];
  List<String> nextPage = ['Page suivante', 'Next page'];
  List<String> theForgotten = ['Les oubliés', 'The forgotten'];
  List<String> readMore = ['En savoir plus', 'Read more'];
  List<String> days = [
    'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];
  List<String> onLine = ['en ligne', 'on line'];
  List<String> offLine = ['hors ligne', 'off line'];
  List<String> user = ['Utilisateur', 'user'];
  List<String> titleRequired = ['Titre obligatoire', 'Title required'];
  List<String> synchronized = ['synchronisé le', 'synchronized on'];
  List<String> keyChange = ['Changement de clé', 'Key change'];
  String shareUser = 'SHR';

}

AppConfig tafConfigFactory() => new AppConfig();
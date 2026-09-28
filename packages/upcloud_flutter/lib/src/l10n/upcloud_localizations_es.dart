import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/utils/password_strength.dart';

/// Spanish strings.
class UpCloudLocalizationsEs extends UpCloudLocalizations {
  /// Creates the Spanish strings.
  const UpCloudLocalizationsEs();

  String _plural(int count, String one, String other) =>
      count == 1 ? one : other;

  @override
  String get decimalSeparator => ',';

  @override
  String get cancel => 'Cancelar';

  @override
  String get create => 'Crear';

  @override
  String get rename => 'Renombrar';

  @override
  String get delete => 'Eliminar';

  @override
  String get remove => 'Quitar';

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get open => 'Abrir';

  @override
  String get refresh => 'Actualizar';

  @override
  String get copy => 'Copiar';

  @override
  String get rootFolder => 'Mis archivos';

  @override
  String get goUp => 'Carpeta superior';

  @override
  String get emptyFolder => 'Esta carpeta está vacía';

  @override
  String get emptyFolderHint =>
      'Sube archivos o crea una carpeta para empezar.';

  @override
  String noSearchResults(String query) =>
      'Ningún archivo coincide con "$query"';

  @override
  String get searchHint => 'Buscar archivos';

  @override
  String get search => 'Buscar';

  @override
  String get closeSearch => 'Cerrar búsqueda';

  @override
  String get loadFolderFailed => 'No se pudo cargar esta carpeta';

  @override
  String get loadMoreFailed => 'No se pudieron cargar más elementos';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get newFolder => 'Nueva carpeta';

  @override
  String get folderName => 'Nombre de la carpeta';

  @override
  String get name => 'Nombre';

  @override
  String get nameRequired => 'Escribe un nombre';

  @override
  String deleteConfirmTitle(int count) =>
      _plural(count, '¿Eliminar elemento?', '¿Eliminar $count elementos?');

  @override
  String deleteConfirmMessage(String name) =>
      'Se eliminará "$name". Esta acción no se puede deshacer.';

  @override
  String deleteManyConfirmMessage(int count) =>
      'Se eliminarán $count elementos. Esta acción no se puede deshacer.';

  @override
  String get add => 'Nuevo';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get upload => 'Subir';

  @override
  String get uploadFiles => 'Subir archivos';

  @override
  String get uploadFromUrl => 'Subir desde URL';

  @override
  String get url => 'URL';

  @override
  String get fileNameOptional => 'Nombre del archivo (opcional)';

  @override
  String get invalidUrl => 'Escribe una URL http(s) válida';

  @override
  String get remoteUploadStarted => 'Subida remota iniciada';

  @override
  String uploadsQueued(int count) =>
      _plural(count, '1 subida en cola', '$count subidas en cola');

  @override
  String get copyLink => 'Copiar enlace';

  @override
  String get linkCopied => 'Enlace copiado';

  @override
  String get noLinks => 'No hay enlaces disponibles';

  @override
  String get move => 'Mover';

  @override
  String get moveTo => 'Mover a';

  @override
  String get moveHere => 'Mover aquí';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get clearSelection => 'Quitar selección';

  @override
  String selectedCount(int count) =>
      _plural(count, '1 seleccionado', '$count seleccionados');

  @override
  String get listView => 'Vista de lista';

  @override
  String get gridView => 'Vista de cuadrícula';

  @override
  String fileCount(int count) => _plural(count, '1 archivo', '$count archivos');

  @override
  String get noTransfers => 'No hay transferencias';

  @override
  String get transferQueued => 'En cola';

  @override
  String get transferUploading => 'Subiendo';

  @override
  String get transferCompleted => 'Completada';

  @override
  String get transferCancelled => 'Cancelada';

  @override
  String get transferFailed => 'Fallida';

  @override
  String transferProgress(String transferred, String total) =>
      '$transferred de $total';

  @override
  String get clearFinished => 'Limpiar finalizadas';

  @override
  String get cancelAll => 'Cancelar todas';

  @override
  String get errorAuthentication =>
      'El proveedor rechazó las credenciales. Revísalas e inténtalo de nuevo.';

  @override
  String get errorNotFound => 'El archivo o la carpeta ya no existe.';

  @override
  String get errorQuota =>
      'La cuenta se quedó sin espacio, ancho de banda o peticiones.';

  @override
  String errorRateLimited(Duration? retryAfter) => retryAfter == null
      ? 'Demasiadas peticiones. Inténtalo más tarde.'
      : 'Demasiadas peticiones. Inténtalo en ${retryAfter.inSeconds} s.';

  @override
  String get errorNetwork => 'Error de red. Revisa tu conexión.';

  @override
  String get errorCancelled => 'Cancelado';

  @override
  String get errorUnsupported => 'Este proveedor no admite esta acción.';

  @override
  String errorProvider(String message) => 'El proveedor respondió: $message';

  @override
  String rejectionFileTooLarge(String size, String maxSize) =>
      'El archivo es demasiado grande ($size, máx. $maxSize)';

  @override
  String rejectionExtensionNotAllowed(String extension) => extension.isEmpty
      ? 'No se permiten archivos sin extensión'
      : 'No se permiten archivos .$extension';

  @override
  String rejectionNotEnoughStorage(String size, String available) =>
      'No hay espacio suficiente (se necesitan $size, libres $available)';

  @override
  String get accounts => 'Cuentas';

  @override
  String get addAccount => 'Añadir cuenta';

  @override
  String get noAccounts => 'Todavía no hay cuentas';

  @override
  String get noAccountsHint =>
      'Añade una cuenta para empezar a gestionar tus archivos.';

  @override
  String get removeAccount => 'Quitar cuenta';

  @override
  String removeAccountMessage(String label) =>
      'Se quitará "$label" de este dispositivo y se cancelarán sus '
      'transferencias.';

  @override
  String get checkConnection => 'Comprobar conexión';

  @override
  String get accountConnected => 'Conectada';

  @override
  String get accountChecking => 'Comprobando…';

  @override
  String get accountConnectionFailed => 'Error de conexión';

  @override
  String storageUsed(String used) => '$used usados';

  @override
  String storageFree(String free) => '$free libres';

  @override
  String get accountName => 'Nombre de la cuenta';

  @override
  String get optional => 'Opcional';

  @override
  String get connect => 'Conectar';

  @override
  String fieldRequired(String label) => 'El campo "$label" es obligatorio';

  @override
  String get invalidEmail => 'Escribe un correo electrónico válido';

  @override
  String get whereToFind => '¿Dónde lo encuentro?';

  @override
  String get showSecret => 'Mostrar';

  @override
  String get hideSecret => 'Ocultar';

  @override
  String get advanced => 'Avanzado';

  @override
  String get baseUrl => 'URL base de la API';

  @override
  String get baseUrlHelper =>
      'Cámbiala solo si el proveedor se mudó a un nuevo dominio.';

  @override
  String get apiKey => 'Clave de API';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get chooseProvider => 'Elige un proveedor';

  @override
  String get noProviders => 'No hay proveedores disponibles';

  @override
  String get provider => 'Proveedor';

  @override
  String maxFileSize(String size) => 'Tamaño máx. de archivo: $size';

  @override
  String capability(Capability capability) => switch (capability) {
    Capability.browseFolders => 'Explorar',
    Capability.createFolder => 'Crear carpetas',
    Capability.renameFolder => 'Renombrar carpetas',
    Capability.moveFolder => 'Mover carpetas',
    Capability.deleteFolder => 'Eliminar carpetas',
    Capability.fileInfo => 'Detalles de archivo',
    Capability.renameFile => 'Renombrar archivos',
    Capability.moveFile => 'Mover archivos',
    Capability.deleteFile => 'Eliminar archivos',
    Capability.search => 'Búsqueda',
    Capability.upload => 'Subida',
    Capability.remoteUpload => 'Subida remota',
    Capability.accountInfo => 'Info. de cuenta',
  };

  @override
  String get manageFoldersCapability => 'Carpetas';

  @override
  String get manageFilesCapability => 'Gestionar archivos';

  @override
  String configProblem(ConfigProblem problem) => switch (problem.code) {
    ConfigProblemCode.wrongDriver => 'El driver no coincide.',
    ConfigProblemCode.unknownDriver => 'Este driver no está disponible.',
    ConfigProblemCode.invalidId =>
      'El id solo puede usar minúsculas, dígitos, "_" y "-".',
    ConfigProblemCode.missingName => 'El nombre es obligatorio.',
    ConfigProblemCode.missingApiBase => 'La URL de la API es obligatoria.',
    ConfigProblemCode.invalidUrl => 'Escribe una URL completa (https://...).',
    ConfigProblemCode.insecureUrl =>
      'Las URL deben usar https para no enviar credenciales sin cifrar.',
    ConfigProblemCode.missingIdPlaceholder =>
      'La plantilla del enlace del archivo debe contener {id}.',
    ConfigProblemCode.other => problem.message,
  };

  @override
  String get providers => 'Proveedores';

  @override
  String get addProvider => 'Añadir proveedor';

  @override
  String get editProvider => 'Editar proveedor';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get providerSaved => 'Proveedor guardado';

  @override
  String get customBadge => 'Personalizado';

  @override
  String get modifiedBadge => 'Modificado';

  @override
  String get disabledBadge => 'Desactivado';

  @override
  String get resetToDefault => 'Restablecer';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get registryUpdated => 'Lista de proveedores actualizada';

  @override
  String get registryUpToDate => 'La lista de proveedores está al día';

  @override
  String get registryDisabled =>
      'Las actualizaciones remotas están desactivadas';

  @override
  String get registryIssues => 'Algunos proveedores no se pudieron cargar';

  @override
  String get general => 'General';

  @override
  String get connection => 'Conexión';

  @override
  String get limits => 'Límites';

  @override
  String get driverSettings => 'Ajustes del controlador';

  @override
  String get driver => 'Controlador';

  @override
  String get providerId => 'ID';

  @override
  String get providerIdHelper =>
      'Minúsculas, números, "-" y "_". No se puede cambiar después.';

  @override
  String get invalidProviderId => 'Usa minúsculas, números, "-" y "_"';

  @override
  String get duplicateProviderId => 'Este ID ya está en uso';

  @override
  String get description => 'Descripción';

  @override
  String get website => 'Sitio web';

  @override
  String get mirrors => 'Espejos';

  @override
  String get mirrorsHelper =>
      'URLs alternativas de la API, se usan si la principal no responde.';

  @override
  String get addMirror => 'Añadir espejo';

  @override
  String get fileUrlTemplate => 'Plantilla del enlace del archivo';

  @override
  String get fileUrlTemplateHelper => '{id} se reemplaza por el id del archivo';

  @override
  String get invalidFileUrlTemplate =>
      'Escribe una URL https que contenga {id}';

  @override
  String get maxFileSizeMb => 'Tamaño máx. de archivo (MB)';

  @override
  String get maxFileSizeHelper =>
      'Vacío: valor del controlador. 0: sin límite.';

  @override
  String get allowedExtensions => 'Extensiones permitidas';

  @override
  String get allowedExtensionsHelper =>
      'Separadas por comas, p. ej. mp4, mkv. Vacío: valor del controlador. '
      '"*": cualquier archivo.';

  @override
  String get invalidNumber => 'Escribe un número válido';

  @override
  String get enabled => 'Activado';

  @override
  String get providerEnabledHelper =>
      'Los proveedores desactivados no aparecen al añadir cuentas.';

  @override
  String get invalidProviderConfig => 'La configuración no es válida';

  @override
  String resetProviderMessage(String name) =>
      'Se descartarán tus cambios en "$name".';

  @override
  String deleteProviderMessage(String name) =>
      'Se eliminará el proveedor personalizado "$name".';

  @override
  String registryUpdateFailed(String error) =>
      'No se pudieron buscar actualizaciones: $error';

  @override
  String lastChecked(String date) => 'Última comprobación: $date';

  @override
  String unknownDriver(String id) => 'Controlador desconocido "$id"';

  @override
  String transferRetrying(int retry, int? maxRetries) => maxRetries == null
      ? 'Reintentando ($retry)'
      : 'Reintentando ($retry/$maxRetries)';

  @override
  String batchTitle(int files, int accounts) =>
      '${fileCount(files)} → '
      '${_plural(accounts, '1 cuenta', '$accounts cuentas')}';

  @override
  String batchDone(int done, int total) =>
      _plural(total, '$done de 1 terminada', '$done de $total terminadas');

  @override
  String batchFailedCount(int count) =>
      _plural(count, '1 fallida', '$count fallidas');

  @override
  String batchCancelledCount(int count) =>
      _plural(count, '1 cancelada', '$count canceladas');

  @override
  String get retryFailed => 'Reintentar fallidas';

  @override
  String get clear => 'Quitar';

  @override
  String get uploadNotificationRunningTitle => 'Subiendo {displayName}';

  @override
  String get uploadNotificationRunningBody => '{progress}';

  @override
  String get uploadNotificationCompleteTitle => 'Subida completada';

  @override
  String get uploadNotificationCompleteBody => '{displayName}';

  @override
  String get uploadNotificationErrorTitle => 'Error al subir';

  @override
  String get uploadNotificationErrorBody => '{displayName}';

  @override
  String get uploadGroupNotificationRunningTitle => 'Subiendo archivos';

  @override
  String get uploadGroupNotificationRunningBody =>
      '{numFinished} de {numTotal} terminadas';

  @override
  String get uploadGroupNotificationCompleteTitle => 'Subidas completadas';

  @override
  String get uploadGroupNotificationCompleteBody =>
      '{numTotal} archivos subidos';

  @override
  String get uploadGroupNotificationErrorTitle => 'Algunas subidas fallaron';

  @override
  String get uploadGroupNotificationErrorBody =>
      '{numFailed} de {numTotal} fallidas';

  @override
  String get uploadQueueSection => 'Cola';

  @override
  String get finishedUploadsSection => 'Subidas terminadas';

  @override
  String get uploadDefaultsSection => 'Valores por defecto';

  @override
  String get maxConcurrentUploads => 'Subidas simultáneas';

  @override
  String get maxConcurrentUploadsHelper =>
      'Entre todas las cuentas. Cada proveedor puede permitir menos a la vez.';

  @override
  String get automaticRetries => 'Reintentos automáticos';

  @override
  String get automaticRetriesHelper =>
      'Tras errores de red, límites de peticiones y errores del servidor.';

  @override
  String get off => 'No';

  @override
  String get checkStorage => 'Comprobar el espacio libre';

  @override
  String get checkStorageHelper =>
      'Omite los archivos que no caben en la cuenta. Añade una petición por '
      'subida.';

  @override
  String get autoClear => 'Quitar las subidas completadas';

  @override
  String get autoClearHelper =>
      'Las subidas fallidas y canceladas siempre se quedan en la lista.';

  @override
  String get autoClearNever => 'Nunca';

  @override
  String get autoClearImmediately => 'Al momento';

  @override
  String autoClearAfter(Duration delay) => 'A los ${_duration(delay)}';

  @override
  String get defaultFolder => 'Carpeta por defecto';

  @override
  String get defaultFolderHelper =>
      'Se usa al subir a varias cuentas. Déjala vacía para la carpeta raíz.';

  @override
  String get folderPathHint => 'p. ej. Películas/2026';

  @override
  String get visibilityLabel => 'Visibilidad';

  @override
  String visibility(UploadVisibility visibility) => switch (visibility) {
    UploadVisibility.providerDefault => 'La del proveedor',
    UploadVisibility.public => 'Pública',
    UploadVisibility.private => 'Privada',
  };

  @override
  String get filesSection => 'Archivos';

  @override
  String get addFiles => 'Añadir archivos';

  @override
  String get noFilesSelected => 'Aún no hay archivos';

  @override
  String get noFilesSelectedHint => 'Añade los archivos que quieres subir.';

  @override
  String filesSummary(int count, String size) => '${fileCount(count)} · $size';

  @override
  String get selectNone => 'Ninguna';

  @override
  String upToSize(String size) => 'Hasta $size';

  @override
  String accountsSelected(int selected, int total) => _plural(
    selected,
    '1 de $total seleccionada',
    '$selected de $total seleccionadas',
  );

  @override
  String get noUploadAccounts => 'Ninguna cuenta admite subidas';

  @override
  String get noUploadAccountsHint =>
      'Conecta una cuenta de un proveedor que admita subidas.';

  @override
  String get destinationSection => 'Destino';

  @override
  String get destinationFolder => 'Carpeta de destino';

  @override
  String get destinationFolderHelper =>
      'Se busca por nombre en cada cuenta seleccionada y se crea si no '
      'existe. Déjala vacía para la carpeta raíz.';

  @override
  String uploadsSkipped(int count) =>
      _plural(count, 'Se omitirá 1 subida', 'Se omitirán $count subidas');

  @override
  String get uploadsSkippedHint =>
      'Estos archivos superan los límites del proveedor. El resto de '
      'subidas empieza con normalidad.';

  @override
  String skippedUpload(String file, String account, String reason) =>
      '$file → $account: $reason';

  @override
  String andMore(int count) => _plural(count, 'y 1 más', 'y $count más');

  @override
  String skippedFor(String accounts) => 'Se omite en $accounts';

  @override
  String startUploads(int count) =>
      _plural(count, 'Iniciar 1 subida', 'Iniciar $count subidas');

  @override
  String get backupSection => 'Copia de seguridad';

  @override
  String get exportBackup => 'Exportar configuración';

  @override
  String get exportBackupHelper =>
      'Cuentas, proveedores y ajustes en un archivo cifrado';

  @override
  String get importBackup => 'Importar configuración';

  @override
  String get importBackupHelper =>
      'Restaura un archivo de copia en este dispositivo';

  @override
  String get exportBackupTitle => 'Cifra la copia';

  @override
  String get exportBackupMessage =>
      'La copia contiene claves de API y contraseñas. Elige una contraseña '
      'para cifrarla; la necesitarás para restaurar la copia.';

  @override
  String get confirmPassword => 'Confirma la contraseña';

  @override
  String passwordTooShort(int minLength) =>
      'Usa al menos $minLength caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String passwordStrength(PasswordStrength strength) => switch (strength) {
    PasswordStrength.tooShort => 'Demasiado corta',
    PasswordStrength.weak => 'Débil',
    PasswordStrength.fair => 'Aceptable',
    PasswordStrength.good => 'Buena',
    PasswordStrength.strong => 'Fuerte',
  };

  @override
  String get backupPasswordWarning =>
      'Si pierdes esta contraseña, no podrás restaurar la copia. Nadie '
      'puede recuperarla.';

  @override
  String get exportAction => 'Exportar';

  @override
  String get encryptingBackup => 'Cifrando…';

  @override
  String get backupSaved => 'Copia guardada';

  @override
  String get saveBackupFailed => 'No se pudo guardar la copia';

  @override
  String get openBackupFailed => 'No se pudo abrir el archivo';

  @override
  String get invalidBackupTitle => 'No se puede restaurar este archivo';

  @override
  String invalidBackup(InvalidBackupReason reason) => switch (reason) {
    InvalidBackupReason.notABackup =>
      'Este archivo no es una copia de la configuración.',
    InvalidBackupReason.corrupted => 'El archivo de copia está dañado.',
    InvalidBackupReason.unsupported =>
      'Esta copia se hizo con una versión más reciente de la app. '
          'Actualízala para restaurarla.',
  };

  @override
  String get importBackupTitle => 'Restaurar una copia';

  @override
  String backupCreatedAt(String date) => 'Creada el $date';

  @override
  String get backupPasswordHelper =>
      'La contraseña que elegiste al exportar la copia';

  @override
  String get importModeLabel => 'Cómo importar';

  @override
  String get importMerge => 'Combinar';

  @override
  String get importMergeHelper =>
      'Añade las cuentas y proveedores nuevos y actualiza los existentes. '
      'No se elimina nada.';

  @override
  String get importReplace => 'Reemplazar todo';

  @override
  String get importReplaceHelper =>
      'Elimina las cuentas y los cambios de proveedores que no estén en la '
      'copia.';

  @override
  String get importAction => 'Importar';

  @override
  String get decryptingBackup => 'Descifrando…';

  @override
  String get replaceConfirmTitle => '¿Reemplazar tu configuración?';

  @override
  String get replaceConfirmMessage =>
      'Se eliminarán las cuentas que no estén en la copia y se cancelarán '
      'sus subidas. Se reemplazarán los cambios de proveedores, los ajustes '
      'de subida y las carpetas recientes. No se puede deshacer.';

  @override
  String get replaceAction => 'Reemplazar';

  @override
  String get wrongBackupPassword =>
      'Contraseña incorrecta o el archivo se ha modificado.';

  @override
  String get backupRestored => 'Copia restaurada';

  @override
  String accountsAdded(int count) =>
      _plural(count, '1 cuenta añadida', '$count cuentas añadidas');

  @override
  String accountsUpdated(int count) =>
      _plural(count, '1 cuenta actualizada', '$count cuentas actualizadas');

  @override
  String accountsRemoved(int count) =>
      _plural(count, '1 cuenta eliminada', '$count cuentas eliminadas');

  @override
  String providersImported(int count) => _plural(
    count,
    '1 cambio de proveedor importado',
    '$count cambios de proveedores importados',
  );

  @override
  String providersSkipped(int count) => _plural(
    count,
    '1 proveedor omitido: requiere una versión más reciente',
    '$count proveedores omitidos: requieren una versión más reciente',
  );

  @override
  String get uploadSettingsRestored => 'Ajustes de subida restaurados';

  @override
  String get backupUpToDate => 'Todo estaba ya al día';

  String _duration(Duration delay) {
    if (delay.inHours > 0 && delay.inMinutes % 60 == 0) {
      return '${delay.inHours} h';
    }
    if (delay.inMinutes > 0 && delay.inSeconds % 60 == 0) {
      return '${delay.inMinutes} min';
    }
    return '${delay.inSeconds} s';
  }
}

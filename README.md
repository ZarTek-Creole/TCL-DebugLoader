# TCL-DebugLoader
Ce script ce charge en premier dans la config eggdrop. DebugLoader permet de charger des scripts TCL. Il redirige les erreurs dans un fichier ${::botnet-nick}_Error.log, ainsi que sur un channel 'Channel_Debug'. Très pratique pour les developpers, afin de suivre les erreurs, mais également il permet de ne pas "planté" le robot en cas de probleme de syntaxe apres un rehash.

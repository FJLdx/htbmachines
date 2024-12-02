# htbmachines
Script para buscar información sobre máquinas de Hack The Box basado en la base de datos de @S4vitar.
=======
# HTBMachines

HTBMachines es un script diseñado para buscar información detallada sobre máquinas de Hack The Box. Este proyecto se basa en la base de datos y tutoriales proporcionados por @S4vitar.

## Características
- **Búsqueda por nombre de máquina**.
- **Búsqueda por dirección IP**.
- **Filtrar por dificultad (español e inglés)**.
- **Filtrar por sistema operativo**.
- **Combinación de filtros por dificultad y sistema operativo**.
- **Obtención del enlace del tutorial en YouTube**.
- **Actualización automática de la base de datos.**

## Requisitos
- **Sistema Operativo**: Linux o macOS.
- **Dependencias**:
  - `curl`
  - `awk`
  - `js-beautify`
  - `sponge`

## Instalación
1 Clona este repositorio:
   ```bash
   git clone https://github.com/FJLdx/htbmachines.git
   cd htbmachines
   ```

2	Asegúrate de que el script tiene permisos de ejecución:

```chmod +x htbmachines.sh

```

3	Opcional: Crea un enlace simbólico para ejecutarlo desde cualquier lugar:

```sudo ln -s $(pwd)/htbmachines.sh /usr/local/bin/htbmachines

```

Uso

Para ejecutar el script, utiliza las siguientes opciones:

```htbmachines -h

```

Créditos

Este script se creó como parte del curso de Hack4U impartido por @S4vitar. La base de datos y tutoriales utilizados son propiedad de @S4vitar.
Nota

Este proyecto está destinado exclusivamente para fines educativos en el contexto del hacking ético.

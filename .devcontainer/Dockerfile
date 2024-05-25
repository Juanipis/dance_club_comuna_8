# Utilizamos una imagen base de Dart que tenga el Dart SDK deseado
FROM dart:3.3.3

# Instalamos las dependencias necesarias para Flutter
RUN apt-get update
RUN apt-get install -y curl git unzip xz-utils zip libglu1-mesa
RUN apt-get clean

# Clonamos la versión específica de Flutter
RUN git clone https://github.com/flutter/flutter.git -b 3.19.5 --depth 1 /flutter

# Configuramos el PATH para incluir el binario de Flutter
ENV PATH="/flutter/bin:$PATH"

# Ejecutamos flutter doctor para verificar la instalación y flutter pub upgrade para actualizar las dependencias
RUN flutter doctor

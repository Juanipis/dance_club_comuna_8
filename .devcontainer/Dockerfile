# Utilizamos una imagen base de Dart actualizada (Dart 3.7)
FROM dart:3.7

# Instalamos las dependencias necesarias para Flutter
RUN apt-get update && \
    apt-get install -y curl git unzip xz-utils zip libglu1-mesa && \
    apt-get clean

# Clonamos la última versión estable de Flutter (3.29.1)
RUN git clone https://github.com/flutter/flutter.git -b 3.29.1 --depth 1 /flutter

# Configuramos el PATH para incluir el binario de Flutter
ENV PATH="/flutter/bin:$PATH"

# Ejecutamos flutter doctor para verificar la instalación
RUN flutter doctor

#!/bin/bash

echo "===================================================="
echo " 🛡️ Rutine - Compilador Seguro de Producción"
echo "===================================================="
echo ""
echo "Iniciando proceso de compilación con ofuscación AES y código nativo..."
echo "Esto ocultará los strings y la lógica interna de la aplicación."
echo ""

flutter clean
flutter pub get

echo ""
echo "Construyendo APK..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

echo ""
echo "===================================================="
echo " APK Seguro Generado Exitosamente"
echo " Ruta: build/app/outputs/flutter-apk/app-release.apk"
echo "===================================================="

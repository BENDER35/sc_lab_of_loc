# Guía didáctica (Español)

## Objetivo

Aprender ciberseguridad defensiva en una **red local aislada**, enfocándose en el vector de documentos de Office (macros) desde el punto de vista de prevención, análisis estático y detección.

> **Importante**: No uses estas técnicas fuera de tu laboratorio. No accedas a equipos ajenos sin autorización escrita.

## 1. Diseño del laboratorio

### Topología recomendada

- **Host**: tu máquina física (Linux).
- **VM Windows**: máquina de pruebas con Office (licencia/evaluación legítima).
- **VM Linux análisis**: REMnux/Ubuntu con `oletools`, YARA, Sigma tools.
- **Red**: `Internal Network` o `Host-only` en VirtualBox. Sin adaptador puente.

### Reglas de aislamiento

- Sin NAT/Bridged en las VMs del laboratorio cuando hagas ejercicios de análisis.
- Usa snapshots antes de cada ejercicio.
- No compartas carpetas del host con permisos de escritura innecesarios.
- No pegues credenciales reales dentro del lab.

## 2. Montaje con VirtualBox

```bash
# En el host Linux
./scripts/create_isolated_lab.sh --name sc-lab --network 192.168.56.0/24
```

Asignar a cada VM **un solo adaptador** de tipo Host-only/Internal conectado a la red del lab. Verificar:

```bash
./scripts/check_lab_isolation.sh --vm "SC-Windows" --vm "SC-Linux"
```

Comprobaciones manuales dentro de las VMs:

- La IP debe pertenecer al rango del lab.
- No debe haber ruta a Internet (o debe fallar `ping 1.1.1.1` si no hay NAT).
- Solo debe haber conectividad entre VMs del lab.

## 3. Endurecimiento de Microsoft Office (defensivo)

El objetivo es **reducir la superficie de ataque** de macros y contenido activo.

### Medidas clave

- **Macros**: deshabilitar macros salvo las firmadas por editor de confianza; bloquear macros de Internet (MOTW).
- **Protected View**: habilitar para archivos de Internet, ubicaciones inseguras y adjuntos Outlook.
- **ASR rules (Defender)**: bloquear creación de procesos hijos desde Office, inyección, contenido ejecutable desde correo.
- **AMSI/ETW**: mantener habilitados para visibilidad y detección.
- **Actualizaciones**: Office y Windows al día.

### Script de auditoría/hardening

En la VM Windows, como Administrador:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\windows\office_hardening.ps1 -AuditOnly
.\scripts\windows\office_hardening.ps1
```

Revisa los cambios antes de aplicarlos en equipos reales; en laboratorio puedes aplicarlos directamente.

## 4. Análisis estático seguro de macros

Nunca ejecutes un documento sospechoso para "ver qué hace". Empieza por análisis estático.

### Herramientas

- `oleid`: identifica características de riesgo.
- `olevba`: extrae y analiza macros VBA.
- `mraptor`: detecta comportamiento sospechoso de macros.

### Flujo

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install oletools

oleid documento.docm
olevba --decode documento.docm
mraptor documento.docm
```

Trabaja sobre una **copia** en una VM con snapshot. Si el documento no es tuyo o no tienes permiso, no lo analices fuera de un entorno autorizado.

## 5. Detección

En `detection/` hay ejemplos de reglas:

- **Sigma**: proceso hijo sospechoso lanzado por Office.
- **YARA**: palabras clave típicas de macros sospechosas (ejemplo educativo).

Estas reglas son puntos de partida; ajústalas a tu telemetría y reduce falsos positivos.

## 6. Ejercicio propuesto

1. Crea un documento de prueba **inocuo** con una macro que solo muestre un `MsgBox`.
2. Analízalo con `olevba` y observa los indicadores.
3. Aplica hardening y verifica que la macro queda bloqueada según política.
4. Revisa eventos/logs y compara con la regla Sigma.

## 7. Qué aprender después

- Redes: TCP/IP, DNS, HTTP, TLS.
- Windows internals y Sysmon.
- Linux, Bash, Python.
- MITRE ATT&CK (tácticas/técnicas) desde el lado defensivo.
- CTFs legales: TryHackMe, Hack The Box Academy, OverTheWire.

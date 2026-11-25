# Guía didáutica (Asturianu / Bable)

## Oxetivu

Deprender ciberseguranza defensiva nuna **rede llocal aisllada**, centrándose nel vector de documentos d'Office (macros) dende la perspeutiva de prevención, análisis estáticu y deteición.

> **Importante**: Nun uses estes téuniques fuera del to llaboratoriu. Nun accedas a equipos ayenos ensin autorización escrita.

## 1. Diseñu del llaboratoriu

### Topoloxía recomendada

- **Anfitrión (Host)**: la to máquina física (Linux).
- **VM Windows**: máquina de pruebes con Office (llicencia/evaluación llexítima).
- **VM Linux d'análisis**: REMnux/Ubuntu con `oletools`, YARA, ferramientes Sigma.
- **Rede**: `Internal Network` o `Host-only` en VirtualBox. Ensin adaptador ponte (bridged).

### Regles d'aislamientu

- Ensin NAT/Bridged nes VMs del llaboratoriu cuando faigas exercicios d'análisis.
- Fai snapshots enantes de cada exerciciu.
- Nun compartas carpetes del anfitrión con permisos d'escritura innecesarios.
- Nun pegues credenciales reales dientro del llab.

## 2. Montaxe con VirtualBox

```bash
# Nel anfitrión Linux
./scripts/create_isolated_lab.sh --name sc-lab --network 192.168.56.0/24
```

Asigna a cada VM **un solu adaptador** de tipu Host-only/Internal conectáu a la rede del llab. Verifica:

```bash
./scripts/check_lab_isolation.sh --vm "SC-Windows" --vm "SC-Linux"
```

Comprobaciones manuales dientro de les VMs:

- La IP tien de pertenecer al rangu del llab.
- Nun tien d'haber ruta a Internet (o tien de fallar `ping 1.1.1.1` si nun hai NAT).
- Solo tien d'haber conectividá ente VMs del llab.

## 3. Endurecimientu de Microsoft Office (defensivu)

L'oxetivu ye **amenorgar la superficie d'ataque** de macros y conteníu activu.

### Midíes clave

- **Macros**: desactivar macros sacante les roblaes por editor d'enfotu; bloquiar macros d'Internet (MOTW).
- **Protected View**: activar pa ficheros d'Internet, allugamientos inseguros y axuntos d'Outlook.
- **Regles ASR (Defender)**: bloquiar creación de procesos fíos dende Office, inyeición, conteníu executable dende corréu.
- **AMSI/ETW**: caltener activaos pa visibilidá y deteición.
- **Anovamientos**: Office y Windows al día.

### Script d'auditoría/endurecimientu

Na VM Windows, como Alministrador:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\windows\office_hardening.ps1 -AuditOnly
.\scripts\windows\office_hardening.ps1
```

Revisa los cambeos enantes d'aplicalos n'equipos reales; nel llaboratoriu puedes aplicalos direutamente.

## 4. Análisis estáticu seguru de macros

Nunca executes un documentu sospechosu pa "ver qué fai". Entama con análisis estáticu.

### Ferramientes

- `oleid`: identifica carauterístiques de riesgu.
- `olevba`: estrái y analiza macros VBA.
- `mraptor`: detecta comportamientu sospechosu de macros.

### Fluxu

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install oletools

oleid documentu.docm
olevba --decode documentu.docm
mraptor documentu.docm
```

Trabaya sobre una **copia** nuna VM con snapshot. Si'l documentu nun ye tuyu o nun tienes permisu, nun lu analices fuera d'un entornu autorizáu.

## 5. Deteición

En `detection/` hai exemplos de regles:

- **Sigma**: procesu fíu sospechosu llanzáu por Office.
- **YARA**: palabres clave típiques de macros sospechoses (exemplu educativu).

Estes regles son puntos d'entamu; axústales a la to telemetría y amenorga falsos positivos.

## 6. Exerciciu propuestu

1. Crea un documentu de prueba **inocuu** con una macro que solo amuese un `MsgBox`.
2. Analízalu con `olevba` y observa los indicadores.
3. Aplica endurecimientu y verifica que la macro queda bloquiada según la política.
4. Revisa eventos/rexistros y compara cola regla Sigma.

## 7. Qué deprender dempués

- Redes: TCP/IP, DNS, HTTP, TLS.
- Internos de Windows y Sysmon.
- Linux, Bash, Python.
- MITRE ATT&CK (táctiques/téuniques) dende'l llau defensivu.
- CTFs llegales: TryHackMe, Hack The Box Academy, OverTheWire.

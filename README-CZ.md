# RCT1 Deluxe Full HD

Malý kompatibilitní patch a launcher pro **původní RollerCoaster Tycoon 1 Deluxe** na moderních Windows.

Zachovává původní RCT1 engine a přidává:

- skutečnou herní plochu **1920×1080**
- borderless fullscreen
- kompatibilitu s Windows 11
- posouvání mapy myší u okrajů obrazovky
- podporu více monitorů
- automatické uvolnění kurzoru při Alt+Tab
- automatickou zálohu původního EXE
- **automatické rozbalení běžné NeoLite Steam/GOG verze EXE**

Nejde o roztažený obraz 1024×768. Upravené EXE skutečně dovolí hře vykreslit větší plochu, takže je z parku vidět více.

## Screenshoty

**RCT1 Deluxe běžící v rozlišení 1920×1080 na Windows 11**

![RCT1 Deluxe Full HD gameplay](patch/screenshots/RCT-fullhd2.jpg)

Další ukázka ve Full HD:

![RCT1 Deluxe Full HD gameplay](patch/screenshots/RCT-fullhd.jpg)


## Otestovaná konfigurace

- Windows 11
- RollerCoaster Tycoon Deluxe ze Steamu, anglická verze
- Deluxe 1.20.015
- herní monitor 1920×1080
- dva monitory

## Instalace

1. Nainstaluj **RollerCoaster Tycoon Deluxe**.
2. **Ještě před rozbalením staženého ZIPu** na něj klikni pravým tlačítkem → **Vlastnosti** → zaškrtni **Odblokovat** → **Použít / OK**. Je to důležité, protože Windows jinak může blokovat CMD/PowerShell skripty.
3. ZIP rozbal.
4. Z balíčku nakopíruj do hlavní složky hry pouze:

   - `Install-RCT-FullHD.cmd`
   - `Start-RCT-FullHD.cmd`
   - `Restore-Original-RCT.cmd`
   - celou složku `patch`

   Oba README soubory mohou zůstat mimo složku hry. Ve složce RCT tak zůstanou navíc jen tři malé spouštěcí/instalační soubory a jedna složka `patch`.

   Typická Steam cesta:

   ```text
   C:\Program Files (x86)\Steam\steamapps\common\RollerCoaster Tycoon Deluxe\
   ```

5. Dvojklikem spusť:

   ```text
   Install-RCT-FullHD.cmd
   ```

6. Potvrď výzvu UAC systému Windows.
7. Počkej na hlášku **Installation complete**.
8. Instalátor zároveň vytvoří na ploše zástupce **RollerCoaster Tycoon FullHD** s původní herní ikonou.
9. Hru potom spouštěj buď přes tohoto zástupce, nebo přes:

   ```text
   Start-RCT-FullHD.cmd
   ```

A to je vše. **Není potřeba instalovat Python ani zadávat jakékoli příkazy.**

Instalátor automaticky vytvoří zálohu původního EXE jako:

```text
RCT.original.exe
```

### Anglický Steam/GOG Deluxe 1.20.015

Běžné anglické `RCT.EXE` je zabalené kompresorem **NeoLite**. Instalátor to teď řeší automaticky.

Pokud je potřeba Steam/GOG EXE rozbalit, instalátor si může dočasně stáhnout tyto **pomocné balíčky**:

- **Python 3.10.11 embeddable runtime** z python.org — přenosný Python pouze pro spuštění unpackeru
- **Neo-Executable-Decompressor s podporou ExeLock**, připnutý na commit `4c8e0166af65f4a5410cd6a011489e04ffee1bbd` — rozbalí variantu ExeLock/NeoLite použitou u RCT
- **pefile 2023.2.7** z GitHubu — knihovna pro práci s PE soubory
- **zipfile-deflate64 0.2.0** z PyPI — Deflate64 dekomprese, kterou ExeLock verze RCT používá

Vše se stáhne pouze do dočasné složky Windows. Instalátor u Deflate64 balíčku ověří SHA-256 podle údajů z PyPI, rozbalí tvoje vlastní `RCT.EXE`, provede Full HD patch a pomocné soubory zase smaže. Python se do Windows **neinstaluje**.

Při první instalaci je pro automatické rozbalení potřeba připojení k Internetu.

Technické podrobnosti jsou v [UNPACKING.md](patch/UNPACKING.md).

## Co patch mění

U podporovaného rozbaleného anglického Deluxe 1.20.015 změní limit velikosti herního okna:

- 1280 → 1920 pixelů
- 1024 → 1080 pixelů

Současně nastaví kompatibilitu Windows pro `RCT.EXE`:

- Windows XP SP3
- 16bitové barvy
- DPI škálování provádí aplikace
- spouštění jako správce

## Proč borderless a ne původní fullscreen?

Původní DirectDraw fullscreen RCT1 vznikl pro rozlišení jako 640×480, 800×600 a 1024×768.

Widescreen patch funguje nejlépe tak, že RCT vykreslí větší **okenní** plochu a launcher z ní následně vytvoří borderless fullscreen.

RCT1 ale v okenním režimu nepoužívá posouvání mapy myší u okrajů. Launcher ho proto obnovuje:

1. při aktivní hře omezí kurzor na herní monitor;
2. rozpozná dotyk okraje;
3. emuluje odpovídající šipku;
4. při Alt+Tab kurzor i případně držené klávesy okamžitě uvolní.

Tím funguje edge-scrolling i na sestavě s více monitory.

## Více monitorů

Dokud je RCT aktivní, kurzor zůstává na herním monitoru, aby fungoval posun na všech čtyřech okrajích.

Pro přejetí myší na druhý monitor použij nejdřív **Alt+Tab**.

## Návrat k originálu

Spusť:

```text
Restore-Original-RCT.cmd
```

Vrátí se `RCT.original.exe` a odstraní se kompatibilitní nastavení zapsané instalátorem.

## Omezení

- První verze je otestovaná konkrétně na **1920×1080**.
- 2560×1440 a 4K zatím nejsou otestované/podporované.
- UI zůstává v původní pixelové velikosti, takže je ve Full HD menší.
- Launcher musí po dobu hraní běžet na pozadí, protože zajišťuje edge-scrolling a práci s více monitory.
- SmartScreen/antivirus může varovat před staženými CMD/PowerShell skripty; celý zdrojový kód je součástí balíku.

## Bez herních souborů

Projekt neobsahuje žádné EXE ani assety RollerCoaster Tycoon. Obsahuje pouze skripty, které upraví uživatelem dodané EXE z vlastní instalace.

## Licence

Skripty jsou pod licencí MIT. Herní soubory RollerCoaster Tycoon nejsou součástí projektu ani licence.

Jde o neoficiální komunitní projekt bez vazby na držitele práv ke hře.

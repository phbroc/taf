import 'dart:convert';

class Cryptography {


  static String encode(String s, String k, bool doRight) {
    String retStr = "";
    // local code et local key
    int _lc = 0;
    int _lk = 0;
    final latin1Codec = Latin1Codec();
    List<int> codes = [];
    List<int> keycodes = [];
    int keylength = k.length;
    int i = 0;

    try {
      codes = latin1Codec.encode(s);
      keycodes = latin1Codec.encode(k);
    }
    catch (e) {
      throw Exception('encode function, error ASCII encode, '+e);
    }
    List<int> shiftcodes = [];

    // on démarre la lecture de la clé en fonction de la longueur de la chaine à crypter, de manière à ne pas toujours utiliser le premier caractère de la clé.
    i = s.length%keylength;

    codes.forEach((ascCode) {
      // pour minimiser la valeur de déplacement on considère que le code de la clé ne comporte pas de caractères en dessous de ASCII 0 = 48
      _lk = keycodes[i]-47;
      // encode avec right et décoder avec left
      if (doRight) _lc = shiftRightChar(ascCode,_lk);
      else _lc = shiftLeftChar(ascCode,_lk);

      shiftcodes.add(_lc);
      i++;
      if (i>=keylength) i=0;
    });

    try {
      retStr = latin1Codec.decode(shiftcodes);
    }
    catch (e) {
      throw Exception('encode function, error ASCII decode, '+e);
    }
    return retStr;
  }

  static int shiftRightChar(int c, int s) {
    // deux plages de caractères valides car imprimables [32,126] et [192,155]
    int retCode = c + s;
    /*
    if (retCode > 255) {
      retCode = 31 + (retCode - 255);
      if (retCode > 126) retCode = 191 + (retCode - 126);
    }
    else if ((retCode > 126) && (retCode < 192)){
      retCode = 191 + (retCode - 126);
      if (retCode > 255) retCode = 31 + (retCode - 255);
    }
    */

    if (retCode > 255) {
      retCode -= 224;
      if (retCode > 126) retCode += 65;
    }
    else if ((retCode > 126) && (retCode < 192)) {
      retCode += 65;
      if (retCode > 255) retCode -= 224;
    }

    return retCode;
  }

  static int shiftLeftChar(int c, int s) {
    // deux plages de caractères valides car imprimables [32,126] et [192,155]
    int retCode = c - s;

    /*
    if (retCode < 32) {
      retCode = 256 - (32 - retCode);
      if (retCode < 192) retCode = 127 - (192 - retCode);
    }
    else if ((retCode < 192) && (retCode > 126)) {
      retCode = 127 - (192 - retCode);
      if (retCode < 32) retCode = 256 - (32 - retCode);
    }
    */

    if (retCode < 32) {
      retCode += 224;
      if (retCode < 192) retCode -= 65;
    }
    else if ((retCode < 192) && (retCode > 126)) {
      retCode -= 65;
      if (retCode < 32) retCode += 224;
    }

    return retCode;
  }

}
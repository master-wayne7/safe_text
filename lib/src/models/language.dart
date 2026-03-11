enum Language {
  afrikaans,
  amharic,
  arabic,
  azerbaijani,
  belarusian,
  bulgarian,
  catalan,
  cebuano,
  czech,
  welsh,
  danish,
  german,
  dzongkha,
  greek,
  english,
  esperanto,
  spanish,
  estonian,
  basque,
  persian,
  finnish,
  filipino,
  french,
  scottishGaelic,
  galician,
  hindi,
  croatian,
  hungarian,
  armenian,
  indonesian,
  icelandic,
  italian,
  japanese,
  kabyle,
  khmer,
  korean,
  latin,
  lithuanian,
  latvian,
  maori,
  macedonian,
  malayalam,
  mongolian,
  marathi,
  malay,
  maltese,
  burmese,
  dutch,
  norwegian,
  norfuk,
  piapoco,
  polish,
  portuguese,
  romanian,
  kriol,
  russian,
  slovak,
  slovenian,
  samoan,
  albanian,
  serbian,
  swedish,
  tamil,
  telugu,
  tetum,
  thai,
  klingon,
  tongan,
  turkish,
  ukrainian,
  uzbek,
  vietnamese,
  yiddish,
  chinese,
  zulu,
  all,
}

extension LanguageExtension on Language {
  static Language fromString(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'af':
      case 'afrikaans':
        return Language.afrikaans;
      case 'am':
      case 'amharic':
        return Language.amharic;
      case 'ar':
      case 'arabic':
        return Language.arabic;
      case 'az':
      case 'azerbaijani':
        return Language.azerbaijani;
      case 'be':
      case 'belarusian':
        return Language.belarusian;
      case 'bg':
      case 'bulgarian':
        return Language.bulgarian;
      case 'ca':
      case 'catalan':
        return Language.catalan;
      case 'ceb':
      case 'cebuano':
        return Language.cebuano;
      case 'cs':
      case 'czech':
        return Language.czech;
      case 'cy':
      case 'welsh':
        return Language.welsh;
      case 'da':
      case 'danish':
        return Language.danish;
      case 'de':
      case 'german':
        return Language.german;
      case 'dz':
      case 'dzongkha':
        return Language.dzongkha;
      case 'el':
      case 'greek':
        return Language.greek;
      case 'en':
      case 'english':
        return Language.english;
      case 'eo':
      case 'esperanto':
        return Language.esperanto;
      case 'es':
      case 'spanish':
        return Language.spanish;
      case 'et':
      case 'estonian':
        return Language.estonian;
      case 'eu':
      case 'basque':
        return Language.basque;
      case 'fa':
      case 'persian':
        return Language.persian;
      case 'fi':
      case 'finnish':
        return Language.finnish;
      case 'fil':
      case 'filipino':
        return Language.filipino;
      case 'fr':
      case 'french':
        return Language.french;
      case 'gd':
      case 'scottish gaelic':
        return Language.scottishGaelic;
      case 'gl':
      case 'galician':
        return Language.galician;
      case 'hi':
      case 'hindi':
        return Language.hindi;
      case 'hr':
      case 'croatian':
        return Language.croatian;
      case 'hu':
      case 'hungarian':
        return Language.hungarian;
      case 'hy':
      case 'armenian':
        return Language.armenian;
      case 'id':
      case 'indonesian':
        return Language.indonesian;
      case 'is':
      case 'icelandic':
        return Language.icelandic;
      case 'it':
      case 'italian':
        return Language.italian;
      case 'ja':
      case 'japanese':
        return Language.japanese;
      case 'kab':
      case 'kabyle':
        return Language.kabyle;
      case 'kh':
      case 'khmer':
        return Language.khmer;
      case 'ko':
      case 'korean':
        return Language.korean;
      case 'la':
      case 'latin':
        return Language.latin;
      case 'lt':
      case 'lithuanian':
        return Language.lithuanian;
      case 'lv':
      case 'latvian':
        return Language.latvian;
      case 'mi':
      case 'maori':
        return Language.maori;
      case 'mk':
      case 'macedonian':
        return Language.macedonian;
      case 'ml':
      case 'malayalam':
        return Language.malayalam;
      case 'mn':
      case 'mongolian':
        return Language.mongolian;
      case 'mr':
      case 'marathi':
        return Language.marathi;
      case 'ms':
      case 'malay':
        return Language.malay;
      case 'mt':
      case 'maltese':
        return Language.maltese;
      case 'my':
      case 'burmese':
        return Language.burmese;
      case 'nl':
      case 'dutch':
        return Language.dutch;
      case 'no':
      case 'norwegian':
        return Language.norwegian;
      case 'pih':
      case 'norfuk':
      case 'pitcairn':
        return Language.norfuk;
      case 'piy':
      case 'piapoco':
        return Language.piapoco;
      case 'pl':
      case 'polish':
        return Language.polish;
      case 'pt':
      case 'portuguese':
        return Language.portuguese;
      case 'ro':
      case 'romanian':
        return Language.romanian;
      case 'rop':
      case 'kriol':
        return Language.kriol;
      case 'ru':
      case 'russian':
        return Language.russian;
      case 'sk':
      case 'slovak':
        return Language.slovak;
      case 'sl':
      case 'slovenian':
        return Language.slovenian;
      case 'sm':
      case 'samoan':
        return Language.samoan;
      case 'sq':
      case 'albanian':
        return Language.albanian;
      case 'sr':
      case 'serbian':
        return Language.serbian;
      case 'sv':
      case 'swedish':
        return Language.swedish;
      case 'ta':
      case 'tamil':
        return Language.tamil;
      case 'te':
      case 'telugu':
        return Language.telugu;
      case 'tet':
      case 'tetum':
        return Language.tetum;
      case 'th':
      case 'thai':
        return Language.thai;
      case 'tlh':
      case 'klingon':
        return Language.klingon;
      case 'to':
      case 'tongan':
        return Language.tongan;
      case 'tr':
      case 'turkish':
        return Language.turkish;
      case 'uk':
      case 'ukrainian':
        return Language.ukrainian;
      case 'uz':
      case 'uzbek':
        return Language.uzbek;
      case 'vi':
      case 'vietnamese':
        return Language.vietnamese;
      case 'yid':
      case 'yiddish':
        return Language.yiddish;
      case 'zh':
      case 'chinese':
        return Language.chinese;
      case 'zu':
      case 'zulu':
        return Language.zulu;
      case 'all':
        return Language.all;
      default:
        return Language.english; // Default to English
    }
  }

  String get fileCode {
    switch (this) {
      case Language.afrikaans: return 'af';
      case Language.amharic: return 'am';
      case Language.arabic: return 'ar';
      case Language.azerbaijani: return 'az';
      case Language.belarusian: return 'be';
      case Language.bulgarian: return 'bg';
      case Language.catalan: return 'ca';
      case Language.cebuano: return 'ceb';
      case Language.czech: return 'cs';
      case Language.welsh: return 'cy';
      case Language.danish: return 'da';
      case Language.german: return 'de';
      case Language.dzongkha: return 'dz';
      case Language.greek: return 'el';
      case Language.english: return 'en';
      case Language.esperanto: return 'eo';
      case Language.spanish: return 'es';
      case Language.estonian: return 'et';
      case Language.basque: return 'eu';
      case Language.persian: return 'fa';
      case Language.finnish: return 'fi';
      case Language.filipino: return 'fil';
      case Language.french: return 'fr';
      case Language.scottishGaelic: return 'gd';
      case Language.galician: return 'gl';
      case Language.hindi: return 'hi';
      case Language.croatian: return 'hr';
      case Language.hungarian: return 'hu';
      case Language.armenian: return 'hy';
      case Language.indonesian: return 'id';
      case Language.icelandic: return 'is';
      case Language.italian: return 'it';
      case Language.japanese: return 'ja';
      case Language.kabyle: return 'kab';
      case Language.khmer: return 'kh';
      case Language.korean: return 'ko';
      case Language.latin: return 'la';
      case Language.lithuanian: return 'lt';
      case Language.latvian: return 'lv';
      case Language.maori: return 'mi';
      case Language.macedonian: return 'mk';
      case Language.malayalam: return 'ml';
      case Language.mongolian: return 'mn';
      case Language.marathi: return 'mr';
      case Language.malay: return 'ms';
      case Language.maltese: return 'mt';
      case Language.burmese: return 'my';
      case Language.dutch: return 'nl';
      case Language.norwegian: return 'no';
      case Language.norfuk: return 'pih';
      case Language.piapoco: return 'piy';
      case Language.polish: return 'pl';
      case Language.portuguese: return 'pt';
      case Language.romanian: return 'ro';
      case Language.kriol: return 'rop';
      case Language.russian: return 'ru';
      case Language.slovak: return 'sk';
      case Language.slovenian: return 'sl';
      case Language.samoan: return 'sm';
      case Language.albanian: return 'sq';
      case Language.serbian: return 'sr';
      case Language.swedish: return 'sv';
      case Language.tamil: return 'ta';
      case Language.telugu: return 'te';
      case Language.tetum: return 'tet';
      case Language.thai: return 'th';
      case Language.klingon: return 'tlh';
      case Language.tongan: return 'to';
      case Language.turkish: return 'tr';
      case Language.ukrainian: return 'uk';
      case Language.uzbek: return 'uz';
      case Language.vietnamese: return 'vi';
      case Language.yiddish: return 'yid';
      case Language.chinese: return 'zh';
      case Language.zulu: return 'zu';
      case Language.all: return '';
    }
  }
}

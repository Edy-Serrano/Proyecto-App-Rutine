class QuotesRepository {
  static const List<String> quotes = [
    "Hablar no es un acto de guerra, es un puente de conexión. Cruza con confianza.",
    "El miedo al público desaparece cuando dejas de intentar impresionarlos y empiezas a intentar servirles.",
    "La asertividad no es hablar más fuerte, es hablar más claro.",
    "Un mar en calma no hace marineros expertos. Acepta los nervios como tu entrenamiento.",
    "Nadie te juzga tan duro como te juzgas a ti mismo. Suelta el látigo.",
    "La timidez es un muro de papel. Un solo paso firme y lo atraviesas.",
    "Tu voz importa. Si no la alzas, el mundo se pierde tu perspectiva.",
    "La paz mental no es la ausencia de problemas, es la capacidad de mantener la calma en medio de ellos.",
    "No puedes controlar lo que otros piensan, pero puedes controlar cómo respondes.",
    "La disciplina pesa onzas, el arrepentimiento pesa toneladas.",
    "El coraje no es la ausencia de miedo, es actuar a pesar de él.",
    "Si te equivocas al hablar, sonríe. La vulnerabilidad conecta más que la perfección.",
    "Cada vez que hablas en público, estás entrenando a tu cerebro para ser libre.",
    "El sufrimiento surge del apego. Suelta el resultado y enfócate en el proceso.",
    "Tu respiración es tu ancla. Si te pierdes en los nervios, vuelve a ella.",
    "Comunicar tus límites es un acto de amor propio.",
    "No pidas disculpas por ocupar espacio o por tener una opinión.",
    "La disciplina es el puente entre tus metas y tus logros.",
    "El verdadero poder reside en una mente tranquila.",
    "Observa tus pensamientos de ansiedad como nubes en el cielo: vienen y se van.",
    "El que domina a otros es fuerte; el que se domina a sí mismo es poderoso.",
    "La asertividad es el punto medio entre la agresividad y la sumisión.",
    "Habla con la intención de ser entendido, no con la necesidad de ser validado.",
    "Si el público está ahí, es porque quieren escucharte. Ya están de tu lado.",
    "Tu valía no se mide por la fluidez de tus palabras, sino por la sinceridad de tu mensaje.",
    "La paz viene de adentro. No la busques afuera.",
    "Cada pequeño paso hacia el escenario es una victoria contra la timidez.",
    "No busques la ausencia del miedo, busca la presencia del valor.",
    "El miedo es solo energía que no ha encontrado su propósito.",
    "Ser asertivo significa respetar los derechos de los demás tanto como los tuyos.",
    "La mente es todo. Lo que pienses, llegarás a ser.",
    "Haz las paces con el peor escenario posible, y el miedo desaparecerá.",
    "La práctica constante vence al talento natural.",
    "No importa cuán lento vayas, siempre y cuando no te detengas.",
    "La ansiedad de anticipación siempre es peor que la realidad del momento.",
    "Las palabras amables pueden ser cortas y fáciles de decir, pero sus ecos son infinitos.",
    "Para ser interesante, sé interesado. Escuchar es el 50% de la buena comunicación.",
    "La disciplina es elegir entre lo que quieres ahora y lo que quieres más.",
    "Acepta lo que es, deja ir lo que fue, ten fe en lo que será.",
    "El crecimiento comienza donde termina tu zona de confort.",
    "No te preocupes por equivocarte; preocúpate por las oportunidades que pierdes al no intentarlo.",
    "La verdadera libertad es no tener que depender de la aprobación externa.",
    "Respira hondo. Estás seguro, estás preparado, eres capaz.",
    "El silencio también es una forma de comunicación asertiva.",
    "Nadie recuerda tus errores tanto como tú. Relájate.",
    "La timidez es un escudo que ya no necesitas llevar.",
    "Tus ideas tienen valor. Permíteles ver la luz.",
    "El autocontrol es la mayor de las fortalezas.",
    "La paz interior empieza en el momento en que eliges no permitir que otra persona o evento controle tus emociones.",
    "Cada oportunidad para hablar es un regalo para compartir, no una prueba para pasar."
  ];

  static String getDailyQuote() {
    final now = DateTime.now();
    // Obtener el día del año (1 a 366)
    final dayOfYear = int.parse(now.difference(DateTime(now.year, 1, 1)).inDays.toString()) + 1;
    
    // Usar el operador módulo para evitar desbordamientos, soporta años bisiestos automáticamente
    final index = dayOfYear % quotes.length;
    return quotes[index];
  }
}

class Challenge {
  final int id;
  final String text;
  final int level;

  const Challenge({required this.id, required this.text, required this.level});
}

class ChallengeRepository {
  static const List<Challenge> allChallenges = [
    // Nivel 1: Leves (Sonrisas, saludos básicos, amabilidad pasiva)
    Challenge(id: 1, text: "Regálale una sonrisa sincera a un desconocido en la calle.", level: 1),
    Challenge(id: 2, text: "Hazle un cumplido honesto a un compañero o familiar.", level: 1),
    Challenge(id: 3, text: "Saluda con un 'buenos días/tardes' fuerte y claro al entrar a un lugar público.", level: 1),
    Challenge(id: 4, text: "Mantén contacto visual por 3 segundos extra con el cajero o vendedor.", level: 1),
    Challenge(id: 5, text: "Da las gracias a alguien por algo pequeño que dio por sentado.", level: 1),
    Challenge(id: 6, text: "Deja que alguien pase delante de ti en una fila y sonríele.", level: 1),
    Challenge(id: 7, text: "Sostén la puerta para la persona que viene detrás de ti.", level: 1),
    Challenge(id: 8, text: "Envía un mensaje de texto deseando buen día a un amigo.", level: 1),
    Challenge(id: 9, text: "Saluda a un vecino con el que normalmente solo cruzas miradas.", level: 1),
    Challenge(id: 10, text: "Deja una nota adhesiva con un mensaje positivo en un lugar público.", level: 1),
    Challenge(id: 11, text: "Camina con la cabeza en alto y los hombros atrás por al menos 10 minutos.", level: 1),
    Challenge(id: 12, text: "Responde '¡Muy bien, gracias!' con entusiasmo cuando te pregunten cómo estás.", level: 1),
    Challenge(id: 13, text: "Usa ropa de un color que normalmente no usas por temor a llamar la atención.", level: 1),
    Challenge(id: 14, text: "Hazle una pregunta sencilla a un compañero sobre su fin de semana.", level: 1),
    Challenge(id: 15, text: "Felicita a alguien por su trabajo o esfuerzo de forma directa.", level: 1),
    Challenge(id: 16, text: "Hazle un favor no solicitado a un amigo o familiar.", level: 1),
    Challenge(id: 17, text: "Escucha a alguien sin interrumpir durante 5 minutos seguidos.", level: 1),
    Challenge(id: 18, text: "Dale propina o un pequeño obsequio a alguien que te brinde un servicio.", level: 1),
    Challenge(id: 19, text: "Dile 'buen provecho' a desconocidos en un restaurante o cafetería.", level: 1),
    Challenge(id: 20, text: "Pide ayuda para alcanzar algo en un supermercado, aunque puedas hacerlo solo.", level: 1),
    Challenge(id: 21, text: "Saluda al conductor del autobús o taxi al subir.", level: 1),
    Challenge(id: 22, text: "Escribe un comentario positivo en las redes sociales de un conocido.", level: 1),
    Challenge(id: 23, text: "Despídete usando el nombre de la persona si lo tiene en su gafete.", level: 1),
    Challenge(id: 24, text: "Cede tu asiento en el transporte público o sala de espera.", level: 1),
    Challenge(id: 25, text: "Pide perdón sinceramente si te tropiezas o interrumpes a alguien.", level: 1),
    
    // Nivel 2: Intermedios (Pequeñas interacciones, small talk)
    Challenge(id: 26, text: "Inicia una pequeña conversación de 1 minuto con el cajero o vendedor.", level: 2),
    Challenge(id: 27, text: "Pregúntale la hora a alguien en la calle aunque ya la sepas.", level: 2),
    Challenge(id: 28, text: "Pide una recomendación de comida al mesero del restaurante.", level: 2),
    Challenge(id: 29, text: "Llama por teléfono para pedir información en lugar de buscarla en internet.", level: 2),
    Challenge(id: 30, text: "Pregúntale a un extraño por una dirección.", level: 2),
    Challenge(id: 31, text: "Habla sobre el clima o un tema ligero con alguien en un elevador o fila.", level: 2),
    Challenge(id: 32, text: "Halaga una prenda de vestir (zapatos, chaqueta) de un desconocido.", level: 2),
    Challenge(id: 33, text: "Pide un descuento en una tienda pequeña o mercado (solo por practicar).", level: 2),
    Challenge(id: 34, text: "Si estás en un café, pregúntale a la persona de al lado qué está tomando/leyendo.", level: 2),
    Challenge(id: 35, text: "Escríbele un mensaje a alguien que admiras (profesor, creador) agradeciéndole.", level: 2),
    Challenge(id: 36, text: "Propón una idea menor en tu grupo de trabajo o amigos.", level: 2),
    Challenge(id: 37, text: "Tómate una selfie en un lugar público concurrido sin sentir vergüenza.", level: 2),
    Challenge(id: 38, text: "Asiste a un evento local gratuito (charla, exposición) donde no conozcas a nadie.", level: 2),
    Challenge(id: 39, text: "Si te equivocas al hablar, ríete de tu error en lugar de pedir perdón.", level: 2),
    Challenge(id: 40, text: "Deja un mensaje de voz en lugar de texto a un amigo.", level: 2),
    Challenge(id: 41, text: "Si alguien te hace un cumplido, simplemente di 'Gracias' sin justificarte.", level: 2),
    Challenge(id: 42, text: "Pregúntale a un compañero de trabajo/clase por su hobby favorito.", level: 2),
    Challenge(id: 43, text: "Hazle conversación al conductor de tu taxi o transporte.", level: 2),
    Challenge(id: 44, text: "Pide un producto en la tienda que sabes que no tienen, solo para hablar.", level: 2),
    Challenge(id: 45, text: "Sal a caminar sin auriculares y observa a tu alrededor con atención.", level: 2),
    Challenge(id: 46, text: "Llama a soporte al cliente para resolver una duda sencilla.", level: 2),
    Challenge(id: 47, text: "Pide una muestra gratis en alguna heladería o tienda.", level: 2),
    Challenge(id: 48, text: "Lee un libro o revista en voz alta durante 5 minutos para mejorar tu dicción.", level: 2),
    Challenge(id: 49, text: "Pide que te tomen una foto en un lugar turístico o público.", level: 2),
    Challenge(id: 50, text: "Únete a una conversación ya iniciada en tu grupo de amigos o trabajo.", level: 2),

    // Nivel 3: Avanzados (Exposición grupal, vulnerabilidad, opiniones fuertes)
    Challenge(id: 51, text: "Levanta la mano y da tu opinión en voz alta en tu próxima reunión o clase.", level: 3),
    Challenge(id: 52, text: "Llama por teléfono a un amigo con el que no hablas hace más de un mes.", level: 3),
    Challenge(id: 53, text: "Di 'No' firmemente a una petición que no quieres hacer, sin dar largas excusas.", level: 3),
    Challenge(id: 54, text: "Cuenta un chiste o anécdota en un grupo de al menos 3 personas.", level: 3),
    Challenge(id: 55, text: "Haz una pregunta frente a todo tu salón o equipo de trabajo.", level: 3),
    Challenge(id: 56, text: "Vístete de manera mucho más formal o llamativa de lo normal en un día común.", level: 3),
    Challenge(id: 57, text: "Admite abiertamente que no sabes sobre un tema cuando te pregunten.", level: 3),
    Challenge(id: 58, text: "Ofrece tu ayuda para coordinar o liderar una pequeña actividad grupal.", level: 3),
    Challenge(id: 59, text: "Canta una canción (aunque sea bajito) mientras caminas por la calle.", level: 3),
    Challenge(id: 60, text: "Comparte en redes sociales una opinión sincera sobre un tema, no un simple meme.", level: 3),
    Challenge(id: 61, text: "Devuelve tu comida en un restaurante si no está como la pediste (educadamente).", level: 3),
    Challenge(id: 62, text: "Únete a un grupo, club o clase de prueba (ej. baile, oratoria) hoy o esta semana.", level: 3),
    Challenge(id: 63, text: "Ve a tomar un café o almorzar totalmente solo, sin mirar tu teléfono todo el tiempo.", level: 3),
    Challenge(id: 64, text: "Pídele feedback honesto sobre tu trabajo/actitud a tu jefe o profesor.", level: 3),
    Challenge(id: 65, text: "Defiende tu punto de vista en una conversación donde los demás opinen distinto.", level: 3),
    Challenge(id: 66, text: "Habla con alguien que consideres muy atractivo/a, solo de algo casual.", level: 3),
    Challenge(id: 67, text: "Pídele a un amigo o familiar un favor que normalmente te daría vergüenza pedir.", level: 3),
    Challenge(id: 68, text: "Haz una presentación o muestra tu trabajo a otras personas.", level: 3),
    Challenge(id: 69, text: "Invita a un conocido (no amigo cercano) a tomar un café o a estudiar/trabajar.", level: 3),
    Challenge(id: 70, text: "Da un discurso de 1 minuto frente al espejo manteniéndote la mirada.", level: 3),
    Challenge(id: 71, text: "Participa voluntariamente en la primera oportunidad que surja hoy.", level: 3),
    Challenge(id: 72, text: "Corrige respetuosamente a alguien si dice algo incorrecto sobre tu área de expertise.", level: 3),
    Challenge(id: 73, text: "Pide un aumento, una prórroga o negocia un mejor trato.", level: 3),
    Challenge(id: 74, text: "Acércate a un grupo de desconocidos en un evento y preséntate.", level: 3),
    Challenge(id: 75, text: "Cuéntale a un amigo un miedo o inseguridad tuya.", level: 3),

    // Nivel 4: Desafiantes (Pánico escénico, exposición alta, independencia extrema)
    Challenge(id: 76, text: "Ve al cine totalmente solo, compra palomitas y disfruta tu compañía.", level: 4),
    Challenge(id: 77, text: "Grábate hablando frente a la cámara por 1 minuto dando tu opinión y mándaselo a un amigo.", level: 4),
    Challenge(id: 78, text: "Acuéstate en el piso de un lugar público (parque, plaza) por 30 segundos sin importar quién vea.", level: 4),
    Challenge(id: 79, text: "Habla en un micrófono frente a una audiencia o canta en un karaoke.", level: 4),
    Challenge(id: 80, text: "Pídele a un artista callejero tocar su instrumento por 10 segundos.", level: 4),
    Challenge(id: 81, text: "Ve a un lugar de alto nivel (hotel 5 estrellas, concesionario) solo a observar y preguntar.", level: 4),
    Challenge(id: 82, text: "Ofrece un abrazo a alguien en un lugar público que lleve un cartel (o haz tu propio cartel de Abrazos Gratis).", level: 4),
    Challenge(id: 83, text: "Hazle una entrevista de 3 minutos a un desconocido en la calle sobre cómo fue su día.", level: 4),
    Challenge(id: 84, text: "Publica un video tuyo hablando en tus historias de Instagram/Facebook/TikTok.", level: 4),
    Challenge(id: 85, text: "Lidera una reunión, juego o actividad con un grupo de más de 5 personas.", level: 4),
    Challenge(id: 86, text: "Negocia el precio de algo que no suele ser negociable (ej. un café).", level: 4),
    Challenge(id: 87, text: "Expresa tu disconformidad a un amigo sobre algo que te molestó de forma calmada y asertiva.", level: 4),
    Challenge(id: 88, text: "Llama por teléfono a la radio local para dar una opinión o pedir una canción.", level: 4),
    Challenge(id: 89, text: "Viaja a un lugar de tu ciudad que no conozcas y pasa el día solo.", level: 4),
    Challenge(id: 90, text: "Da una clase o mini taller sobre algo que domines a tus amigos o conocidos.", level: 4),
    Challenge(id: 91, text: "Baila sutilmente o tararea mientras esperas en una fila larga.", level: 4),
    Challenge(id: 92, text: "Si ves a alguien llorando o triste en público, acércate y pregúntale si necesita ayuda.", level: 4),
    Challenge(id: 93, text: "Pide hablar con el gerente de un lugar solo para felicitarlo por el servicio.", level: 4),
    Challenge(id: 94, text: "Haz una transmisión en vivo en alguna red social por 5 minutos.", level: 4),
    Challenge(id: 95, text: "Asiste a una audición, entrevista o casting de algo que no sepas hacer bien.", level: 4),
    Challenge(id: 96, text: "Interrumpe respetuosamente a alguien que acapara la conversación para dar espacio a otros.", level: 4),
    Challenge(id: 97, text: "Confiesa tus sentimientos románticos o de admiración hacia alguien.", level: 4),
    Challenge(id: 98, text: "Sal a correr o hacer ejercicio en un parque sin preocuparte por cómo te ves.", level: 4),
    Challenge(id: 99, text: "Escribe un poema o historia y publícalo bajo tu nombre real.", level: 4),
    Challenge(id: 100, text: "Haz el ridículo a propósito frente a tus amigos (caerte falsamente, cantar mal) para reírte de ti mismo.", level: 4),
  ];

  static Challenge getDailyChallenge(int dayOfYear) {
    // Retorna un reto diferente basado en el día del año
    final index = dayOfYear % allChallenges.length;
    return allChallenges[index];
  }
}

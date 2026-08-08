/// Formata segundos como `mm:ss`, ou `h:mm:ss` acima de uma hora.
String formatarDuracao(int segundos) {
  final duracao = Duration(seconds: segundos);
  final horas = duracao.inHours;
  final minutos = duracao.inMinutes.remainder(60).toString().padLeft(2, '0');
  final segs = duracao.inSeconds.remainder(60).toString().padLeft(2, '0');
  return horas > 0 ? '$horas:$minutos:$segs' : '$minutos:$segs';
}

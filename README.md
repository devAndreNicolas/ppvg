# A Roda — EDRIEL

Greybox jogável de um beat ’em up rítmico 2.5D para a faixa **Perder Pra Você Ganhar**.

## Jogar

Abra `project.godot` no Godot 4.7 e pressione **F6/F5**.

- **WASD / setas**: mover na roda.
- **J / K**: golpes e sequências de combo.
- **L** ou **Shift**: esquiva.
- **U**: Pausa — 4 notas; atordoa rivais próximos.
- **I**: Grave — 6 notas; dano triplo por 4 segundos.
- **O**: Duplo — combo 15 e público 100%; duplicação por 5 segundos.
- **Espaço / Enter**: começar a apresentação.
- **Esc**: pausar a música.
- **R**: recomeçar após o fim.

Ataques funcionam a qualquer momento. Use o trilho de ritmo: acerte quando uma nota cruzar a linha dourada para ganhar `PERFECT` ou `GOOD`. As sequências `J J J`, `J J K`, `J K` e `L + J` disparam golpes próprios; o guia completo permanece visível durante a partida.

Hits no beat e rivais derrotados deixam notas musicais no chão. Colete-as para usar habilidades. O jogo nunca interrompe a faixa por derrota: o medidor de público altera a nota final.

## Estado atual

Esta etapa usa somente greybox procedural. Ainda não há sprites, cenários finais ou arte gerada. `audio/track.wav`, `assets/player/` e `assets/references/` foram preservados para a fase visual posterior.

# Perder pra Você Ganhar — EDRIEL 

Clipe jogável de R&B urbano para **Perder Pra Você Ganhar**, feito em Godot 4.7.

## Jogar

Abra `project.godot` e pressione F6/F5.

- Menu: WASD/setas navegam; Enter/Espaço confirma; Esc volta.
- Jogo: WASD/setas movem; J/K atacam; L/Shift esquivam.
- Habilidades: U Pausa, I Grave, O Duplo.
- Esc pausa jogo e música; F3 mostra o diagnóstico de desempenho.

## Sistema de UI

### Direção

R&B noturno premium: bordô, couro-preto, creme, cromo, âmbar e ciano usado somente em estados rítmicos/ativos. A assinatura é uma moldura cromada fina que pulsa de forma sutil.

### Tipografia

- **Bodoni Moda**: artista, faixa e títulos editoriais.
- **Barlow**: navegação, dados, controles e leitura de jogo.

As fontes e suas licenças OFL ficam em `assets/ui/fonts/`.

### Módulos

- `UiTheme`: tokens de cor, fontes e primitivas de painel/tecla.
- `UiNavigator`: menu principal, pausa, controles, créditos e resultado; também concentra foco e teclado.
- `ShowHud`, `AbilityBar` e `BeatRail`: leitura de combate, usando exclusivamente o tema compartilhado.

Cada tela pede estado ao módulo responsável. Ela não repete cores, fontes ou regras de foco.

### Estados e movimento

- Seleção: bordô, borda âmbar e pulso discreto.
- Pronto: cor da habilidade acesa.
- Ativo: preenchimento leve e tempo restante.
- Cooldown/bloqueio: máscara escura e informação objetiva.
- Transições e pulsos devem ser curtos; a UI nunca deve competir com a dança ou reduzir 60 FPS.

### Política de assets

A UI atual é geométrica/procedural. Sprites serão adicionados apenas quando ilustração, ícone ou ornamento não puder ser resolvido com tipografia e formas. Cache do Godot não é versionado: `.godot/` e `*.import` pertencem ao `.gitignore`.

## Fluxo

`Menu principal → Controles/Créditos → Jogo → Pausa → Resultado → Replay ou Menu`.

O trecho final remove a HUD e os inimigos; Edriel fica livre até a música terminar.

## Estado visual

O combate e cenário seguem como greybox procedural. Os assets em `assets/player/` e `assets/references/` estão preservados para a etapa de personagens, cenários e sprites.

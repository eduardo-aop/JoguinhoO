# RIFT — Arena 3×3

MVP local 3D de arena, com um jogador e cinco bots. Guerreiro melee e mago ranged, com câmera elevada e independente do personagem.

## Base atual: câmera tática

- Visão ortográfica inclinada em 60°, com campo de visão ajustável entre 16 e 30 unidades.
- Câmera acompanha suavemente, antecipa até 3 metros na direção da mira e limita o enquadramento às bordas da arena.
- WASD relativo à tela, independente da direção de ataque. O mouse move um cursor livre e o personagem se orienta para ele.
- Mira manual sem atração para o centro dos inimigos. A projeção na altura do disparo faz a trajetória passar pelo cursor. Habilidades de área seguem o ponto indicado no chão.
- Ajustes de resposta da câmera, enquadramento e volume persistidos em preferências próprias da V6.
- Um ataque por clique, dois kits de habilidades, bots, runas e rodadas de eliminação.
- Bots reconhecem campos hostis e projéteis próximos em rota de colisão, tentando sair ou esquivar com uma cadência de reação de 180–230 ms.
- Movimento com aceleração e frenagem mais responsivas, guia de alcance/linha de tiro e Espaço como atalho de mobilidade.
- Treino livre com alvos imóveis ou móveis que restauram a vida, sem zona nem limite de tempo.

Projeto editável com modelos e fontes Blender. Testado no Godot 4.7.2 Compatibility; não inclui aplicativo standalone exportado. Battlerite é a referência de jogabilidade: WASD, mira manual e leitura de ataques para desviar. Arte, personagens e regras são próprios; não é uma reprodução exata.

## Jogar

1. Importe o `project.godot` desta pasta no Godot 4.7.2.
2. Aguarde a importação dos modelos e pressione **F5**.
3. Escolha **GUERREIRO** ou **MAGO** e clique em **ENTRAR NA ARENA**.
4. Após a contagem de três segundos, elimine os três adversários. Não há renascimento durante a rodada.

No menu, **TREINO LIVRE** permite praticar os dois kits. Ative **Alvos em movimento no treino** para treinar antecipação da mira; a opção também está disponível na pausa do treino. Em Esc, **TROCAR PERSONAGEM / MODO** retorna à seleção. Na tela de resultado, você pode trocar de personagem antes da próxima rodada. O placar permanece durante a sessão, sem gravação em disco.

## Controles

| Entrada | Ação |
|---|---|
| Mouse | Cursor livre para mirar; personagem acompanha a direção |
| W / S | Move para cima / baixo em relação à tela |
| A / D | Move para esquerda / direita em relação à tela |
| Clique esquerdo | Um ataque básico por clique; segurar não repete |
| Q / E / R | Habilidades do personagem ao pressionar |
| Shift + Q/E/R/F | Prévia sem ativar; solte para fechar |
| F | Habilidade de runa, quando disponível |
| Espaço | Investida do guerreiro / Passo arcano do mago; compartilha a recarga de Q / E |
| Botão direito | Cancela a habilidade em preparação |
| Esc | Pausa e ajustes de câmera; pressione novamente para continuar |
| Tab, após morrer | Troca o aliado acompanhado |

**Habilidades:** Q/E/R/F ativam ao pressionar a tecla. Segurar ou soltar não repete a ação. **Prévia opcional:** Shift + habilidade mostra o indicador sem gastar recarga; soltar fecha a prévia sem executar. Para usar, pressione a habilidade sem Shift. Botão direito cancela a prévia e o ataque básico na fila, sem desfazer habilidades já usadas. A prévia impede o ataque básico. A pausa cancela a preparação e congela a rodada. Perder o foco da janela pausa automaticamente.

## Guerreiro

270 de vida, velocidade base de 5,6 m/s. Combate próximo, aproximação e defesa frontal.

| Ação | Efeito | Recarga / intervalo |
|---|---|---|
| Ataque básico | Corte em arco de 100°, alcance de 2,9 m, 16 de dano | 0,85 s; impacto após 0,22 s |
| Q — Investida | Avanço de 6,21 m em espaço livre, bloqueado por obstáculos | 7 s |
| E — Guarda | Reduz em 75% o dano vindo do setor frontal de 130°, por 2,5 s; movimento 30% mais lento | 9 s |
| R — Golpe sísmico | 38 de dano em raio de 3,8 m, com lentidão de 35% por 2,5 s | 20 s |

## Mago

200 de vida, velocidade base de 5,3 m/s. Distância, mobilidade e controle de área.

| Ação | Efeito | Recarga / intervalo |
|---|---|---|
| Ataque básico | Projétil, 12 de dano, alcance de 17 m | 0,9 s; lançamento após 0,14 s |
| Q — Orbe explosivo | 27 de dano em raio de 2,6 m ao colidir ou chegar a 18 m | 6 s |
| E — Passo arcano | Teleporte de até 5,5 m na direção do movimento; parado, usa a direção frontal; bloqueado por paredes e corpos | 9 s |
| R — Campo glacial | Área de raio 3,6 m por 5 s; 10 de dano/s e lentidão de 35%; alcance de colocação de 14 m | 22 s |

Campo glacial precisa de mira no chão e de caminho livre até o ponto; mirar no vazio ou atrás de cobertura invalida a execução sem consumir recarga. Pontos muito distantes são limitados ao alcance. Projéteis partem do corpo, de modo que a câmera ver além da parede não permite disparar através dela.

## Runas

Cada personagem pode manter **um bônus passivo e uma habilidade ativa simultaneamente**. Coletar outra runa substitui somente a mesma categoria.

| Categoria | Runa | Efeito |
|---|---|---|
| Bônus, 12 s | Ímpeto | +25% de velocidade |
| Bônus, 12 s | Fúria | +35% de dano |
| Bônus, 12 s | Égide | −30% de dano recebido, exceto dano ambiental |
| Ativa em F, uso único | Cura | Recupera até 65 de vida, sem ultrapassar o máximo |
| Ativa em F, uso único | Onda de choque | 24 de dano em raio de 4,2 m e lentidão de 45% por 2,5 s |

A runa ativa expira se não for usada em 25 s. Existem seis pontos simétricos: quatro de bônus nas rotas laterais e dois de habilidades no centro. Primeira leva aos 10 s; reposição dos pontos vazios a cada 24 s, com aviso de 4 s. Os pontos brilham antes do surgimento. Runas já presentes permanecem até serem coletadas. Cada par simétrico recebe o mesmo tipo, que alterna entre levas. Bots também coletam e usam runas.

## Arena, zona e resultado

Arena plana de **48 × 40 m**, quatro blocos de cobertura e rotas central e laterais. Corpos bloqueiam movimento; aliados não sofrem dano e não bloqueiam projéteis. Cobertura bloqueia ataques, explosões e campos de dano. Lentidões usam o maior valor e renovam duração, sem multiplicação.

A zona começa a fechar aos **90 s**, com aviso a partir de 80 s. Até 135 s, a área segura diminui para 5 × 5 m no centro. Fora dela, o dano cresce de 12 a 24 por segundo e ignora Guarda e Égide. O mapa mostra o limite seguro, e a área perigosa fica marcada em vermelho.

Vence quem eliminar os três rivais. Se as duas equipes forem eliminadas na mesma atualização, há empate. Aos **165 s**, uma regra de segurança resolve impasses: mais sobreviventes, depois maior soma de vida proporcional; igualdade resulta em empate. Rodadas são independentes e o placar apenas acumula resultados na sessão.

## Validação

273 verificações automáticas aprovadas em 14 scripts: combate, controle, câmera, animação, efeitos, bots, telemetria, investida e colisões. Inclui duas partidas completas de seis bots. Os testes de câmera em terceira pessoa foram substituídos por verificações da câmera tática; os resultados históricos da V5 estão em `docs/historico-v5/`.

Na janela nativa, verificados enquadramento, seleção, entrada na rodada, cursor sem captura e um ataque apontando para a direita com câmera imóvel. Movimento sustentado foi verificado via InputMap, sem teste de tecla física mantida pressionada pela ferramenta.

Após importar o projeto no editor:

```sh
python3 tools/validate.py --godot /caminho/para/Godot --output /caminho/para/logs
```

Resultados atuais em `docs/validacao-reacoes/report.json`. Os avisos do ambiente restrito sobre logs locais e certificados do macOS são separados dos erros de script. Capturas em `tests/preview.tscn` são cenários montados de inspeção visual.

Veja `docs/GUIA-DE-TESTE.md` para avaliar a sensação dos controles e `docs/ARTE-E-FONTES.md` para reconstruir os assets.

## Fontes e manutenção

- `scripts/rules.gd`: estatísticas e regras da rodada.
- `scripts/fighter.gd`: movimento, ataques, habilidades e estado do personagem.
- `scripts/bot.gd`: decisões locais e navegação dos bots.
- `scripts/arena.gd`: cenário, rodadas, runas, zona e resultados.
- `scripts/animation_controller.gd`: mistura de animações e acessórios presos aos ossos.
- `scripts/appearance.gd` e `shaders/`: materiais, pintura e tecido.
- `scripts/hud.gd`, `camera_rig.gd` e `minimap.gd`: apresentação e câmera.
- `tools/make_audio.py` e `tools/make_skill_audio.py`: geração dos sons originais.

Os modelos usados são `assets/warrior_animated.glb` e `assets/mage_animated.glb`. As fontes mais recentes são `blender/warrior_final.blend` e `blender/mage_final.blend`. Para reconstruir a arte, preserve a ordem: `stylized_heroes.py` → `refine_attacks.py` → `paint_materials.py` → `refine_locomotion.py`. A última etapa exporta os GLBs finais; executar apenas uma etapa intermediária pode substituir a exportação com uma versão anterior. Os arquivos Blender e scripts das etapas anteriores foram preservados como fontes.

## Limitações atuais

Sem multiplayer online, progressão, névoa de guerra ou catálogo amplo de heróis. Bots tomam decisões locais e não planejam jogadas coordenadas. O placar e as estatísticas duram a sessão; apenas preferências são persistidas. Modelos, animações, áudio e balanceamento continuam sujeitos a acabamento e avaliação humana.


## Desenvolvimento com Git

Repositório principal: `git@github.com:eduardo-aop/JoguinhoO.git`.

```sh
git clone git@github.com:eduardo-aop/JoguinhoO.git
cd JoguinhoO
```

Importe `project.godot` no Godot e pressione F5. Esta pasta passa a ser a base permanente; as próximas melhorias serão commits no mesmo projeto. O histórico e eventuais tags substituem pastas duplicadas por versão. Caches são recriados automaticamente ao importar.

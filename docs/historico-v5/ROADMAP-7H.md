# RIFT — Ciclo autorizado de 7 horas

Início: 10/09/2026 22:01 BRT (11/09 01:01 UTC).
Fim: 11/09/2026 05:01 BRT (08:01 UTC).
Estabilização final: a partir de 04:01 BRT (07:01 UTC).

## Escopo aprovado
Terceira pessoa; mouse gira personagem e câmera; WASD com strafe; um ataque básico por clique; dois heróis; jogador e cinco bots; fantasia estilizada inspirada em Dota 2. Sem compras, sem multiplayer online neste ciclo. Preservar V4. Não criar subagentes sem autorização específica.

## Etapas
- [x] Diagnóstico e base: revisar código e testar os dois heróis.
- [x] Controle e câmera: giro, frenagem, obstáculos, enquadramento e ajustes persistentes.
- [x] Combate e animações: preparação, impacto e recuperação sincronizados; posturas próprias.
- [x] Efeitos e áudio: leitura de ataques, bloqueios, habilidades e perigos.
- [x] Arte: materiais, luz, silhuetas e coberturas.
- [x] Bots: distância do mago, aproximação do guerreiro, cobertura, runas e ritmo.
- [x] Estabilização: regressões, desempenho, reinícios e pacote final com evidências.

Prioridade se houver atraso: controle/combate > animação/efeitos > bots > cenário. A última hora é reservada para estabilização.

## Estado atual
Implementação e estabilização concluídas. Regressão: 195 verificações em dez scripts, aprovadas no projeto e em cópia descompactada/importada sem cache. Revisão visual principal concluída sem erros. Relatório atual: docs/VALIDACAO-FINAL.md. Nenhuma decisão bloqueante.

Código e recursos congelados; apenas documentação e conferência do ZIP final podem ser finalizadas neste fechamento. Não retomar implementação nem fazer mudanças por quantidade. O relatório ao usuário deve ser apresentado às 08:00 BRT e a automação pausada somente depois dele.

Instrução mais recente: guardar perguntas e decisões do usuário até 11/09 às 08:00 BRT. Continuar partes independentes. Registrar em DECISOES-PENDENTES.md. Implementação encerra às 05:01 BRT; automação continua silenciosa até entregar relatório às 08:00 BRT. Agendamento confirmado após o usuário autorizar novamente: uma única automação roda em horas cheias até 08:00 BRT. Encerrar implementação às 05:01; aguardar silenciosamente até 08h e então apresentar relatório/decisões e pausar a automação. Não criar outra automação nesta tarefa.

## Como executar
Godot: <local-tools>/Godot_mono.app/Contents/MacOS/Godot
Importar: --headless --editor --path outputs/arena-v5-ciclo --import
Testes: --headless --path outputs/arena-v5-ciclo --fixed-fps 60 --script tests/suite.gd (também polish.gd e input_and_stress.gd).
Ferramentas Godot e Blender podem ser descobertas em ALL_TOOLS.
Fontes Blender: blender/stylized_heroes.py e rig_and_animate.py. Blender de interface funciona; não confiar em execução background.
Os logs headless podem conter avisos de certificado macOS e escrita de log por sandbox; distinguir de falhas de script.

## Registro de trabalho
- 22:01 BRT: iniciado ciclo; preservada V4 e criada V5.

- 22:29 BRT: 125 verificações aprovadas e revisão gráfica concluída; corrigidos controles, persistência e mira.
- 22:41 BRT: usuário pediu guardar decisões até 08h; perguntas adiadas no acompanhamento existente; tentativa de agendar relatório às 08h recusada pela ferramenta.

- 22:44 BRT: usuário autorizou novamente o agendamento; atualização concluída com sucesso.
- 22:43 BRT: curvas dos ataques reexportadas de Blender por blender/refine_attacks.py; fontes warrior_combat.blend e mage_combat.blend. Validação visual em andamento.

- 22:48 BRT: ataque refeito em Blender e validado com tests/attack_timing.gd (6 verificações). Pico de extensão guerreiro 0,233 s vs impacto 0,22 s; mago 0,167 s vs lançamento 0,14 s, dentro de um quadro de animação a 30 fps. Retorno à pose validado. Scripts e GLBs finais importados.
- Animação em movimento foi validada por polish (26) na primeira exportação de ataque; após ajuste final pequeno do follow-through, timing (6) passou. Não repetir todos os testes sem nova mudança justificável; estabilização final ainda prevista.
- Capturas de ataque em outputs/v5-warrior-impact.png e v5-mage-impact.png correspondem à primeira exportação, anterior ao ajuste pequeno do follow-through. Refazer na entrega final.

## Próxima execução
Continuar combate/animações e efeitos: revisar posturas próprias, evitar sobreposição que esconda o ataque e dar leitura visual clara ao instante do golpe/lançamento. Melhorar habilidades com efeitos distintos sem mudar regras. Em seguida arte e bots. Não refazer cópia do projeto ou agendamento. O agendamento foi autorizado novamente e atualizado com sucesso para relatório às 08h.

## Atualização de 23:40 BRT
- Efeitos distintos de corte, cura, teleporte, explosão e choque implementados em combat_fx.gd; limite de 48 efeitos e expiração verificada. Campo glacial com dez marcadores de gelo.
- Seis sons novos originais em tools/make_skill_audio.py (dash, seismic, orb, blink, frost, bolt).
- Reações a dano não encobrem ataques, têm intervalo e são canceladas ao iniciar nova ação. Guarda anima só o braço esquerdo, preservando o ataque do direito. tests/effects.gd: 15 verificações passaram.
- Bots priorizam inimigos visíveis, recuam para pontos navegáveis e seguros, usam defesa antes da ofensiva em perigo próximo, evitam sobreposição com aliados e giram gradualmente antes de atacar. tests/tactics.gd: 7 passaram. Oito partidas com bots e input via tests/input_and_stress.gd: 25 passaram após ajustes.
- Decoração agrupada com MultiMesh. Comparação controlada estática em docs/RENDER-COMPARISON-V5.json: 944 → 422 chamadas medianas; mediana de quadro 12,5 → 8,33 ms nesta máquina. É cena estática, não garantia de desempenho em toda partida. Amostras dinâmicas anteriores estão separadas e não devem ser tratadas como comparação controlada.
- Modelos com pintura por vértices em blender/paint_materials.py; fontes *_painted.blend. Godot exige vertex_color_use_as_albedo ativado nas superfícies para mostrar essa pintura; já aplicado em fighter.gd. Piso com juntas antialias e ruínas com material de pedra.
- HUD com cartões e barras de recarga, destaque de preparação e liberação de ações de movimento ao pausar. tests/control.gd tem agora 12 verificações, todas passaram. Input.release_pressed_events NÃO existe nesta versão; corrigido com Input.action_release nas quatro ações de movimento. Não reintroduzir chamada inválida.
- A tentativa de teste nativo via CUA retornou timeout ao acessar Godot por nome e caminho; foram usados testes de entrada no engine e revisão gráfica via plugin Godot. Não alegar teste manual completo de teclado nativo.
- Revisão de cinco telas atualizada sem erro no depurador.

## Próximas ações prioritárias
Rever o estado em jogo, cobrir regressões materiais/animação com polish e attack_timing, consolidar README/relatórios sem contar testes repetidos como novos. Melhorar somente problemas concretos identificados no tempo restante. Preparar pacote apenas após estabilização. Ainda não é entrega final; nenhuma decisão do usuário necessária até aqui.

## Atualização por volta de 00:00 BRT
- Locomoção refinada no Blender com ciclos de 0,6 s e posturas distintas; passos ajustados a 0,3 s. Fontes finais em *_final.blend. Pipeline: stylized_heroes.py → refine_attacks.py → paint_materials.py → refine_locomotion.py. Cada script lê a etapa anterior; o último exporta GLBs usados no jogo.
- Cabeça acompanha a mira via SkeletonModifier3D (head_aim.gd). Aplicar rotação diretamente no Skeleton acumulava inclinação; foi removido. Modifier usa constante MODIFIER_CALLBACK_MODE_PROCESS_IDLE para compatibilidade entre executáveis. tests/polish.gd: 30 verificações passaram, incluindo não acumular rotação.
- Prévia de trajetória para mobilidade/orbe e aviso de trajeto bloqueado adicionados. Não alterado consumo de habilidade bloqueada.
- Manto tem movimento sutil por shader; sem simulação de tecido física.
- Cores de vértice GLTF são lineares. Renderizador Compatibility requer conversão para saída sRGB em painted_hero.gdshader e cloth.gdshader via OUTPUT_IS_SRGB. Código central em appearance.gd. Referência oficial: https://docs.godotengine.org/en/4.5/classes/class_basematerial3d.html (vertex_color_is_srgb não tem efeito no Compatibility). Revisão gráfica confirmou paleta correta; não voltar à solução anterior escura.
- Telemetria de dano efetivo, eliminações, runas e habilidades; resumo pessoal no resultado. tests/telemetry.gd: 7 passaram (inclui não contar overkill nem kill repetida).
- 32 partidas em 16 pares espelhados: 17 vitórias azuis/15 corais, duração mediana 47,4 s. Separar por composição: escolha guerreiro 3/16 vitórias azuis; escolha mago 14/16. Não alegar equilíbrio só pelo agregado! É teste com bots, antes da correção final da distância da investida; manter valores de heróis até avaliação mais confiável.
- Teste nativo CUA conseguiu funcionar após eliminar erro de compilação que travava a janela. Menu, entrada em rodada, Q, clique único e pausa confirmados. Um toque muito curto em W não gerou deslocamento observável; não alegar validação nativa de WASD mantido (API não oferece hold). Movimento WASD foi validado pelo InputMap nos testes automáticos.
- Investida corrigida de ~6,516 m para 6,21 m: último passo usa fração restante da duração. tests/dash_timing.gd: 6 passaram, com 30/60/120 ticks. Teste nativo confirmou 6,210 m; snapshot em docs/NATIVE-INPUT-V5.json, com versão anterior arquivada.
- Prévia 3D do herói no menu; renderização desativada durante a partida. HUD inicial sem cartões vazios. tests/control.gd agora tem 14 verificações, todas passaram. Nenhum aviso no último preview após correções, mas há mudanças posteriores de rastro de projétil que ainda precisam de revisão gráfica.
- Rastro curto nos projéteis e cor própria do orbe; física de colisão não foi alterada.

## Próximo bloco
Validar rastro e prévia após últimas mudanças. Consolidar relatórios e documentação e procurar defeitos concretos de partida completa, reinício, foco e desempenho. Revalidar suíte de regressão após mudanças centrais de dash/telemetria. Não contar execuções repetidas como novos testes. Guardar decisões para 08h; não interromper trabalho por perguntas opcionais. Prazo de implementação 05:01 BRT e estabilização a partir de 04:01.

## Atualização de 00:14 BRT
- Criado tools/validate.py: executa nove scripts, preserva logs e rejeita erro de script, timeout, marcador ausente ou saída anormal. Execução conjunta: 176 verificações sem falhas; avisos de sandbox/certificados identificados separadamente.
- Rastro de projétil e campo glacial revistos em tests/effects_preview.tscn; captura outputs/v5-ciclo-efeitos.png. Cores de equipe reforçadas em tecidos e escudo. Não mudou física ou dano.
- Corrigida corrida em falso dos sobreviventes no resultado: blend retorna ao repouso mesmo com arena inativa. effects.gd agora tem 17 verificações, passou.
- Auditoria de navegação: 12 partidas, seeds 3700–3711. Antes, dois magos aliados bloquearam um ao outro por pelo menos 1,5 s; depois do desvio lateral para a direita, zero eventos usando o mesmo critério. JSONs antes/depois preservados. tactics.gd agora tem oito verificações, incluindo passagem frontal entre aliados; passou.
- Corrigido corpo oculto após morte quando a câmera estava muito próxima: cycle_spectator restaura o modelo do ator anterior, incluindo o jogador. suite.gd agora tem 67 verificações; passou.
- Durante os três segundos iniciais, mouse pode orientar câmera/personagem; movimento e combate continuam bloqueados. input_and_stress.gd tem 26 verificações, passou. Captura de mouse não funciona no DisplayServer headless: não forçar teste de giro nesse modo. tests/countdown_preview.tscn validou giro com janela real: COUNTDOWN_LOOK_COMPLETE passed=true mouse_mode=2, sem erros no depurador.
- README reescrito para V5, fontes finais e limitações reais. Não é ainda relatório final. Nenhuma decisão bloqueante do usuário.
- Diretório de export_templates do Godot existe mas está vazio; pacote do projeto continua viável. Não alegar aplicativo standalone exportado.

## Checkpoint de 00:33 BRT
- 181 verificações passaram juntas e novamente em uma cópia limpa extraída do pacote de teste, sem cache `.godot`. Logs atuais em docs/validacao-0030 e síntese docs/VALIDACAO-V5.md. Não somar repetições.
- tools/package.py cria ZIP com manifesto SHA-256 e verifica integridade; inclui blender/.gdignore (essencial para não importar fontes .blend automaticamente) e exclui caches/backups. Pacote de teste em work/arena-v5-review.zip, extração em work/v5-clean-check. Ainda não é pacote final em outputs.
- Doze rodadas reais com gráficos e áudio concluídas em 627,3 s: limpeza correta, zero nós órfãos, contagem de nós estável por herói. docs/SOAK-V5.json e .log preservados. Teste anterior à inclusão das armas na prévia; não interpretar contagens de nós como universais para revisões posteriores. Não repetir teste longo sem nova preocupação concreta.
- Menus revistos a 1280×720 e 1024×768. O primeiro ensaio revelou letterboxing (viewport continuava 16:10); project.godot agora usa window/stretch/aspect="expand", com capturas confirmadas nas dimensões reais e controles dentro dos limites.
- Armas/escudo e cores na prévia agora correspondem ao personagem. Geometria e anexação aos ossos compartilhadas em appearance.gd para evitar divergência. polish e control passaram após a mudança.
- Ao morrer, cabeça deixa de seguir a última mira e tecido desativa intensidade de corrida. Efeito plano de corte preserva material de duas faces; revisão gráfica em outputs/v5-ciclo-corte.png.
- Campos de estatísticas antigos e sem uso foram removidos de settings.gd; valores dos heróis continuam em rules.gd, sem alteração numérica.
- Docs de reconstrução em docs/ARTE-E-FONTES.md e roteiro de revisão humana em docs/GUIA-DE-TESTE.md. Nenhuma decisão bloqueante.
- Janela gráfica restaurada para scenes/arena.tscn, seleção interativa normal (não deixar fixture de teste aberta para jogar). Próximas revisões devem evitar alterações por quantidade; focar problemas concretos e preparar pacote final na estabilização. Prazo de implementação e relatório às 08h permanecem os mesmos.

## Atualização de 00:37 BRT
- Corrigida leitura das barras de vida em ângulos laterais. Antes, os cubos giravam com o personagem e ficavam quase invisíveis a 90°. Materiais agora usam billboard, preservam a escala proporcional de HP, são não iluminados e não projetam sombras. Teste gráfico com três rotações confirmou largura e proporção legíveis, sem erros.
- Evidências antes/depois: outputs/v5-barras-de-vida-antes.png e outputs/v5-barras-de-vida.png; cena tests/nameplate_preview.tscn. Não adicionados testes redundantes por ser ajuste visual; 181 continua a contagem da última regressão completa, anterior a este ajuste de material.
- O ZIP de teste em work está anterior a esta mudança; reconstruir no empacotamento final. Nenhuma decisão necessária. Restaurar/usar scenes/arena.tscn para jogar.

## Atualização de 01:05 BRT
- clear_round agora cancela a contagem inicial; antes uma limpeza durante a contagem podia reativar uma arena vazia quando o temporizador terminasse. Reinício também restaura cor e escala neutras dos marcadores de runas, evitando aviso da rodada anterior durante os três segundos iniciais.
- Controle: 17 verificações passaram, incluindo três novas para esses estados. Evidência em docs/controle-reinicio-0104.log.
- Fim da rodada oculta indicadores de guarda e ataque, que podiam permanecer congelados sobre o chão enquanto as animações dos sobreviventes voltavam ao repouso. Efeitos: 18 verificações passaram, incluindo uma nova para o encerramento. Evidência em docs/efeitos-resultado-0104.log.
- A suíte tem agora 185 verificações ao todo; a última execução conjunta de 181 é anterior às quatro adições. Reunir execução final na estabilização, sem somar repetições. Nenhum dano, vida, recarga ou regra central alterado. Nenhuma decisão necessária.

## Atualização de 02:05 BRT
- Diagnóstico de acerto: raios na altura de 2,02 m atravessavam a parte superior da cabeça dos dois modelos atuais. Dois casos falharam antes da correção; log em docs/hitbox-diagnostico-antes.log.
- Cápsula alinhada à cabeça, com altura 2,10 m (antes 1,95 m) e base no chão. Raio horizontal permanece 0,44 m; pontas de coroa/capuz e armas continuam fora da cápsula. Não alterados dano, vida, recargas, alcance de ataque ou composição.
- Adicionado tests/hitbox.gd com oito verificações, incluído no executor. Regressão conjunta aprovada: 193 verificações em dez scripts, incluindo controle 17 e efeitos 18. Logs em docs/validacao-0205.
- A cópia limpa validada anteriormente é anterior às correções de reinício e cápsula; reempacotar e validar pacote final na estabilização. Nenhuma decisão do usuário necessária.

## Atualização de 03:05 BRT
- Corrigido volume que só afetava sons novos. Efeitos agora usam um barramento RiftEffects; alterações de settings.effects_volume emitem sinal e atualizam ganho/mute também para vozes existentes, inclusive com a árvore pausada. Ganhos relativos dos sons preservados. Barramento é criado apenas uma vez por processo.
- Controle passou com 19 verificações (duas novas de mute/volume durante pausa), log docs/controle-audio-0305.log. Total da suíte: 195; última regressão conjunta de 193 anterior a estas duas adições.
- Teste gráfico tests/audio_volume_preview.tscn confirmou reprodução ativa no barramento, mute durante pausa e ganho da voz existente atualizado. docs/AUDIO-VOLUME-V5.json passou. O primeiro ensaio iniciou som antes de estabilizar a janela; a fixture agora aguarda oito frames antes de iniciar áudio. Não foi necessário mudar a inicialização normal do jogo, que tem contagem inicial.
- Preferências originais restauradas no teste e não salvas. Nenhuma mudança de regras ou decisão bloqueante.
- Próximo despertar (07:02 UTC / 04:02 BRT) é exclusivamente estabilização: regressão dos dez scripts/195 verificações, revisão visual final, pacote em outputs/arena-v5-ciclo.zip e teste de importação desse pacote sem cache. Limite de implementação 08:01 UTC; após isso aguardar silenciosamente o relatório das 08h BRT.

## Estabilização final — 04:08 BRT
- 195 verificações aprovadas no projeto e em cópia descompactada sem cache. Esta última foi importada pelo executável Godot 4.7.2 sem .NET, o mesmo da revisão gráfica. Logs em docs/validacao-final e docs/importacao-final.log.
- Cinco telas principais novamente revisadas sem erros no depurador. Capturas outputs/v5-ciclo-*.png atualizadas.
- Fontes e recursos congelados. ZIP final destinado a outputs/arena-v5-ciclo.zip; sua integridade e igualdade de código/recursos com o candidato testado serão registradas em outputs/VERIFICACAO-PACOTE-V5.json. Relatório de entrega em outputs/RELATORIO-FINAL-V5.md.
- Nenhuma decisão bloqueante. Aguardar relatório das 08h BRT; não pausar automação antes disso.

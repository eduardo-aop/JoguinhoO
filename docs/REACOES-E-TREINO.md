# Reações dos bots e treino de mira

Os bots avaliam perigos a cada 180–230 ms e mantêm a direção de esquiva por 250 ms para reduzir oscilações. Ignoram projéteis aliados, os que se afastam e trajetórias que não ameaçam seu corpo. As opções de fuga respeitam coberturas, limites e zona. Campos hostis geram tentativa de saída; não há invulnerabilidade ou garantia de esquiva. Essas regras tornam a movimentação mais variada, mas não demonstram balanceamento entre classes.

No treino, alvos móveis percorrem faixas laterais curtas e previsíveis. Podem ser parados no menu de pausa; não usam a IA de combate. A animação acompanha a velocidade da faixa. A opção não altera os bots de partidas normais.

A mobilidade do mago agora consulta WASD no próprio evento da tecla: direção e Espaço simultâneos não dependem de uma atualização física anterior. Habilidades indisponíveis explicam recarga, ação em andamento ou falta de runa.

273 verificações aprovadas em 14 scripts, incluindo uma esquiva física de um projétil real, com movimento lateral e vida preservada. Resultados em validacao-reacoes/. A inspeção gráfica do treino e da pausa confirmou a opção de alvos móveis. Quatro partidas gráficas consecutivas concluídas em 231,8 s, com limpeza correta de atores, efeitos e áudio em todas as rodadas e zero nós órfãos após a limpeza. Dados em validacao-reacoes/endurance.json. São partidas de bots no equipamento local, não comprovação de balanceamento ou FPS em outros computadores.

Interface verificada graficamente em 1280×720 e 1024×768: seleção, opções de treino, HUD e minimapa dentro da janela, sem erros de script.

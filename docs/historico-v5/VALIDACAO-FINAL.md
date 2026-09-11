# Validação final — RIFT V5

Estabilização de 11/09/2026, concluída antes do limite de 05:01 BRT. A divulgação do relatório permanece reservada para 08:00 BRT.

## Resultado

**195 verificações aprovadas em dez scripts**, tanto no projeto de trabalho quanto em uma cópia descompactada sem cache `.godot`. A cópia foi importada no Godot 4.7.2 antes dos testes. Os resultados completos estão em `validacao-final/`; repetições não aumentam a contagem.

| Script | Verificações |
|---|---:|
| suite | 67 |
| input_and_stress | 26 |
| polish | 30 |
| control | 19 |
| attack_timing | 6 |
| effects | 18 |
| tactics | 8 |
| telemetry | 7 |
| dash_timing | 6 |
| hitbox | 8 |

A suíte cobre rodadas completas, reinício, pausa, regras de combate, runas, colisões, animação, câmera, volume, estatísticas e os dois heróis. A importação headless gerou avisos de permissão para caches e configurações globais do editor, e de certificados do macOS. Os recursos foram importados e os testes terminaram sem erros de script ou erros inesperados de execução. Esses avisos estão preservados no log de importação.

## Gráficos, áudio e entrada

Revisão de seleção, guerreiro, mago, zona e resultado sem erros no depurador. Menu e HUD inspecionados em 1280×720 e 1024×768; a janela usa toda a área disponível. As capturas são cenas preparadas para inspeção, não resultados de partidas humanas.

Durante o ciclo, doze partidas com gráficos e áudio ativos concluíram em 627,3 segundos. A limpeza passou em todas, sem nós órfãos; dados em `SOAK-V5.json` e `SOAK-V5.log`. Esse teste ocorreu antes de refinamentos posteriores da prévia, colisão e áudio, que têm verificações próprias. Não é uma prova de ausência de todo tipo de vazamento.

O teste gráfico de volume confirmou uma voz ativa, mute durante a pausa e atualização do ganho, conforme `AUDIO-VOLUME-V5.json`. A câmera durante a contagem foi validada com janela gráfica. O teste nativo anterior confirmou seleção, início, ataque, investida e pausa. Movimento sustentado foi coberto pelo InputMap; não foi testado com uma tecla física mantida pela ferramenta de interação.

## Desempenho e balanceamento

A comparação estática controlada registrou redução de 944 para 422 chamadas medianas de desenho ao agrupar decoração. Consulte `RENDER-COMPARISON-V5.json` para condições e tempos. Não representa garantia de FPS em partidas.

Uma auditoria de doze partidas identificou bloqueio prolongado entre aliados; após a correção de desvio lateral, não houve eventos pelo mesmo critério. Dados antes/depois em `NAVIGATION-AUDIT-V5*.json`.

As 32 partidas exploratórias de balanceamento são anteriores a refinamentos finais. O agregado 17×15 esconde uma diferença por composição; não foi usado para declarar os heróis equilibrados. Consulte `OBSERVACOES-DE-BALANCEAMENTO.md`.

## Entrega e limites

O pacote contém projeto Godot, scripts, fontes Blender, modelos GLB, sons e documentação. O manifesto SHA-256 permite conferir os arquivos. Caches gerados e backups Blender ficam de fora; `blender/.gdignore` é preservado. O código e os recursos de execução do ZIP final são conferidos contra a versão descompactada testada; somente documentação e relatórios são acrescentados depois dessa execução.

Requer Godot 4.7.2 para abrir e jogar. Não foi produzido aplicativo standalone: os templates de exportação não estão instalados. Mantidos o escopo local, dois heróis, terceira pessoa e um jogador com cinco bots. Multiplayer online, catálogo ampliado, acabamento artístico de lançamento e validação humana de balanceamento continuam fora desta entrega.

Nenhuma decisão bloqueante do usuário permanece para a entrega.

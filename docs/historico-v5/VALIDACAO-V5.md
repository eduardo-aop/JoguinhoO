> Histórico de checkpoints. O relatório atual está em `VALIDACAO-FINAL.md`.

# Validação da V5 — checkpoint de 11/09, 00:30 BRT

O ciclo noturno ainda está em andamento. Este documento registra o checkpoint atual; os relatórios de versões anteriores são históricos.

## Regressão

**181 verificações aprovadas**, em nove scripts: suite 67, input_and_stress 26, polish 30, control 14, attack_timing 6, effects 17, tactics 8, telemetry 7 e dash_timing 6. A contagem não soma execuções repetidas.

A execução foi feita também em uma cópia descompactada sem o diretório `.godot`, após importar os recursos. O manifesto conferiu a integridade dos 177 arquivos desse pacote de teste. Relatório e logs completos em `validacao-0030/`; o pacote final ainda será montado na estabilização.

O editor headless teve avisos de permissões para caches, configurações e comunicação .NET, além do aviso de certificados do macOS. A importação dos recursos terminou e os testes passaram; esses avisos do ambiente não foram apresentados como erros de jogabilidade. O executor rejeita erros de script e outros erros inesperados.

## Partidas com gráficos e áudio

Doze rodadas com bots, em tempo real, concluídas em **627.3 segundos**. Todas liberaram personagens, efeitos e streams de áudio ao reiniciar. Nenhum nó órfão foi registrado; o número de nós após a limpeza retornou a 182 na seleção do guerreiro e 181 na do mago.

Memória estática observada após limpeza: 45.61–45.83 MB. Pico de 13 vozes tocando simultaneamente, abaixo do limite de 18; pico de 12 efeitos transitórios, abaixo de 48. É uma observação nesta máquina, sem prova de ausência de todo tipo de vazamento. O teste ocorreu antes de adicionar armas à prévia de seleção; as regras de combate eram as mesmas.

Evidências: `SOAK-V5.json` e `SOAK-V5.log`. O diagnóstico retoma automaticamente após perda de foco; o jogo normal continua pausando nessa situação.

## Revisão gráfica e entrada

- Menu e HUD revistos em janelas 1280×720 e 1024×768, agora ocupando toda a área, com controles principais dentro dos limites.
- Prévia dos dois heróis com armas e cores corretas. Corte, projétil, orbe e campo glacial inspecionados.
- Giro durante a contagem inicial validado com janela gráfica e mouse capturado: `COUNTDOWN_LOOK_COMPLETE passed=true`. Movimento e ataques continuam bloqueados até o início.
- Teste nativo anterior confirmou seleção, início, ataque, investida e pausa. A investida percorreu 6,21 m. Não foi realizada validação nativa de uma tecla de movimento mantida pressionada; esse movimento foi coberto pelo InputMap.

## Navegação e desempenho

A auditoria de doze partidas identificou dois eventos de bloqueio prolongado entre aliados. Após o desvio lateral, os mesmos cenários terminaram sem eventos pelo critério de menos de 0,35 m de progresso durante 1,5 s com intenção de movimento. Dados em `NAVIGATION-AUDIT-V5-ANTES.json` e `NAVIGATION-AUDIT-V5.json`.

A comparação de desenho da cena estática está em `RENDER-COMPARISON-V5.json`. A análise exploratória de composições está em `OBSERVACOES-DE-BALANCEAMENTO.md`. Não usar esses dados como garantia de FPS nem como prova de equilíbrio para jogadores humanos.

## Ajuste visual posterior, 00:37 BRT

Barras de vida passaram a enfrentar a câmera em qualquer orientação do personagem, mantendo escala proporcional e teste de profundidade. Inspeção gráfica de três orientações em `tests/nameplate_preview.tscn` sem erros. Esta revisão de material é posterior à execução das 181 verificações; a contagem não foi ampliada.

## Estados de reinício e resultado, 01:05 BRT

A limpeza da rodada agora cancela uma contagem pendente e restaura os marcadores de runas. O resultado oculta os indicadores de ataque e guarda. As 17 verificações de controle e 18 de efeitos passaram; quatro casos foram adicionados, levando a suíte a 185 verificações previstas na próxima execução conjunta. Logs em `controle-reinicio-0104.log` e `efeitos-resultado-0104.log`.

## Regressão conjunta, 02:05 BRT

**193 verificações aprovadas em dez scripts**. A cápsula foi ajustada de 1,95 m para 2,10 m para cobrir a cabeça dos modelos atuais. O raio permanece 0,44 m; pontas decorativas e armas ficam fora da área de colisão. Os dois testes de cabeça falhavam antes do ajuste e passaram depois; os demais testes de movimento, câmera e combate também passaram. Logs completos em `validacao-0205/`. A importação limpa do pacote final ainda deve ser repetida durante a estabilização.

## Volume na pausa, 03:05 BRT

O controle de efeitos agora ajusta também sons já iniciados, por um barramento próprio. As 19 verificações de controle passaram (duas novas); o teste gráfico confirmou voz ativa, mute e atualização do ganho durante pausa, em `AUDIO-VOLUME-V5.json`. O teste aguarda a inicialização da janela antes de disparar áudio. A suíte passa a conter 195 verificações para a regressão final.

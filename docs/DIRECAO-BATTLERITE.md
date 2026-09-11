# Direção de jogabilidade

Referências oficiais: [Steam](https://store.steampowered.com/app/504370/Battlerite/) e [Stunlock](https://arena.battlerite.com/). Ambas descrevem WASD, mira por cursor, skillshots e desvio de projéteis. Esses são os princípios adotados; os números e escolhas abaixo são do nosso MVP, não estatísticas de Battlerite.

## Implementado

- Mira sem correção automática para o torso do inimigo. O cursor informa a trajetória real; alvos continuam recebendo feedback de hover.
- Aceleração 70 m/s², frenagem 90 m/s² e reversão de direção com pelo menos 100 m/s². Velocidades máximas e danos mantidos.
- Guia de alcance no guerreiro e linha de disparo do mago na altura real, interrompida por corpos inimigos ou coberturas. Cor de aviso para obstrução.
- Espaço aciona a mobilidade de cada classe, compartilhando a recarga existente. Q/E mantidos.
- Treino livre com alvos imóveis e vida restaurada ao esgotar, sem conceder eliminações nem encerrar a rodada. Dano acumulado continua registrando o dano efetivo.
- Treino não fecha a zona nem termina por tempo. Esc permite trocar classe ou voltar à arena normal; bots são restaurados na nova rodada.

## Validação

232 verificações em 12 scripts, sem falhas; inclui duas partidas completas de bots. Novas verificações cobrem resposta do movimento em 100 ms, reversão em 134 ms, mobilidade/recarga, indicadores, vida dos alvos, treino e saída para arena normal. Inspeção gráfica de seleção, treino e pausa sem erros de script. Capturas são fixtures, não prova de conforto subjetivo durante uma sessão humana.

## Decisão solicitada

Trocar habilidades direcionadas de segurar/soltar para ativar ao pressionar a tecla. A convenção anterior foi escolhida pelo usuário; por isso permanece até sua resposta. Recomendação: pressionar para acelerar o fluxo do combate. Ataque básico continua um por clique.

Após essa escolha, o próximo trabalho é ajustar preparação/cancelamento e animações de habilidades à convenção escolhida, seguido de sinais visuais de ataques adversários. Não alterar balanceamento de kits por analogia com personagens de Battlerite sem testes próprios.

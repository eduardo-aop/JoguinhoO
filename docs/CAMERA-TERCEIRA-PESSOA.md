# Câmera acima e atrás do personagem

Enquadramento baseado no pedido de referência a [Valheim](https://store.steampowered.com/app/892970/Valheim/). Mantém arena, kits, bots e ativação de habilidades ao pressionar.

Perspectiva com FOV 68°, distância inicial 6,5 m e pivô a 2,65 m. Cursor visível e livre. O movimento do mouse altera a mira e solicita uma correção suave da câmera em direção à orientação apontada, limitada a 25° por atualização de intenção. O acompanhamento suaviza a translação; WASD segue a orientação horizontal da câmera.

Colisão por esfera de 25 cm, consultada tanto na física quanto no giro da câmera. Recolhe imediatamente, retorna a 5 m/s e evita começar além da parede. Ao ficar muito perto, esconde o modelo com histerese para evitar cintilação. Ao trocar o aliado observado, reposiciona o pivô e atualiza a colisão.

O raio sob o cursor ignora o próprio corpo e aliados, mas respeita cenário e adversários. Ataques continuam saindo do corpo: enxergar o alvo por cima de uma parede não permite atravessá-la. Habilidades de chão rejeitam projeção inválida ao mirar no céu.

280 verificações aprovadas em 14 scripts. Testes de perspectiva, limites, movimento lateral, cursor livre sem recentralização, retorno suave sem órbita contínua com cursor parado, recuo/retorno após parede, pausa, espectador e habilidades substituem os testes do modo tático. Inspeção gráfica de treino, prévia/uso de área e interface em dois formatos de janela. Relatórios antigos de duração referem-se à câmera anterior e não foram refeitos nesta revisão.

Correção solicitada: o mouse continua livre tanto na partida quanto após a pausa. Retirado o controle de sensibilidade do giro, que não se aplica ao cursor livre. Validação atual em validacao-retorno-camera/.

## Retorno suave

A direção de retorno é amostrada quando o mouse se move, com amortecimento exponencial de 4/s e limite angular de 70°/s. Pequenos movimentos deixam a câmera acompanhar com atraso; ao parar o cursor, ela se acomoda na última direção solicitada. Não persegue a rotação recalculada do jogador indefinidamente: isso criaria um ciclo de câmera/mira girando sozinho com o cursor fora do centro. O cursor permanece livre. Para o espectador, acompanha a orientação do bot observado.

Novos testes verificam correção limitada, acomodação, ausência de giro contínuo, manutenção do cursor, amortecimento e passagem pelo limite de ±180°. Sensação subjetiva ainda depende do teste do jogador.

# Câmera acima e atrás do personagem

Enquadramento baseado no pedido de referência a [Valheim](https://store.steampowered.com/app/892970/Valheim/). Mantém arena, kits, bots e ativação de habilidades ao pressionar.

Perspectiva com FOV 68°, distância inicial 6,5 m e pivô a 2,65 m. Cursor visível e livre. O movimento do mouse altera a mira, mantendo o ângulo da câmera fixo. O acompanhamento suaviza a translação; WASD segue a orientação horizontal da câmera.

Colisão por esfera de 25 cm, consultada tanto na física quanto no giro da câmera. Recolhe imediatamente, retorna a 5 m/s e evita começar além da parede. Ao ficar muito perto, esconde o modelo com histerese para evitar cintilação. Ao trocar o aliado observado, reposiciona o pivô e atualiza a colisão.

O raio sob o cursor ignora o próprio corpo e aliados, mas respeita cenário e adversários. Ataques continuam saindo do corpo: enxergar o alvo por cima de uma parede não permite atravessá-la. Habilidades de chão rejeitam projeção inválida ao mirar no céu.

272 verificações aprovadas em 14 scripts. Testes de perspectiva, limites, movimento lateral, cursor livre sem recentralização, câmera estável durante o movimento do mouse, recuo/retorno após parede, pausa, espectador e habilidades substituem os testes do modo tático. Inspeção gráfica de treino, prévia/uso de área e interface em dois formatos de janela. Relatórios antigos de duração referem-se à câmera anterior e não foram refeitos nesta revisão.

Correção solicitada: o mouse continua livre tanto na partida quanto após a pausa. Retirado o controle de sensibilidade do giro, que não se aplica ao cursor livre. Validação atual em validacao-cursor-livre/.

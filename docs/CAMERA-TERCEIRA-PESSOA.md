# Câmera acima e atrás do personagem

Enquadramento baseado no pedido de referência a [Valheim](https://store.steampowered.com/app/892970/Valheim/). Mantém arena, kits, bots e ativação de habilidades ao pressionar.

Perspectiva com FOV 68°, distância inicial 6,5 m e pivô a 2,65 m. Mouse capturado gira yaw e pitch, com limites verticais de -1,05 a 0,45 rad. O acompanhamento suaviza a translação; o giro responde diretamente ao mouse. Mira central e movimento relativo ao yaw da câmera.

Colisão por esfera de 25 cm, consultada tanto na física quanto no giro da câmera. Recolhe imediatamente, retorna a 5 m/s e evita começar além da parede. Ao ficar muito perto, esconde o modelo com histerese para evitar cintilação. Ao trocar o aliado observado, reposiciona o pivô e atualiza a colisão.

O raio central ignora o próprio corpo e aliados, mas respeita cenário e adversários. Ataques continuam saindo do corpo: enxergar o alvo por cima de uma parede não permite atravessá-la. Habilidades de chão rejeitam projeção inválida ao mirar no céu.

269 verificações aprovadas em 14 scripts. Testes de perspectiva, giro, limites, movimento lateral, mira central, recuo/retorno após parede, pausa, espectador e habilidades substituem os testes do modo tático. Inspeção gráfica de treino, prévia/uso de área e interface em dois formatos de janela. Relatórios antigos de duração referem-se à câmera anterior e não foram refeitos nesta revisão.

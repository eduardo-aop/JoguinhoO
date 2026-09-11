# Ajuste de câmera e mira

A câmera mantém inclinação e rotação fixas e acompanha o personagem com suavização exponencial. O cursor acrescenta um deslocamento de até 3 metros para mostrar mais espaço na direção da mira. O deslocamento é calculado em relação ao centro da tela, evitando realimentação conforme a câmera anda. O enquadramento continua limitado à arena. Observar bots não recebe esse deslocamento.

WASD continua relativo à tela. O clique usa imediatamente a posição do evento do mouse. Para o mago, fora dos inimigos, a mira é projetada na altura de lançamento: a trajetória agora passa pelo marcador, em vez de aparecer acima dele. Sobre inimigos, a mira continua apontando para o torso. Habilidades de área mantêm a projeção no chão.

Validação: 207 verificações aprovadas em 11 scripts (validacao-mouse/), incluindo projeção do disparo no cursor, deslocamento limitado da câmera e neutralidade do cursor central. Inspeção gráfica dos cenários de guerreiro, mago, área, zona e resultado sem erros de script. A avaliação de conforto durante jogo humano continua pendente.

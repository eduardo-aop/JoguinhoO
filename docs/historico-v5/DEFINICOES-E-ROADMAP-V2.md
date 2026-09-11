# Arena 3×3 — Definições e roadmap da versão 2

Status: as seis etapas foram implementadas no projeto separado `arena-v2-completo`. As versões V1 e V2 Etapa 1 permanecem preservadas. A instrução posterior do usuário autorizou concluir todas as fases sem pausas para aprovação. Resultado: 91 verificações automatizadas aprovadas, dez partidas completas com bots e revisão gráfica. Valores de balanceamento continuam provisórios; avaliação humana não foi apresentada como concluída.

## 1. Experiência desejada

Batalhas 3D em terceira pessoa entre duas equipes de três personagens, com foco em posicionamento, cooperação e habilidades distintas para melee e ranged. Sobreviver e eliminar a equipe adversária é o objetivo. Câmera atrás do personagem, com rotação pelo mouse, como referência de perspectiva de Smite. O projeto usa Godot e modelos originais produzidos no Blender.

A primeira versão terá um jogador, dois bots aliados e três bots rivais. Elenco amplo e multiplayer online ficam para fases futuras.

## 2. Decisões confirmadas

### Câmera, movimento e mira

- Câmera atrás do personagem, controlada pelo mouse.
- Girar a câmera horizontalmente também gira o personagem.
- Movimento vertical do mouse ajusta câmera e mira, sem inclinar o corpo inteiro.
- W avança, S recua e A/D deslocam de lado em relação à orientação do personagem.
- Mira livre com marcador no centro da tela, sem travamento automático em adversário.
- Ataques e habilidades seguem o direcionamento da mira, respeitando alcance e obstáculos.
- Ataques melee atingem uma área à frente do personagem, limitada pelo alcance da arma.

### Ataques e habilidades

- Botão esquerdo: ataque básico, um ataque por clique.
- Segurar o botão não repete ataques. Cliques respeitam o intervalo do personagem.
- Cada personagem tem três habilidades em Q, E e R; R é a especial, com recarga maior.
- Habilidades usam apenas tempo de recarga, sem mana ou energia no MVP.
- Não há esquiva universal. Avanços e teleportes pertencem ao kit de cada personagem.
- Para habilidades que exigem direcionamento: segurar a tecla mostra alcance e área; soltar executa.
- Ritmo tático intermediário: duelos de aproximadamente 15–25 segundos são referência inicial para balanceamento, não duração garantida nem limite de rodada.

### Personagens iniciais

| Personagem | Perfil | Ataque básico | Q | E | R |
|---|---|---|---|---|---|
| Guerreiro | Melee equilibrado, resistência moderada | Corte de espada em arco à frente | Investida: avanço curto para aproximação | Guarda: redução temporária de dano recebido pela frente | Golpe sísmico: dano e lentidão em uma área próxima |
| Mago | Ranged, menor resistência, distância e controle | Projétil mágico na direção da mira | Orbe explosivo: explode ao atingir inimigo ou obstáculo, causando dano em área | Passo arcano: teleporte curto na direção do movimento, sem atravessar paredes | Campo glacial: área no chão apontado pela mira, limitada por alcance, com dano ao longo do tempo e lentidão |

O jogador escolhe guerreiro ou mago antes da rodada. Personagens podem se repetir na mesma equipe. Bots completam as vagas.

### Runas

- Duas categorias: bônus passivos temporários e habilidades ativas temporárias.
- Bônus passivos ativam na coleta; velocidade, dano e proteção são os exemplos definidos.
- Habilidade de runa fica na tecla F até ser usada ou expirar; tem um uso.
- Cada personagem pode carregar um bônus passivo e uma habilidade de runa simultaneamente.
- Outra coleta da mesma categoria substitui a anterior; as duas categorias não se substituem entre si.
- Surgimento em pontos fixos e simétricos, com aviso visual antes de aparecerem.

### Arena e rodadas

- Arena plana, com obstáculos, centro disputável e duas rotas laterais.
- Espaço suficiente para aproximação, recuo, flanqueamento e disputa das runas.
- Rodadas sem renascimento. Vence a equipe que eliminar os três adversários.
- Quem for eliminado acompanha os aliados até a próxima rodada.
- Após um tempo limite, uma zona de perigo avança das bordas para o centro.
- A zona causa dano fora da área segura, aproximando os sobreviventes.

## 3. Decisões operacionais adotadas para completar o MVP

O usuário autorizou prosseguir sem pausas. Os itens antes em aberto foram resolvidos com valores provisórios, registrados integralmente no README de `arena-v2-completo`:

- Botão direito cancela; apenas uma habilidade pode ser preparada; cancelamento não consome recarga; preparar impede ataque básico.
- Guarda e Cura ativam imediatamente ao pressionar; demais habilidades usam segurar e soltar.
- Teleporte parado segue a direção frontal; paredes e corpos limitam a distância.
- Campo glacial exige mira no chão, alcance limitado e caminho livre; execução inválida não consome recarga.
- Lentidão mais forte prevalece, com renovação da duração, sem multiplicação.
- Runas ativas: Cura e Onda de choque. Um uso, com 25 s para usar. Bônus passivos duram 12 s.
- Seis pontos de runas simétricos; primeira leva aos 10 s, reposição de pontos vazios a cada 24 s e aviso de 4 s.
- Arena plana de 48 × 40 m; zona começa em 90 s, alcança 5 × 5 m aos 135 s; fora dela, dano crescente de 12 a 24/s.
- Limite de segurança de 165 s: sobreviventes, depois vida proporcional; igualdade ou eliminação simultânea gera empate.
- Sem fogo amigo; projéteis atravessam aliados, mas corpos bloqueiam movimento.
- Guerreiro com 270 de vida; mago com 200. Outros números constam do README e permanecem ajustáveis.
- Sensibilidade e distância da câmera podem ser alteradas no menu; minimapa e espectador com Tab estão disponíveis.

## 4. Roadmap de implementação

A sequência abaixo foi executada continuamente, conforme autorização posterior. Os critérios técnicos foram verificados; o teste humano permanece recomendado para refinamento, sem bloquear a entrega.

### Etapa 1 — Câmera e controles

Entrega: pequena área de treinamento com personagem provisório, câmera atrás do personagem, WASD relativo à orientação, mira central e ataque por clique.

Critérios:

- Mouse gira câmera e personagem sem alterar a posição do personagem.
- W/S avançam e recuam; A/D fazem deslocamento lateral sem girar o personagem em outra direção.
- Câmera evita atravessar paredes e mantém o personagem legível perto de obstáculos.
- Mira indica a direção real do ataque; cobertura próxima não pode ser ignorada pela câmera.
- Um clique produz um ataque válido; manter pressionado não gera repetição.
- Pausa libera o cursor e congela combate e temporizadores.

Validação humana: conforto da câmera, sensibilidade, deslocamento lateral e clareza da mira.

### Etapa 2 — Guerreiro e combate melee

Entrega: guerreiro com corte, Investida, Guarda e Golpe sísmico, contra alvos de treinamento.

Critérios:

- Golpes têm preparação, instante de impacto e recuperação perceptíveis.
- Corte acerta apenas alvos dentro do arco e alcance; não atinge atrás de paredes nem aplica dano repetido ao mesmo alvo em um único golpe.
- Investida respeita obstáculos.
- Guarda protege apenas o setor frontal definido.
- Golpe sísmico mostra a área real de dano e lentidão.
- Preparação, execução e recarga funcionam conforme a habilidade; indicador e efeito coincidem.

Validação humana: sensação de peso, alcance e possibilidade de reagir aos golpes.

### Etapa 3 — Mago e duelo melee × ranged

Entrega: mago com projétil básico, Orbe explosivo, Passo arcano e Campo glacial; seleção entre os dois personagens em cenário de duelo.

Critérios:

- Projéteis têm trajetória e colisão verificáveis, inclusive em disparos junto à cobertura.
- Explosão aplica dano por impacto sem duplicação indevida.
- Teleporte usa direção de movimento e não atravessa paredes.
- Campo glacial respeita chão e alcance e aplica dano conforme o tempo, sem depender da taxa de quadros.
- Guerreiro tem oportunidades de aproximação; mago pode criar distância, mas não fugir indefinidamente sem custo de recarga.
- Registrar duração dos duelos e causas das vitórias para ajustar os valores à referência de 15–25 segundos.

Validação humana: os dois kits precisam mudar a forma de jogar e oferecer oportunidades de resposta.

### Etapa 4 — Runas passivas e ativas

Entrega: sistema de dois espaços de runas por personagem, interface de bônus e F, efeitos e surgimento com aviso.

Critérios:

- Bônus e habilidade ativa coexistem; coleta substitui apenas a mesma categoria.
- Bônus termina corretamente; uso da runa ativa consome a habilidade uma única vez.
- Expiração, morte e reinício removem efeitos e habilidades armazenadas corretamente.
- Habilidade ativa direcionada segue a mesma convenção de preparação por tecla.
- Aviso antecipa o surgimento no ponto correto; duas entidades não recebem a mesma runa.

Validação humana: clareza da coleta, expiração, substituição e interesse em disputar cada ponto.

### Etapa 5 — Arena estratégica e zona de perigo

Entrega: arena plana adaptada à terceira pessoa, rotas laterais, coberturas, pontos de runas e zona de perigo.

Critérios:

- Equipes têm acesso simétrico às rotas e pontos disputáveis.
- Câmera, movimento e habilidades funcionam junto a paredes e passagens.
- Dimensões permitem recuo e flanqueamento sem excesso de tempo andando sem interação.
- Zona tem aviso legível, fecha no ritmo configurado e causa dano somente fora da área segura.
- Zona e runas respeitam pausa e reinício; não restam temporizadores da rodada anterior.

Validação humana: leitura do espaço pela câmera e utilidade das rotas para os dois personagens.

### Etapa 6 — Partidas 3×3 e consolidação

Entrega: um jogador, cinco bots usando os kits, seleção de personagem, repetição de personagens permitida, espectador, vitória e nova rodada.

Critérios:

- Exatamente três integrantes por equipe e apenas um personagem controlado pelo jogador.
- Bots usam regras de alcance, colisão, vida e recarga dos jogadores; navegam, atacam e disputam runas sem atravessar obstáculos.
- Nenhum eliminado renasce na rodada; espectador acompanha um aliado vivo.
- Vitória dispara uma única vez; aplicar a regra definida para empate.
- Reinício limpa projéteis, campos persistentes, runas, efeitos, zona e estados de preparação.
- Partidas completas terminam; registrar duração, composição e causa do desfecho.

Validação humana: jogar com os dois personagens, observar se há escolhas táticas e corrigir problemas antes de ampliar o elenco.

## 5. Diretrizes de produção

- Preservar uma cópia executável da V1 antes de iniciar alterações na implementação.
- Manter a documentação de funcionalidades implementadas separada das definições futuras.
- Separar controle humano, câmera, personagem, definição de habilidade, efeitos, runas e estado da rodada.
- Usar dados configuráveis para valores de combate e composições; evitar construir todos os novos comportamentos em um único script de arena.
- Criar no Blender formas e animações provisórias suficientes para ler arma, direção, preparação e impacto. Exportar GLB e preservar fontes .blend.
- Priorizar comportamento e clareza visual; acabamento artístico, elenco amplo e online vêm depois.
- Atualizar testes da V1: ataque contínuo, câmera elevada, avanço universal e dano global de morte súbita serão substituídos.

## 6. Estado após implementação

As Etapas 1–6 estão disponíveis em `arena-v2-completo`. Próximo trabalho possível: refinamento a partir de partidas humanas, animações e áudio; multiplayer continua fora deste MVP.

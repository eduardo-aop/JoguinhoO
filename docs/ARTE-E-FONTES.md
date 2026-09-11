# Arte, fontes e reconstrução

Os personagens e o cenário desta versão foram construídos para o protótipo. A referência de fantasia estilizada não usa modelos, personagens ou texturas extraídos de Dota 2.

## Personagens

Arquivos editáveis mais recentes: `blender/warrior_final.blend` e `blender/mage_final.blend`. Exportações usadas no jogo: `assets/warrior_animated.glb` e `assets/mage_animated.glb`.

Cada personagem tem um esqueleto de 16 ossos e dez clipes: repouso, quatro direções de locomoção, ataque, guarda, magia, reação e morte. O guerreiro tem sete malhas; o mago, seis. As armas e o escudo são geometria do Godot, conectada às mãos por BoneAttachment3D; não estão incorporados ao GLB.

A sequência de refinamento é `stylized_heroes.py` → `refine_attacks.py` → `paint_materials.py` → `refine_locomotion.py`. Cada etapa lê a fonte da etapa anterior. A última grava os arquivos `*_final.blend` e exporta os GLBs. As fontes anteriores foram preservadas, incluindo os scripts de construção e de rig.

A pintura está nos atributos de cor dos vértices. No jogo, `appearance.gd` fornece os materiais que mostram essas cores; o tecido também recebe a cor da equipe e movimento por shader. O ajuste da cabeça à mira é um SkeletonModifier3D no Godot, sem alterar os clipes originais.

O renderizador usado é Compatibility. A conversão de cores para a saída sRGB fica explícita nos shaders de pintura e tecido. A documentação oficial observa que a propriedade `vertex_color_is_srgb` do material padrão não tem efeito nesse renderizador: [BaseMaterial3D](https://docs.godotengine.org/en/4.5/classes/class_basematerial3d.html).

## Cenário e efeitos

Piso e ruínas usam shaders procedurais. Pilares, cristais, vegetação e estandartes são geometria gerada por `fantasy_world.gd`; a decoração estática é agrupada em MultiMesh. As quatro coberturas mantêm colisores próprios. Efeitos transitórios têm duração limitada e teto de 48 instâncias.

## Áudio

Os treze sons são sintetizados por `tools/make_audio.py` e `tools/make_skill_audio.py`, com WAVs em `assets/audio/`. O jogo reutiliza dezoito vozes espaciais e libera os streams ao reiniciar a rodada. Os sons continuam sendo efeitos de protótipo, sujeitos a direção e acabamento de áudio futuros.

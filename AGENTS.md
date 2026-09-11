# Trabalho neste repositório

Este repositório é a pasta permanente do jogo. Continue as alterações aqui e registre o histórico em commits; não crie pastas V7, V8 ou cópias completas para cada melhoria. Use branches para mudanças isoladas e tags somente quando for necessário marcar uma entrega estável.

## Projeto

Godot 4.7.2, GDScript, renderizador Compatibility. Cena principal: `scenes/arena.tscn`. Jogo local 3×3 com um jogador e cinco bots. Base atual: câmera em terceira pessoa acima/atrás do personagem, WASD relativo ao giro horizontal da câmera e cursor livre para mirar, sem giro automático da câmera.

## Verificação

Importe o projeto antes de testar uma cópia nova. Para mudanças de código, execute os testes relevantes e a regressão antes de entregar alterações de jogabilidade:

```sh
python3 tools/validate.py --godot /caminho/para/Godot --output work/validation
```

Para mudanças visuais e de controle, inspecione também no Godot gráfico. Não apresente resultados históricos como testes da versão atual. Atualize o README quando controles ou regras mudarem.

## Arquivos

Versione os arquivos `.uid`, assets exportados e fontes Blender. Preserve `blender/.gdignore`. Não versione `.godot`, backups Blender, credenciais, ambientes locais ou pacotes ZIP. Fontes finais e sequência de reconstrução estão em `docs/ARTE-E-FONTES.md`.

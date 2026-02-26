# cputil-cpp

Ferramenta de linha de comando (CLI) desenvolvida em Bash para automação de testes de estresse em problemas de programação competitiva utilizando C++.

## Funcionalidades

- **Teste de Estresse**: Compara a saída de uma solução otimizada contra uma solução brute force para identificar falhas.
- **Geração de Entradas**: Suporta o gerador interno com opções pré definidas ou geradores customizados via flag `-g`.
- **Compilação Automática**: Compila os fontes C++ utilizando `g++` com as flags `-O2` e `-std=c++17`.
- **Relatório de Erros**: Em caso de divergência, exibe o input gerado e o diff detalhado entre as saídas.
- **Monitoramento de Tempo**: Medição do tempo de execução de cada rodada em milissegundos.
- **Configuração via RC**: Suporte para carregar preferências a partir do arquivo `~/.cputilrc`.

## Instalação

O projeto utiliza um Makefile para automatizar a compilação do gerador interno e a instalação dos scripts no sistema.

### Comandos de Instalação

```bash
# Compilar o gerador interno
make

# Instalar o script e o binário no sistema (requer sudo)
sudo make install
```

## Desinstalação
```Bash
sudo make uninstall
```
## Uso
```Bash
cputil [opções] <solucao.cpp> <bruteforce.cpp>

Opções Disponíveis

    -h: Exibe a mensagem de ajuda.

    -c <arquivo>: Compila e executa um arquivo C++ individualmente.

    -l "<min> <max>": Define os limites numéricos para o gerador (padrão: "1 100").

    -r <num>: Define o número de rodadas de teste.

    -t <num>: Define a quantidade de casos de teste por entrada (T).

    -i <num>: Define a quantidade de números gerados por linha.

    -g <arquivo>: Especifica o caminho para um gerador customizado.

    -s: Ativa a exibição do tempo gasto por rodada.

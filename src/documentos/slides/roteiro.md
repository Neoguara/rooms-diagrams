# Roteiro de Apresentação — Reserva de Salas (Banca de Estágio)

**Apresentador:** José Ronaldo dos Santos Júnior
**Orientador:** Prof. Gustavo Queiroz Silveira
**Duração-alvo:** 13–14 min (limite de 15 min) — da capa até a Conclusão.

> Como usar: o texto em itálico é o que dizer (pode adaptar com suas palavras).
> `[AÇÃO]` são deixas práticas (apontar, trocar de slide, abrir o sistema).
> O tempo de cada slide é o **alvo**; a coluna *acumulado* é o relógio total.

| # | Slide | Alvo | Acumulado |
|---|-------|------|-----------|
| 1 | Capa | 0:30 | 0:30 |
| 2 | Objetivos e Motivações | 1:00 | 1:30 |
| 3 | Tecnologias | 0:45 | 2:15 |
| 4 | Workflow AS-IS | 1:00 | 3:15 |
| 5 | Caso de Uso | 0:40 | 3:55 |
| 6 | Atores | 0:35 | 4:30 |
| 7 | DER | 0:40 | 5:10 |
| 8 | Componentes | 0:45 | 5:55 |
| 9 | Classes (4) | 1:15 | 7:10 |
| 10 | Estado — Usuário | 0:35 | 7:45 |
| 11 | Sequência — Criar Usuário | 0:40 | 8:25 |
| 12 | Sequência — Criar Sala | 0:30 | 8:55 |
| 13 | Implantação | 0:35 | 9:30 |
| 14 | Demonstração (ao vivo) | 2:00 | 11:30 |
| 15 | Artefatos de Requisitos | 0:25 | 11:55 |
| 16 | Conceitos de Eng. de Software | 0:50 | 12:45 |
| 17 | Conclusão | 0:40 | 13:25 |

---

## 1. Capa — `0:30`

*"Bom dia/Boa tarde a todos. Meu nome é José Ronaldo, sou aluno de Ciência da Computação e vou apresentar o trabalho de estágio desenvolvido sob orientação do professor Gustavo Queiroz: o sistema de Reserva de Salas da UniFil. Agradeço à banca pela presença."*

`[Respirar, trocar de slide]`

---

## 2. Objetivos e Motivações — `1:00`

*"O ponto de partida do projeto foi um problema concreto. Hoje o gerenciamento das salas é feito de forma manual, em planilhas. Com a alta demanda, as trocas de horário e as restrições de uso, esse processo fica complexo — e abre espaço para conflitos de agendamento, retrabalho e perda de rastreabilidade de quem reservou o quê."*

*"Diante disso, o objetivo principal foi desenvolver uma solução de agendamento de salas para a UniFil, com três metas: centralizar as informações em um só lugar, automatizar o fluxo de solicitação e aprovação das reservas, e manter um histórico das alterações."*

`[Transição]` *"Para construir isso, usei o seguinte conjunto de tecnologias."*

---

## 3. Tecnologias Utilizadas — `0:45`

*"No back-end usei Java com Spring Boot, expondo uma API REST — é um ecossistema consolidado no mercado corporativo. No front-end, JavaScript com React, para uma interface reativa e componentizada. E o banco de dados é o PostgreSQL, escolhido pela maturidade e pela boa integração com esses frameworks."*

`[Trocar para o separador "Diagramas" e seguir direto para o próximo]`

---

## 4. Workflow AS-IS (BPMN) — `1:00`

*"Antes de modelar a solução, mapeei o processo atual nessa notação BPMN. Repare no fluxo:"*
`[APONTAR a raia do Professor]` *"o professor solicita a reserva e precisa consultar a planilha manualmente. Quando há conflito de horário, a resolução é por negociação informal."*
`[APONTAR a raia do Coordenador]` *"Depois a solicitação passa pela análise do coordenador e, se aprovada, alguém atualiza a planilha à mão e gera o mapa de salas em PDF."*

*"Ou seja: é todo manual nos pontos críticos — e é exatamente isso que o sistema vem resolver."*

---

## 5. Diagrama de Caso de Uso — `0:40`

*"A partir do processo, levantei os casos de uso do sistema."*
`[Gesto amplo sobre o diagrama]` *"Aqui estão agrupadas as principais funcionalidades: autenticação, gerenciamento de salas e de seus recursos, o fluxo de agendamento, o histórico e os relatórios. Cada caso de uso foi detalhado em um artefato próprio, que comento mais à frente."*

---

## 6. Atores do Sistema — `0:35`

*"O sistema tem dois atores. O `sa_professor`, que é o usuário comum: faz autenticação, gerencia salas e agendamentos e consulta relatórios e histórico. E o `sa_coordenador`, que é uma especialização do professor — herda todas as permissões dele e ganha o acesso ao gerenciamento de usuários."*

---

## 7. Modelagem do Banco de Dados (DER) — `0:40`

*"Este é o DER, a modelagem das entidades no banco."*
`[APONTAR as entidades centrais]` *"As entidades centrais são usuário, sala, tipo de sala, recurso e prédio, além das entidades ligadas ao agendamento. As relações garantem, por exemplo, que cada sala pertence a um prédio e a um tipo, e que uma sala pode ter vários recursos associados."*

---

## 8. Diagrama de Componentes — Visão Geral dos Módulos — `0:45`

*"Em alto nível, o sistema é organizado em módulos por domínio: autenticação, usuários, salas e eventos."*
`[APONTAR as setas]` *"Eles não conversam de qualquer jeito: o módulo de autenticação acessa usuários por uma porta bem definida, e o módulo de eventos referencia usuário e sala apenas pelo identificador. Isso mantém as fronteiras entre os módulos claras — é a base do monólito modular que detalho no final."*

---

## 9. Diagramas de Classe — Usuário, Sala, Evento, Autenticação — `1:15`

> Passe os 4 slides em sequência, sem se prender a cada classe.

*"Agora detalhando os módulos internamente. Em todos eles segui a mesma estrutura em camadas: o domínio no centro, a aplicação com os casos de uso, e a infraestrutura por fora."*

`[Slide Usuário]` *"No módulo de Usuário dá pra ver bem isso: a entidade `User` no domínio, os casos de uso como criar e atualizar na aplicação, e o controller e o repositório na infraestrutura."*

`[Slide Sala]` *"O módulo de Sala é o mais rico — concentra sala, tipo de sala, recurso e prédio, cada um com seu CRUD."*

`[Slides Evento e Autenticação — rápido]` *"E temos ainda os módulos de Evento, responsável pelos agendamentos, e de Autenticação. A estrutura se repete em todos, o que dá consistência ao código."*

---

## 10. Diagrama de Estado — Usuário — `0:35`

*"Algumas entidades têm um ciclo de vida controlado por estados. No usuário, por exemplo, ele transita entre ativo, inativo e excluído — e cada transição é uma operação específica do sistema, não uma edição livre do campo. Isso evita estados inválidos."*

---

## 11. Diagrama de Sequência — Criar Usuário — `0:40`

*"Para mostrar como as camadas colaboram em tempo de execução, trouxe dois fluxos. Este é o de criar usuário:"*
`[Seguir as setas de cima para baixo]` *"a requisição chega no controller, vai para o caso de uso, que cria a entidade — já validada — e a persiste pelo repositório, devolvendo a resposta. Note que cada camada tem uma responsabilidade clara."*

---

## 12. Diagrama de Sequência — Criar Sala — `0:30`

*"O mesmo padrão se repete para criar sala — com um passo a mais:"*
`[APONTAR o loop]` *"além de salvar a sala, o sistema associa os recursos informados, validando cada um antes. O fluxo é representativo dos demais cadastros do sistema."*

---

## 13. Diagrama de Implantação — `0:35`

*"Em termos de implantação, a arquitetura é simples e separada em responsabilidades: o navegador do cliente acessa o front-end, que conversa com a API do back-end por HTTPS, e a API acessa o banco PostgreSQL. Tudo se comunica de forma segura."*

`[Trocar para o separador "Apresentação do Sistema"]`

---

## 14. Demonstração — AO VIVO — `2:00`

> Abrir o sistema já logado/preparado. Se algo falhar, há prints no fim do PDF (slides de apoio).

*"Agora vou mostrar o sistema funcionando."*

Roteiro da demo (objetivo, sem se perder):
1. `[Login]` — *"Entro com e-mail e senha."*
2. `[Gerenciar Salas]` — *"Aqui cadastro e edito salas, com tipo, capacidade e recursos."*
3. `[Buscar Sala]` — *"O professor consulta as salas disponíveis."*
4. `[Solicitações / Minhas Reservas]` — *"Faço uma solicitação e acompanho o status dela."*
5. `[Grade de Horários]` — *"E aqui visualizo a ocupação das salas na grade."*

*"Esse é o núcleo do que já está funcionando."*

`[Voltar para os slides]`

---

## 15. Artefatos de Requisitos — `0:25`

*"Todo esse desenvolvimento foi sustentado por artefatos de requisitos: o Documento de Visão, a Especificação Complementar, o Glossário, a Solicitação dos Principais Envolvidos e a Especificação de Caso de Uso — que guiaram as decisões do projeto."*

---

## 16. Conceitos de Engenharia de Software Aplicados — `0:50`

*"Um objetivo pessoal do estágio foi aplicar, na prática, conceitos de engenharia de software — e não só entregar funcionalidade."*

*"Usei Clean Architecture, separando domínio, aplicação e infraestrutura por portas e adaptadores. Apliquei Domain-Driven Design, com entidades ricas em comportamento, value objects para os identificadores e agregados referenciados por ID. Usei o Notification Pattern nas validações, que acumulam os erros em vez de estourar exceção campo a campo. E organizei tudo como um monólito modular — que é o que vimos no diagrama de componentes."*

---

## 17. Conclusão — `0:40`

*"Para concluir: o estágio entregou a autenticação e o gerenciamento de usuários, o cadastro e gerenciamento de salas, recursos e prédios, e a modelagem completa do sistema."*

*"Estão em desenvolvimento o fluxo de solicitação e aprovação de reservas e a grade de horários com a visualização de disponibilidade."*

*"Com isso encerro. Agradeço a atenção da banca e fico à disposição para as perguntas."*

`[FIM — abrir para perguntas]`

---

## Dicas finais

- **Ritmo:** se passar de ~12 min ao chegar na demo, encurte a demo (itens 1, 2 e 5 já contam a história).
- **Slides de diagrama** são para olhar e apontar, não para ler — fale olhando para a banca.
- **Slides de apoio** (depois da Conclusão, no PDF): use só se perguntarem de um diagrama específico ou se a demo falhar (os prints das telas estão lá).
- **Perguntas prováveis:** por que essas tecnologias; o escopo é a UniFil toda; como funciona a resolução de conflito de horário; o que falta para implantar.
- **Antes de começar:** deixe o sistema aberto e logado numa aba, e o PDF em tela cheia.

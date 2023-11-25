# CareConnect

CareConnect

É necessário instalar as dependencias antes de ser possivel rodar o codigo. para instalar basta usar "flutter pub upgrade"
Aplicativo foi criado usando Flutter e Dart.
Tem conexão com o ChatGPT usando da OPENAI API em conexão direta com o servidor.
Foram usados pacotes flutter de:
Material(O Basico usado para criação de GUI)
Speech to Text (Para absorver o audio de voz para texto)
Flutter TTS (Para ler o texto recebido pela AI)
Http Flutter (Para fazer os requests para o servidor da OPENAI para conexão de API).
As classes foram separadas em Voice/Text Input Box onde o usuário informa da dúvida tanto por texto ou por voz e VoiceInputScreen onde o usuário pode ver qual foi a dúvida enviada para a AI
Também foi usado OpenAIRequest e OpenAIService para conexão com a API do OpenAI.
Para executar é necessário um aparelho Android ou IOS, também pode ser executado dentro de um emulador através do Android Studio Emulator.
Todos os chamados são excluidos depois de serem feitos para melhor gerenciamento de memória, também foi usado Flutter ao invés de react por seu melhor gerenciamento de memória.

# 📱 Flutter SQLite CRUD App - Cadastro de Alunos

Este é um aplicativo Flutter simples que demonstra um **CRUD local** utilizando o pacote [`sqflite`](https://pub.dev/packages/sqflite). O app permite cadastrar, listar, buscar, atualizar e excluir alunos com os seguintes dados:

- 📌 Matrícula (campo único usado como identificador)
- 🧑 Nome
- 🎂 Idade
- 🎓 Curso

---

## 🚀 Como rodar a aplicação

### Pré-requisitos:

- ✅ [Flutter SDK](https://docs.flutter.dev/get-started/install)
- ✅ [Android Studio (com AVD configurado)](https://developer.android.com/studio)
- ✅ Emulador Android ou dispositivo físico
- ✅ Visual Studio Code (opcional, mas recomendado)

---

### 📦 Dependências

Este app usa os pacotes:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.0
```
### 1. 🔽 Clone este repositório

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```
### 2. 📦 Instale as dependências

```bash
flutter pub get
```

### 3. 📱 Inicie o emulador Android

```bash
flutter emulators --launch nome_do_emulador
```
### 4. 🚀 Rode o app no emulador

```bash

flutter devices
```
Depois execute:
```bash
flutter run -d <id emulador>
```

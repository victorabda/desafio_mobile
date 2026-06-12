# ByCoders iOS Challenge

[English](#english) | [Português](#português)

## Stack

- SwiftUI
- Swift Concurrency
- Combine
- MapKit
- CoreLocation
- SwiftData
- Firebase Authentication
- Firebase Analytics
- Firebase Crashlytics
- Swift Testing
- XCUITest


## English

SwiftUI application developed for the ByCoders Senior iOS Developer technical challenge.

The app authenticates users with Firebase Authentication, displays their current location on a map, persists the authenticated user and last location locally, sends events to Firebase Analytics, and records non-fatal errors in Firebase Crashlytics.

### Core features

- Email and password authentication with Firebase Authentication.
- Home screen with MapKit and the user's current-location marker.
- Local persistence of the authenticated user and last location with SwiftData.
- Success events sent to Firebase Analytics.
- Non-fatal error reporting with Firebase Crashlytics.
- Unit tests with Swift Testing and UI/E2E tests with XCUITest.
- English and Brazilian Portuguese localization, including the location permission message.

### Additional features beyond the briefing

- Restores the persisted session when the app is reopened.
- Secure logout with confirmation and local-session removal.
- Dedicated explanation screen when location access is denied.
- Shortcut to the app's Settings page to enable location permission.
- Recenter button displayed after the user moves the map.
- Password visibility control on the login screen.
- Explicit loading, permission-denied, and error states.
- Deterministic UI test scenarios that do not depend on Firebase, internet access, or real GPS data.
- SwiftUI previews for the main screens and map component.

### Requirements and setup

- macOS with an Xcode version compatible with iOS 17.6 or later.
- Swift Package Manager enabled.
- An iOS Simulator or physical device.

1. Clone the repository.
2. Open `ByCodersChallenge/ByCodersChallenge.xcodeproj`.
3. Wait for Swift Package Manager to resolve the Firebase dependencies.
4. Select the `ByCodersChallenge` scheme.
5. Run with `Command + R`.

Demo credentials:

```text
Email: teste@teste.com
Password: 123456
```

Command-line build:

```bash
xcodebuild build \
  -project ByCodersChallenge/ByCodersChallenge.xcodeproj \
  -scheme ByCodersChallenge \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

### Firebase configuration and security

The project uses `FirebaseAuth`, `FirebaseAnalytics`, and `FirebaseCrashlytics`.

The committed `GoogleService-Info.plist` belongs exclusively to the challenge's demonstration environment. It is intentionally versioned so evaluators can run the app without manual Firebase configuration. It contains client configuration identifiers and keys, but does not grant administrative access to Firebase.

For a production app, use separate Firebase projects for development, staging, and production; restrict enabled resources and authentication methods; never reuse real credentials or data; and never commit service-account keys or administrative credentials.

### Architecture and persistence

The project follows MVVM with dependency injection:

```text
SwiftUI View
    -> ViewModel
        -> Service protocols
        -> Repository protocols
            -> Firebase / CoreLocation / SwiftData
```

`AppContainer` composes dependencies, `AppSession` owns global authentication state, ViewModels coordinate use cases, services integrate with Firebase and CoreLocation, and repositories isolate SwiftData persistence. Views and ViewModels do not depend directly on Firebase.

SwiftData stores the authenticated user's identifier, email, name, and login date, as well as the last location's latitude, longitude, and update date.

### Analytics and Crashlytics

| Event | Parameters |
|---|---|
| `login_success` | `user_id`, `provider` |
| `home_rendered` | `user_id`, `latitude`, `longitude` |

Authentication, session restoration, location loading, persistence, and logout failures are recorded as non-fatal errors with screen and action context. A user's decision to deny location permission is not treated as an error.

### Tests

Unit tests cover credential validation, authentication success and failure, persistence, global session updates, Analytics events, Crashlytics reporting, location states, and logout.

UI/E2E tests cover login validation, password visibility, successful and failed login, session restoration, Home loading, denied location permission, location failure, logout, and an English-localization smoke test.

Run them with `Command + U` or:

```bash
xcodebuild test \
  -project ByCodersChallenge/ByCodersChallenge.xcodeproj \
  -scheme ByCodersChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

---

## Português

Aplicativo SwiftUI desenvolvido para o desafio técnico de Desenvolvedor iOS Sênior da ByCoders.

O app autentica usuários com Firebase Authentication, exibe a localização atual em um mapa, persiste localmente o usuário autenticado e a última localização, envia eventos ao Firebase Analytics e registra erros não fatais no Firebase Crashlytics.

### Funcionalidades principais

- Autenticação com email e senha usando Firebase Authentication.
- Home com MapKit e marcador da localização atual do usuário.
- Persistência local do usuário autenticado e da última localização com SwiftData.
- Eventos de sucesso enviados ao Firebase Analytics.
- Registro de erros não fatais com Firebase Crashlytics.
- Testes unitários com Swift Testing e testes UI/E2E com XCUITest.
- Localização em inglês e português do Brasil, incluindo a mensagem de permissão de localização.

### Funcionalidades adicionais além do briefing

- Restauração da sessão persistida ao reabrir o aplicativo.
- Logout seguro com confirmação e remoção da sessão local.
- Tela dedicada para explicar a necessidade da localização quando a permissão é negada.
- Atalho para os Ajustes do aplicativo para habilitar a permissão de localização.
- Botão para recentralizar o mapa exibido após o usuário movimentá-lo.
- Controle para exibir ou ocultar a senha na tela de login.
- Estados explícitos de carregamento, permissão negada e erro.
- Cenários determinísticos de testes de UI que não dependem do Firebase, internet ou GPS real.
- Previews SwiftUI para as telas principais e o componente de mapa.

### Requisitos e execução

- macOS com uma versão do Xcode compatível com iOS 17.6 ou superior.
- Swift Package Manager habilitado.
- Um simulador iOS ou dispositivo físico.

1. Clone o repositório.
2. Abra `ByCodersChallenge/ByCodersChallenge.xcodeproj`.
3. Aguarde o Swift Package Manager resolver as dependências do Firebase.
4. Selecione o scheme `ByCodersChallenge`.
5. Execute com `Command + R`.

Credenciais de demonstração:

```text
Email: teste@teste.com
Senha: 123456
```

Compilação pela linha de comando:

```bash
xcodebuild build \
  -project ByCodersChallenge/ByCodersChallenge.xcodeproj \
  -scheme ByCodersChallenge \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

### Configuração e segurança do Firebase

O projeto utiliza `FirebaseAuth`, `FirebaseAnalytics` e `FirebaseCrashlytics`.

O `GoogleService-Info.plist` versionado pertence exclusivamente ao ambiente de demonstração do desafio. Ele foi incluído intencionalmente para permitir que os avaliadores executem o app sem configuração manual do Firebase. O arquivo contém identificadores e chaves de configuração do cliente, mas não concede acesso administrativo ao Firebase.

Em um aplicativo de produção, utilize projetos Firebase separados para desenvolvimento, homologação e produção; restrinja os recursos e métodos de autenticação habilitados; nunca reutilize dados ou credenciais reais; e nunca versione service-account keys ou credenciais administrativas.

### Arquitetura e persistência

O projeto utiliza MVVM com injeção de dependências:

```text
SwiftUI View
    -> ViewModel
        -> Service protocols
        -> Repository protocols
            -> Firebase / CoreLocation / SwiftData
```

O `AppContainer` compõe as dependências, o `AppSession` mantém o estado global de autenticação, as ViewModels coordenam os casos de uso, os serviços integram Firebase e CoreLocation, e os repositórios isolam a persistência SwiftData. Views e ViewModels não dependem diretamente do Firebase.

O SwiftData armazena o identificador, email, nome e data de login do usuário autenticado, além da latitude, longitude e data de atualização da última localização.

### Analytics e Crashlytics

| Evento | Parâmetros |
|---|---|
| `login_success` | `user_id`, `provider` |
| `home_rendered` | `user_id`, `latitude`, `longitude` |

Falhas de autenticação, restauração da sessão, carregamento da localização, persistência e logout são registradas como erros não fatais com contexto de tela e ação. A decisão do usuário de negar a localização não é tratada como erro.

### Testes

Os testes unitários cobrem validação das credenciais, sucesso e falha de autenticação, persistência, atualização da sessão global, eventos de Analytics, registros no Crashlytics, estados de localização e logout.

Os testes UI/E2E cobrem validação do login, visibilidade da senha, login com sucesso e falha, restauração da sessão, carregamento da Home, permissão de localização negada, falha de localização, logout e um smoke test da localização em inglês.

Execute com `Command + U` ou:

```bash
xcodebuild test \
  -project ByCodersChallenge/ByCodersChallenge.xcodeproj \
  -scheme ByCodersChallenge \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```
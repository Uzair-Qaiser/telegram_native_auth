import Flutter
import UIKit

public class TelegramLoginPlugin: NSObject, FlutterPlugin {

    private var isConfigured = false

    private var pendingLoginResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "telegram_login",
            binaryMessenger: registrar.messenger()
        )
        let instance = TelegramLoginPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "configure":
            handleConfigure(call: call, result: result)
        case "login":
            handleLogin(result: result)
        case "cancelLogin":
            handleCancelLogin(result: result)
        case "handleUrl":
            handleUrlCall(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleConfigure(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let clientId = args["clientId"] as? String,
              let redirectUri = args["redirectUri"] as? String,
              let scopes = args["scopes"] as? [String] else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Missing required configuration parameters",
                details: nil
            ))
            return
        }

        let fallbackScheme = args["fallbackScheme"] as? String

        DispatchQueue.main.async { [weak self] in
            TelegramLogin.configure(
                clientId: clientId,
                redirectUri: redirectUri,
                scopes: scopes,
                fallbackScheme: fallbackScheme
            )
            self?.isConfigured = true
            result(nil)
        }
    }

    private func handleLogin(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            guard self.isConfigured else {
                result(FlutterError(
                    code: "NOT_CONFIGURED",
                    message: "TelegramLogin.configure() was not called before login()",
                    details: nil
                ))
                return
            }

            self.pendingLoginResult = result

            TelegramLogin.login { [weak self] loginResult in
                DispatchQueue.main.async {
                    self?.deliverLoginResult(loginResult)
                }
            }
        }
    }

    private func handleCancelLogin(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let pending = self.pendingLoginResult else {
                result(false)
                return
            }
            self.pendingLoginResult = nil
            TelegramLogin.cancel()
            pending(FlutterError(
                code: "CANCELLED",
                message: "The user cancelled the login",
                details: nil
            ))
            result(true)
        }
    }

    private func handleUrlCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let urlString = args["url"] as? String,
              let url = URL(string: urlString) else {
            result(FlutterError(
                code: "INVALID_ARGUMENTS",
                message: "Invalid URL provided",
                details: nil
            ))
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
            result(true)
        }
    }

    @MainActor
    private func forwardUrl(_ url: URL) {
        TelegramLogin.handle(url)
    }

    private func deliverLoginResult(_ loginResult: Result<LoginData, Error>) {
        guard let pending = pendingLoginResult else { return }
        pendingLoginResult = nil
        switch loginResult {
        case .success(let data):
            pending(["idToken": data.idToken])
        case .failure(let error):
            let (code, message) = Self.mapError(error)
            pending(FlutterError(code: code, message: message, details: nil))
        }
    }

    private static func mapError(_ error: Error) -> (String, String) {
        if let tgError = error as? TelegramLoginError {
            switch tgError {
            case .notConfigured:
                return ("NOT_CONFIGURED", "TelegramLogin.configure() was not called before login()")
            case .noAuthorizationCode:
                return ("NO_AUTH_CODE", "The callback URL did not contain an authorization code")
            case .serverError(let statusCode):
                return ("SERVER_ERROR", "Server error: " + String(statusCode))
            case .requestFailed(let reason):
                return ("REQUEST_FAILED", reason)
            case .cancelled:
                return ("CANCELLED", "The user cancelled the login")
            }
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return ("NETWORK_ERROR", nsError.localizedDescription)
        }

        return ("UNKNOWN_ERROR", error.localizedDescription)
    }

    public func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
        }
        return true
    }

    public func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]) -> Void
    ) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        DispatchQueue.main.async { [weak self] in
            self?.forwardUrl(url)
        }
        return true
    }
}

import XCTest
@testable import telegram_native_auth

final class CallbackRegistrationTests: XCTestCase {
    func testUniversalLinkHandlerIsExposedToFlutter() {
        let plugin = TelegramLoginPlugin()
        let selector = NSSelectorFromString("application:continueUserActivity:restorationHandler:")
        XCTAssertTrue(plugin.responds(to: selector))
    }

    func testCustomSchemeHandlerIsExposedToFlutter() {
        let plugin = TelegramLoginPlugin()
        XCTAssertTrue(plugin.responds(to: NSSelectorFromString("application:openURL:options:")))
    }
}

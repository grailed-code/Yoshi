//
//  DebugConfigurationManager.swift
//  Yoshi
//
//  Created by Michael Campbell on 12/22/15.
//  Copyright © 2015 Prolific Interactive. All rights reserved.
//

/// The configuration manager for the debug menu.
final class YoshiConfigurationManager {

    /// The default instance.
    static let sharedInstance = YoshiConfigurationManager()

    private var yoshiMenuItems = [YoshiGenericMenu]()
    private var invocations: [YoshiInvocation]?
    private weak var debugViewController: DebugViewController?

    /**
     Sets the debug options to use for presenting the debug menu.

     - parameter menuItems: The menu items for presentation.
     - parameter invocations: The invocation types.
     */
    func setupDebugMenuOptions(_ menuItems: [YoshiGenericMenu], invocations: [YoshiInvocation]) {
        yoshiMenuItems = menuItems
        self.invocations = invocations
    }
    
    /**
     Allows client application to indicate it has restarted.
     Clears inertnal state.
     */
    func restart() {
        debugViewController = nil
        
        guard let invocations = invocations else {
            return
        }
        
        setupDebugMenuOptions(yoshiMenuItems, invocations: invocations)
    }

    /// Helper function to indicate if the given invocation should show Yoshi.
    ///
    /// - parameter invocation: Invocation method called.
    ///
    /// - returns: `true` if Yoshi should appear. `false` if not.
    func shouldShow(_ invocation: YoshiInvocation) -> Bool {
        guard let invocations = invocations else {
            return false
        }

        if  invocations.contains(.all) {
            return true
        }

        return invocations.contains(invocation)
    }

    /**
     Invokes the display of the debug menu.
     */
    func show() {
        let window = UIApplication.shared.keyWindow

        let navigationController = UINavigationController()
        let debugViewController = DebugViewController(
            options: yoshiMenuItems,
            isRootYoshiMenu: true,
            completion: { completionBlock in
                window?.rootViewController?.dismiss(
                    animated: true,
                    completion: { () -> Void in
                        completionBlock?()
                    }
                )
            }
        )

        navigationController.modalPresentationStyle = .formSheet
        navigationController.setViewControllers([debugViewController], animated: false)

        window?.rootViewController?.present(navigationController, animated: true, completion: nil)
        self.debugViewController = debugViewController
    }

    /// Return a navigation controller presenting the debug view controller.
    ///
    /// - Returns: Debug navigation controller
    func debugNavigationController() -> UINavigationController {
        let navigationController = UINavigationController()

        let debugViewController = DebugViewController(options: yoshiMenuItems, isRootYoshiMenu: true, completion: { _ in
            navigationController.dismiss(animated: true)
        })
        self.debugViewController = debugViewController

        navigationController.setViewControllers([debugViewController], animated: false)

        return navigationController
    }

    /**
     Dismisses the debug view controller, if possible.

     - parameter action: The action to take upon completion.
     */
    func dismiss(_ action: VoidCompletionBlock? = nil) {
        if let completionHandler = debugViewController?.completionHandler {
            completionHandler(action)
        }
    }
}
